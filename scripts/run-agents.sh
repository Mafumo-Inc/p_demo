#!/bin/bash

# マルチエージェント並列実行スクリプト
# Claude Code MAX / Codex をターミナルから直接実行

# set -e をコメントアウト（エラー時も続行）
# set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# プロジェクトルートディレクトリを取得
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# エージェント設定ファイルを読み込み
AGENT_CONFIG="$PROJECT_ROOT/.agents/agent-config.json"

if [ ! -f "$AGENT_CONFIG" ]; then
  echo -e "${RED}❌ エージェント設定ファイルが見つかりません: $AGENT_CONFIG${NC}"
  echo -e "${YELLOW}💡 まず 'npm run agent:setup' を実行してください${NC}"
  exit 1
fi

# 日付サフィックスを取得
DATE_SUFFIX=$(jq -r '.workflow.date_suffix' "$AGENT_CONFIG" 2>/dev/null || date +%Y%m%d)

echo -e "${BLUE}🚀 マルチエージェント並列実行を開始します${NC}"
echo -e "${YELLOW}📅 日付サフィックス: $DATE_SUFFIX${NC}"
echo ""

# 実行するエージェントを選択（引数がない場合は全エージェント）
if [ $# -eq 0 ]; then
  AGENTS_TO_RUN=$(jq -r '.agents[].name' "$AGENT_CONFIG")
else
  AGENTS_TO_RUN="$@"
fi

# 各エージェントを並列実行
PIDS=()
AGENT_NAMES=()

for agent_name in $AGENTS_TO_RUN; do
  # エージェント情報を取得
  agent_info=$(jq -r ".agents[] | select(.name == \"$agent_name\")" "$AGENT_CONFIG" 2>/dev/null)
  
  if [ -z "$agent_info" ]; then
    echo -e "${RED}❌ エージェント '$agent_name' が見つかりません${NC}"
    continue
  fi

  worktree_path=$(echo "$agent_info" | jq -r '.worktree_path')
  model_type=$(echo "$agent_info" | jq -r '.model_type')
  model=$(echo "$agent_info" | jq -r '.model')
  prompt_template=$(echo "$agent_info" | jq -r '.prompt_template')
  role=$(echo "$agent_info" | jq -r '.role')

  if [ ! -d "$worktree_path" ]; then
    echo -e "${RED}❌ Worktreeが見つかりません: $worktree_path${NC}"
    continue
  fi

  # プロンプトファイルのパス
  prompt_file="$PROJECT_ROOT/$prompt_template"
  
  if [ ! -f "$prompt_file" ]; then
    echo -e "${YELLOW}⚠️  プロンプトファイルが見つかりません: $prompt_file${NC}"
    echo -e "${YELLOW}   デフォルトプロンプトを使用します${NC}"
    prompt_file=""
  fi

  echo -e "${GREEN}➤ ${agent_name} (${role}) を起動中...${NC}"
  echo -e "   Model: ${model} (${model_type})"
  echo -e "   Worktree: ${worktree_path}"

  # バックグラウンドでエージェントを実行
  (
    cd "$worktree_path"
    
    # ログファイル
    log_file="$worktree_path/.agent-${agent_name}.log"
    
    # モデルタイプに応じてコマンドを実行
    if [ "$model_type" == "claude-code-max" ]; then
      # Claude Code MAX を実行
      if ! command -v claude &> /dev/null; then
        echo -e "${RED}❌ claude コマンドが見つかりません${NC}"
        echo -e "${YELLOW}💡 Claude Code MAXがインストールされているか確認してください${NC}"
        continue
      fi
      
    # モデル名をエイリアスに変換（sonnet-4.5 -> sonnet, opus -> opus）
    model_alias=$(echo "$model" | sed 's/claude-//' | sed 's/-4\.5//' | sed 's/-4-5//')
    
    # Pro/Maxログイン運用を優先（APIキーを一時的に無効化）
    # ターミナルではPro/Maxログイン運用を使い、API課金を避ける
    use_pro_max_login=false
    if [ -z "$ANTHROPIC_API_KEY" ]; then
      # APIキーが設定されていない場合はPro/Maxログインを使用
      use_pro_max_login=true
    else
      # APIキーが設定されている場合でも、Pro/Maxログインが可能か確認
      # APIキーを一時的に無効化して確認
      original_api_key="$ANTHROPIC_API_KEY"
      unset ANTHROPIC_API_KEY
      if claude whoami 2>&1 | grep -q -E "(masafumikikuchi|logged in|authenticated)"; then
        # Pro/Maxログイン済みの場合は、APIキーを一時的に無効化してPro/Maxログインを使用
        use_pro_max_login=true
      fi
      # APIキーを復元
      export ANTHROPIC_API_KEY="$original_api_key"
    fi
    
    # プロンプトを準備
    if [ -n "$prompt_file" ] && [ -f "$prompt_file" ]; then
      prompt_content=$(cat "$prompt_file")
      # REQUIREMENTS.mdの内容も追加
      if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
        requirements_content=$(cat "$PROJECT_ROOT/REQUIREMENTS.md")
        prompt_content="${requirements_content}

---

${prompt_content}"
      fi
    else
      prompt_content="REQUIREMENTS.mdを読み込み、${role}として作業してください。"
      if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
        requirements_content=$(cat "$PROJECT_ROOT/REQUIREMENTS.md")
        prompt_content="${requirements_content}

---

${prompt_content}"
      fi
    fi
    
    # Claudeを非対話モードで実行
    # Pro/Maxログイン運用を優先（APIキーを一時的に無効化）
    # Macではtimeoutコマンドがないため、バックグラウンドで実行してタイマーを設定
    (
      if [ "$use_pro_max_login" = true ] && [ -n "$ANTHROPIC_API_KEY" ]; then
        # Pro/Maxログインを使用するため、APIキーを一時的に無効化
        unset ANTHROPIC_API_KEY
        echo "$prompt_content" | claude --print --model "$model_alias" > "$log_file" 2>&1
      else
        # APIキーを使用（またはPro/Maxログインのみ）
        echo "$prompt_content" | claude --print --model "$model_alias" > "$log_file" 2>&1
      fi
      echo $? > "$worktree_path/.agent-${agent_name}.exitcode"
    ) &
    claude_pid=$!
      
      # タイムアウト監視（30分 = 1800秒）
      timeout_seconds=1800
      start_time=$(date +%s)
      while kill -0 $claude_pid 2>/dev/null; do
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        if [ $elapsed -gt $timeout_seconds ]; then
          kill $claude_pid 2>/dev/null
          echo -e "${YELLOW}⚠️  ${agent_name} がタイムアウトしました（30分）${NC}" >&2
          echo 124 > "$worktree_path/.agent-${agent_name}.exitcode"
          break
        fi
        sleep 5
      done
      
      wait $claude_pid 2>/dev/null
      exit_code=$(cat "$worktree_path/.agent-${agent_name}.exitcode" 2>/dev/null || echo 0)
      if [ $exit_code -ne 0 ] && [ $exit_code -ne 124 ]; then
        echo -e "${RED}❌ ${agent_name} の実行に失敗しました（終了コード: $exit_code）${NC}" >&2
        echo -e "${YELLOW}ログファイル: $log_file${NC}" >&2
        echo -e "${YELLOW}💡 認証状態を確認: 'npm run agent:auth' を実行してください${NC}" >&2
      fi
    elif [ "$model_type" == "codex" ]; then
      # Codex (OpenAI) を実行
      if ! command -v codex &> /dev/null; then
        echo -e "${RED}❌ codex コマンドが見つかりません${NC}"
        echo -e "${YELLOW}💡 Codexがインストールされているか確認してください${NC}"
        continue
      fi
      
      # プロンプトを準備
      if [ -n "$prompt_file" ] && [ -f "$prompt_file" ]; then
        prompt_content=$(cat "$prompt_file")
        # REQUIREMENTS.mdの内容も追加
        if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
          requirements_content=$(cat "$PROJECT_ROOT/REQUIREMENTS.md")
          prompt_content="${requirements_content}

---

${prompt_content}"
        fi
      else
        prompt_content="REQUIREMENTS.mdを読み込み、${role}として作業してください。"
        if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
          requirements_content=$(cat "$PROJECT_ROOT/REQUIREMENTS.md")
          prompt_content="${requirements_content}

---

${prompt_content}"
        fi
      fi
      
      # Codexを実行（--full-autoで非対話モード、--modelでモデル指定）
      # モデル名をcodex形式に変換（gpt-4 -> gpt-5-codex など）
      codex_model="$model"
      if [ "$model" == "gpt-4" ]; then
        codex_model="gpt-5-codex"
      fi
      
      # Codexを実行（タイムアウト30分）
      (
        echo "$prompt_content" | codex exec --full-auto --model "$codex_model" > "$log_file" 2>&1
        echo $? > "$worktree_path/.agent-${agent_name}.exitcode"
      ) &
      codex_pid=$!
      
      # タイムアウト監視（30分 = 1800秒）
      timeout_seconds=1800
      start_time=$(date +%s)
      while kill -0 $codex_pid 2>/dev/null; do
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        if [ $elapsed -gt $timeout_seconds ]; then
          kill $codex_pid 2>/dev/null
          echo -e "${YELLOW}⚠️  ${agent_name} がタイムアウトしました（30分）${NC}" >&2
          echo 124 > "$worktree_path/.agent-${agent_name}.exitcode"
          break
        fi
        sleep 5
      done
      
      wait $codex_pid 2>/dev/null
      exit_code=$(cat "$worktree_path/.agent-${agent_name}.exitcode" 2>/dev/null || echo 0)
      if [ $exit_code -ne 0 ] && [ $exit_code -ne 124 ]; then
        echo -e "${RED}❌ ${agent_name} の実行に失敗しました（終了コード: $exit_code）${NC}" >&2
        echo -e "${YELLOW}ログファイル: $log_file${NC}" >&2
      fi
    else
      echo -e "${RED}❌ 不明なモデルタイプ: $model_type${NC}"
      continue
    fi
    
    echo -e "${GREEN}✅ ${agent_name} の実行が完了しました${NC}"
  ) &
  
  PIDS+=($!)
  AGENT_NAMES+=("$agent_name")
done

# 全てのエージェントの完了を待つ
echo ""
echo -e "${BLUE}⏳ 全エージェントの完了を待っています...${NC}"
echo ""

for i in "${!PIDS[@]}"; do
  pid=${PIDS[$i]}
  agent_name=${AGENT_NAMES[$i]}
  
  if wait $pid; then
    echo -e "${GREEN}✅ ${agent_name} が正常に完了しました${NC}"
  else
    echo -e "${RED}❌ ${agent_name} がエラーで終了しました${NC}"
  fi
done

echo ""
echo -e "${GREEN}🎉 全エージェントの実行が完了しました！${NC}"
echo ""
echo -e "${BLUE}📝 次のステップ:${NC}"
echo -e "1. 各worktreeの変更を確認: git status"
echo -e "2. 変更をコミット: git add . && git commit -m '...'"
echo -e "3. PRを作成して比較・レビュー"
echo -e "4. 最良案を選択してマージ"

