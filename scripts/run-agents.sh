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
# スクリプトの場所から相対的にプロジェクトルートを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 現在のディレクトリがworktreeディレクトリの場合、メインプロジェクトを探す
CURRENT_DIR="$(pwd)"
if [[ "$CURRENT_DIR" == *"p_demo-worktrees"* ]]; then
  # worktreeディレクトリからメインプロジェクトを探す
  PARENT_DIR="$(cd "$CURRENT_DIR/../.." && pwd)"
  if [ -f "$PARENT_DIR/.agents/agent-config.json" ]; then
    PROJECT_ROOT="$PARENT_DIR"
  fi
fi

# エージェント設定ファイルを読み込み
AGENT_CONFIG="$PROJECT_ROOT/.agents/agent-config.json"

# 設定ファイルが見つからない場合、エラーを表示
if [ ! -f "$AGENT_CONFIG" ]; then
  echo -e "${RED}❌ エージェント設定ファイルが見つかりません: $AGENT_CONFIG${NC}"
  echo -e "${YELLOW}💡 メインプロジェクトディレクトリから実行してください:${NC}"
  echo -e "${YELLOW}   cd /Users/masafumikikuchi/Dev/p_demo${NC}"
  echo -e "${YELLOW}   npm run agent:run:backend${NC}"
  echo -e "${YELLOW}   または、まず 'npm run agent:setup' を実行してください${NC}"
  exit 1
fi

# プロジェクトルートディレクトリに移動
cd "$PROJECT_ROOT"

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

  worktree_path_raw=$(echo "$agent_info" | jq -r '.worktree_path')
  model_type=$(echo "$agent_info" | jq -r '.model_type')
  model=$(echo "$agent_info" | jq -r '.model')
  prompt_template=$(echo "$agent_info" | jq -r '.prompt_template')
  role=$(echo "$agent_info" | jq -r '.role')

  # worktree_pathを絶対パスに正規化（`..` や `.` を解決）
  if [[ "$worktree_path_raw" = /* ]]; then
    # 既に絶対パスの場合、正規化
    worktree_path="$(cd "$(dirname "$worktree_path_raw")" 2>/dev/null && cd "$(basename "$worktree_path_raw")" 2>/dev/null && pwd)"
    if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
      # 正規化に失敗した場合、元のパスを使用
      worktree_path="$worktree_path_raw"
    fi
  elif [[ "$worktree_path_raw" = ../* ]]; then
    # `../` で始まる場合、プロジェクトルートの親ディレクトリから解決
    relative_path=$(echo "$worktree_path_raw" | sed 's|^\.\./||')
    worktree_path="$(cd "$PROJECT_ROOT/.." 2>/dev/null && cd "$relative_path" 2>/dev/null && pwd)"
    if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
      echo -e "${RED}❌ Worktreeが見つかりません: $worktree_path_raw${NC}" >&2
      continue
    fi
  else
    # 相対パスの場合、プロジェクトルートから解決
    worktree_path="$(cd "$PROJECT_ROOT" 2>/dev/null && cd "$worktree_path_raw" 2>/dev/null && pwd)"
    if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
      echo -e "${RED}❌ Worktreeが見つかりません: $worktree_path_raw${NC}" >&2
      continue
    fi
  fi
  
  # worktreeが存在するか確認
  if [ ! -d "$worktree_path" ]; then
    echo -e "${RED}❌ Worktreeが見つかりません: $worktree_path (元: $worktree_path_raw)${NC}" >&2
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
  
  # 絶対パスでログファイルと終了コードファイルのパスを定義
  log_file="$worktree_path/.agent-${agent_name}.log"
  exitcode_file="$worktree_path/.agent-${agent_name}.exitcode"
  prompt_temp_file="$worktree_path/.agent-${agent_name}.prompt.txt"
  
  # ログファイルと終了コードファイルを初期化（サブシェル外で実行）
  > "$log_file" 2>&1
  echo "開始時刻: $(date)" >> "$log_file" 2>&1
  echo "エージェント: ${agent_name}" >> "$log_file" 2>&1
  echo "モデル: ${model} (${model_type})" >> "$log_file" 2>&1
  echo "Worktree: ${worktree_path}" >> "$log_file" 2>&1
  echo "1" > "$exitcode_file" 2>&1  # デフォルトはエラー
  
  # モデルタイプに応じてプロンプトを準備（サブシェル外で実行）
  if [ "$model_type" == "claude-code-max" ]; then
    # Claude Code MAX 用のプロンプトを準備
    if ! command -v claude &> /dev/null; then
      echo -e "${RED}❌ claude コマンドが見つかりません${NC}" >&2
      echo -e "${YELLOW}💡 Claude Code MAXがインストールされているか確認してください${NC}" >&2
      echo "1" > "$exitcode_file"
      continue
    fi
    
    # モデル名をエイリアスに変換（sonnet-4.5 -> sonnet, opus -> opus）
    model_alias=$(echo "$model" | sed 's/claude-//' | sed 's/-4\.5//' | sed 's/-4-5//')
    
    # Pro/Maxログイン運用を優先（APIキーを一時的に無効化）
    use_pro_max_login=false
    if [ -z "$ANTHROPIC_API_KEY" ]; then
      use_pro_max_login=true
    else
      original_api_key="$ANTHROPIC_API_KEY"
      unset ANTHROPIC_API_KEY
      if claude whoami 2>&1 | grep -q -E "(masafumikikuchi|logged in|authenticated)"; then
        use_pro_max_login=true
      fi
      export ANTHROPIC_API_KEY="$original_api_key"
    fi
    
    # プロンプトを準備
    if [ -n "$prompt_file" ] && [ -f "$prompt_file" ]; then
      prompt_content=$(cat "$prompt_file")
      if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
        requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
        requirements_size=$(echo "$requirements_content" | wc -c)
        if [ $requirements_size -gt 16000 ]; then
          requirements_content=$(head -150 "$PROJECT_ROOT/REQUIREMENTS.md")
          requirements_content="${requirements_content}

---

**注意: 上記は要件の概要です。詳細な実装要件は省略しています。**
**このプロジェクトはデモ作成用です。UIデモのみを実装してください。**"
        fi
        prompt_content="${prompt_content}

---

## REQUIREMENTS.mdの内容（概要）

以下の要件は**UIデモの要件**として理解してください。バックエンド実装は一切不要です。

${requirements_content}

---

**重要: このプロジェクトはデモ作成用です。**
- バックエンド実装は一切不要
- フロントエンドのみで完結
- 全てダミーデータを使用
- UIデモのみを実装してください"
      fi
    else
      prompt_content="REQUIREMENTS.mdを読み込み、${role}として作業してください。\n\n⚠️ 重要: このプロジェクトはデモ作成用です。バックエンド実装は一切不要です。フロントエンドのみで完結し、全てダミーデータを使用してください。"
      if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
        requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
        requirements_size=$(echo "$requirements_content" | wc -c)
        if [ $requirements_size -gt 16000 ]; then
          requirements_content=$(head -150 "$PROJECT_ROOT/REQUIREMENTS.md")
          requirements_content="${requirements_content}

---

**注意: 上記は要件の概要です。詳細な実装要件は省略しています。**
**このプロジェクトはデモ作成用です。UIデモのみを実装してください。**"
        fi
        prompt_content="${prompt_content}

---

## REQUIREMENTS.mdの内容（概要）

以下の要件は**UIデモの要件**として理解してください。バックエンド実装は一切不要です。

${requirements_content}

---

**重要: このプロジェクトはデモ作成用です。**
- バックエンド実装は一切不要
- フロントエンドのみで完結
- 全てダミーデータを使用
- UIデモのみを実装してください"
      fi
    fi
    
    # プロンプトサイズをログに記録
    prompt_size=$(echo "$prompt_content" | wc -c)
    echo "プロンプトサイズ: ${prompt_size} bytes" >> "$log_file"
    echo "プロンプトサイズ: ${prompt_size} bytes" >&2
    
    # プロンプトを一時ファイルに保存
    echo "$prompt_content" > "$prompt_temp_file"
    echo "プロンプトファイル作成: $prompt_temp_file" >> "$log_file"
    
    # Claudeコマンドをバックグラウンドで実行
    # 注意: ログファイルと終了コードファイルのパスは絶対パスで統一
    (
      cd "$worktree_path" || exit 1
      echo "Claudeコマンド実行開始: $(date)" >> "$log_file" 2>&1
      echo "作業ディレクトリ: $(pwd)" >> "$log_file" 2>&1
      echo "プロンプトファイル: $prompt_temp_file" >> "$log_file" 2>&1
      
      if [ "$use_pro_max_login" = true ] && [ -n "$ANTHROPIC_API_KEY" ]; then
        unset ANTHROPIC_API_KEY
        echo "Pro/Maxログインを使用" >> "$log_file" 2>&1
        if [ -f "$prompt_temp_file" ]; then
          cat "$prompt_temp_file" | claude --print --model "$model_alias" >> "$log_file" 2>&1
          exit_code=$?
        else
          echo "エラー: プロンプトファイルが見つかりません: $prompt_temp_file" >> "$log_file" 2>&1
          exit_code=1
        fi
      else
        echo "APIキーまたはPro/Maxログインを使用" >> "$log_file" 2>&1
        if [ -f "$prompt_temp_file" ]; then
          cat "$prompt_temp_file" | claude --print --model "$model_alias" >> "$log_file" 2>&1
          exit_code=$?
        else
          echo "エラー: プロンプトファイルが見つかりません: $prompt_temp_file" >> "$log_file" 2>&1
          exit_code=1
        fi
      fi
      
      echo "Claudeコマンド実行終了: $(date) (終了コード: $exit_code)" >> "$log_file" 2>&1
      echo "$exit_code" > "$exitcode_file" 2>&1
    ) &
    claude_pid=$!
    
    # PIDを記録
    echo "$claude_pid" > "$worktree_path/.agent-${agent_name}.pid" 2>&1
    echo "Claudeプロセス開始: PID=$claude_pid" >> "$log_file" 2>&1
    echo "Claudeプロセス開始: PID=$claude_pid" >&2
    
  elif [ "$model_type" == "codex" ]; then
    # Codex用のプロンプトを準備（サブシェル外で実行）
    if ! command -v codex &> /dev/null; then
      echo -e "${RED}❌ codex コマンドが見つかりません${NC}" >&2
      echo -e "${YELLOW}💡 Codexがインストールされているか確認してください${NC}" >&2
      echo "1" > "$exitcode_file"
      continue
    fi
    
    # プロンプトを準備
    if [ -n "$prompt_file" ] && [ -f "$prompt_file" ]; then
      prompt_content=$(cat "$prompt_file")
      if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
        requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
        requirements_size=$(echo "$requirements_content" | wc -c)
        if [ $requirements_size -gt 16000 ]; then
          requirements_content=$(head -150 "$PROJECT_ROOT/REQUIREMENTS.md")
          requirements_content="${requirements_content}

---

**注意: 上記は要件の概要です。詳細な実装要件は省略しています。**
**このプロジェクトはデモ作成用です。UIデモのみを実装してください。**"
        fi
        prompt_content="${prompt_content}

---

## REQUIREMENTS.mdの内容（概要）

以下の要件は**UIデモの要件**として理解してください。バックエンド実装は一切不要です。

${requirements_content}

---

**重要: このプロジェクトはデモ作成用です。**
- バックエンド実装は一切不要
- フロントエンドのみで完結
- 全てダミーデータを使用
- UIデモのみを実装してください"
      fi
    else
      prompt_content="REQUIREMENTS.mdを読み込み、${role}として作業してください。\n\n⚠️ 重要: このプロジェクトはデモ作成用です。バックエンド実装は一切不要です。フロントエンドのみで完結し、全てダミーデータを使用してください。"
      if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
        requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
        requirements_size=$(echo "$requirements_content" | wc -c)
        if [ $requirements_size -gt 16000 ]; then
          requirements_content=$(head -150 "$PROJECT_ROOT/REQUIREMENTS.md")
          requirements_content="${requirements_content}

---

**注意: 上記は要件の概要です。詳細な実装要件は省略しています。**
**このプロジェクトはデモ作成用です。UIデモのみを実装してください。**"
        fi
        prompt_content="${prompt_content}

---

## REQUIREMENTS.mdの内容（概要）

以下の要件は**UIデモの要件**として理解してください。バックエンド実装は一切不要です。

${requirements_content}

---

**重要: このプロジェクトはデモ作成用です。**
- バックエンド実装は一切不要
- フロントエンドのみで完結
- 全てダミーデータを使用
- UIデモのみを実装してください"
      fi
    fi
    
    # プロンプトを一時ファイルに保存
    echo "$prompt_content" > "$prompt_temp_file"
    echo "プロンプトファイル作成: $prompt_temp_file" >> "$log_file"
    
    # Codexコマンドをバックグラウンドで実行
    codex_model="$model"
    if [ "$model" == "gpt-4" ]; then
      codex_model="gpt-5-codex"
    fi
    
    (
      cd "$worktree_path" || exit 1
      echo "Codexコマンド実行開始: $(date)" >> "$log_file" 2>&1
      echo "作業ディレクトリ: $(pwd)" >> "$log_file" 2>&1
      echo "プロンプトファイル: $prompt_temp_file" >> "$log_file" 2>&1
      
      if [ -f "$prompt_temp_file" ]; then
        cat "$prompt_temp_file" | codex exec --full-auto --model "$codex_model" >> "$log_file" 2>&1
        exit_code=$?
      else
        echo "エラー: プロンプトファイルが見つかりません: $prompt_temp_file" >> "$log_file" 2>&1
        exit_code=1
      fi
      
      echo "Codexコマンド実行終了: $(date) (終了コード: $exit_code)" >> "$log_file" 2>&1
      echo "$exit_code" > "$exitcode_file" 2>&1
    ) &
    codex_pid=$!
    
    # PIDを記録
    echo "$codex_pid" > "$worktree_path/.agent-${agent_name}.pid" 2>&1
    echo "Codexプロセス開始: PID=$codex_pid" >> "$log_file" 2>&1
    echo "Codexプロセス開始: PID=$codex_pid" >&2
    
    # CodexプロセスのPIDを使用
    claude_pid=$codex_pid
  else
    echo -e "${RED}❌ 不明なモデルタイプ: $model_type${NC}" >&2
    echo "1" > "$exitcode_file"
    continue
  fi
  
  # エージェントプロセスのPIDを記録（メインループで使用）
  PIDS+=($claude_pid)
  AGENT_NAMES+=("$agent_name")
done

# 全てのエージェントの完了を待つ
if [ ${#PIDS[@]} -gt 0 ]; then
  echo ""
  echo -e "${BLUE}⏳ 全エージェントの完了を待っています...${NC}"
  echo ""
  
  for i in "${!PIDS[@]}"; do
    pid=${PIDS[$i]}
    agent_name=${AGENT_NAMES[$i]}
    
    # エージェント情報を取得
    agent_info=$(jq -r ".agents[] | select(.name == \"$agent_name\")" "$AGENT_CONFIG" 2>/dev/null)
    worktree_path_raw=$(echo "$agent_info" | jq -r '.worktree_path')
    
    # worktree_pathを絶対パスに正規化（メインループでも同様に処理）
    if [[ "$worktree_path_raw" = /* ]]; then
      worktree_path="$(cd "$(dirname "$worktree_path_raw")" 2>/dev/null && cd "$(basename "$worktree_path_raw")" 2>/dev/null && pwd)"
      if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
        worktree_path="$worktree_path_raw"
      fi
    elif [[ "$worktree_path_raw" = ../* ]]; then
      relative_path=$(echo "$worktree_path_raw" | sed 's|^\.\./||')
      worktree_path="$(cd "$PROJECT_ROOT/.." 2>/dev/null && cd "$relative_path" 2>/dev/null && pwd)"
      if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
        echo -e "${RED}❌ Worktreeが見つかりません: $worktree_path_raw${NC}" >&2
        continue
      fi
    else
      worktree_path="$(cd "$PROJECT_ROOT" 2>/dev/null && cd "$worktree_path_raw" 2>/dev/null && pwd)"
      if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
        echo -e "${RED}❌ Worktreeが見つかりません: $worktree_path_raw${NC}" >&2
        continue
      fi
    fi
    
    exitcode_file="$worktree_path/.agent-${agent_name}.exitcode"
    log_file="$worktree_path/.agent-${agent_name}.log"
    
    # エージェントの完了を待つ（最大10分）
    timeout_seconds=600
    start_time=$(date +%s)
    
    # ログファイルのサイズを監視して進捗を確認
    last_log_size=0
    no_progress_count=0
    
    while kill -0 $pid 2>/dev/null; do
      current_time=$(date +%s)
      elapsed=$((current_time - start_time))
      
      # ログファイルのサイズを確認（進捗があるかチェック）
      if [ -f "$log_file" ]; then
        current_log_size=$(wc -c < "$log_file" 2>/dev/null || echo "0")
        if [ $current_log_size -eq $last_log_size ]; then
          no_progress_count=$((no_progress_count + 1))
        else
          no_progress_count=0
          last_log_size=$current_log_size
        fi
        
        # 2分間進捗がない場合はタイムアウト
        if [ $no_progress_count -gt 120 ]; then
          kill $pid 2>/dev/null
          echo -e "${YELLOW}⚠️  ${agent_name} がタイムアウトしました（2分間進捗なし）${NC}"
          echo "124" > "$exitcode_file"
          break
        fi
      fi
      
      # タイムアウトチェック（10分）
      if [ $elapsed -gt $timeout_seconds ]; then
        kill $pid 2>/dev/null
        echo -e "${YELLOW}⚠️  ${agent_name} がタイムアウトしました（10分）${NC}"
        echo "124" > "$exitcode_file"
        break
      fi
      
      sleep 2
    done
    
    # プロセスの終了を待つ
    wait $pid 2>/dev/null
    wait_exit_code=$?
    
    # 終了コードを確認
    if [ -f "$exitcode_file" ]; then
      exit_code=$(cat "$exitcode_file" 2>/dev/null || echo "0")
    else
      exit_code=$wait_exit_code
    fi
    
    if [ "$exit_code" -eq 0 ] 2>/dev/null; then
      echo -e "${GREEN}✅ ${agent_name} が正常に完了しました${NC}"
    elif [ "$exit_code" -eq 124 ] 2>/dev/null; then
      echo -e "${YELLOW}⚠️  ${agent_name} がタイムアウトしました${NC}"
    else
      echo -e "${RED}❌ ${agent_name} がエラーで終了しました（終了コード: $exit_code）${NC}"
    fi
  done
fi

echo ""
echo -e "${GREEN}🎉 全エージェントの実行が完了しました！${NC}"
echo ""
echo -e "${BLUE}📝 次のステップ:${NC}"
echo -e "1. 各worktreeの変更を確認: git status"
echo -e "2. 変更をコミット: git add . && git commit -m '...'"
echo -e "3. PRを作成して比較・レビュー"
echo -e "4. 最良案を選択してマージ"
