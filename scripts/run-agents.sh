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

  # ログファイルと終了コードファイルのパスを定義
  log_file="$worktree_path/.agent-${agent_name}.log"
  exitcode_file="$worktree_path/.agent-${agent_name}.exitcode"
  prompt_temp_file="$worktree_path/.agent-${agent_name}.prompt.txt"
  
  # ログファイルを初期化
  > "$log_file"
  echo "1" > "$exitcode_file"  # デフォルトはエラー
  
  # バックグラウンドでエージェントを実行
  (
    cd "$worktree_path"
    
    # モデルタイプに応じてコマンドを実行
    if [ "$model_type" == "claude-code-max" ]; then
      # Claude Code MAX を実行
      if ! command -v claude &> /dev/null; then
        echo -e "${RED}❌ claude コマンドが見つかりません${NC}" >&2
        echo -e "${YELLOW}💡 Claude Code MAXがインストールされているか確認してください${NC}" >&2
        echo "1" > "$exitcode_file"
        exit 1
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
      # 重要: エージェントプロンプトテンプレートを先に読み込んでから、REQUIREMENTS.mdを追加
      # これにより、エージェントは「デモ作成用・バックエンド不要」という指示を先に読む
      if [ -n "$prompt_file" ] && [ -f "$prompt_file" ]; then
        prompt_content=$(cat "$prompt_file")
        # REQUIREMENTS.mdの内容も追加（エージェントプロンプトの後に追加）
        # 重要: REQUIREMENTS.mdが長い場合、最初の200行のみを使用（約8KBに制限）
        if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
          # REQUIREMENTS.mdの最初の200行のみを読み込む（概要、目的、主要機能のみ）
          requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
          # サイズが大きすぎる場合は警告
          requirements_size=$(echo "$requirements_content" | wc -c)
          if [ $requirements_size -gt 16000 ]; then
            # 最初の150行に制限
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
          # REQUIREMENTS.mdの最初の200行のみを読み込む
          requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
          # サイズが大きすぎる場合は警告
          requirements_size=$(echo "$requirements_content" | wc -c)
          if [ $requirements_size -gt 16000 ]; then
            # 最初の150行に制限
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
      
      # Claudeを非対話モードで実行
      # Pro/Maxログイン運用を優先（APIキーを一時的に無効化）
      # デバッグ: プロンプトサイズをログに記録
      prompt_size=$(echo "$prompt_content" | wc -c)
      echo "プロンプトサイズ: ${prompt_size} bytes" >&2
      echo "プロンプトサイズ: ${prompt_size} bytes" >> "$log_file" 2>&1
      
      # プロンプトを一時ファイルに保存（デバッグ用）
      echo "$prompt_content" > "$prompt_temp_file"
      
      # Claudeコマンドを実行（バックグラウンドで実行）
      if [ "$use_pro_max_login" = true ] && [ -n "$ANTHROPIC_API_KEY" ]; then
        # Pro/Maxログインを使用するため、APIキーを一時的に無効化
        unset ANTHROPIC_API_KEY
        cat "$prompt_temp_file" | claude --print --model "$model_alias" >> "$log_file" 2>&1
        exit_code=$?
      else
        # APIキーを使用（またはPro/Maxログインのみ）
        cat "$prompt_temp_file" | claude --print --model "$model_alias" >> "$log_file" 2>&1
        exit_code=$?
      fi
      
      # 終了コードを保存
      echo "$exit_code" > "$exitcode_file"
      
      # エラーチェック
      if [ $exit_code -ne 0 ]; then
        echo -e "${RED}❌ ${agent_name} の実行に失敗しました（終了コード: $exit_code）${NC}" >&2
        echo -e "${YELLOW}ログファイル: $log_file${NC}" >&2
        if [ -s "$log_file" ]; then
          echo -e "${YELLOW}エラー内容:${NC}" >&2
          tail -20 "$log_file" | sed 's/^/  /' >&2
        fi
        echo -e "${YELLOW}💡 認証状態を確認: 'npm run agent:auth' を実行してください${NC}" >&2
        echo -e "${YELLOW}💡 プロンプトファイル: $prompt_temp_file${NC}" >&2
      fi
      
      # 一時ファイルを削除（デバッグ時は残す）
      # rm -f "$prompt_temp_file"
      
    elif [ "$model_type" == "codex" ]; then
      # Codex (OpenAI) を実行
      if ! command -v codex &> /dev/null; then
        echo -e "${RED}❌ codex コマンドが見つかりません${NC}" >&2
        echo -e "${YELLOW}💡 Codexがインストールされているか確認してください${NC}" >&2
        echo "1" > "$exitcode_file"
        exit 1
      fi
      
      # プロンプトを準備
      # 重要: エージェントプロンプトテンプレートを先に読み込んでから、REQUIREMENTS.mdを追加
      # これにより、エージェントは「デモ作成用・バックエンド不要」という指示を先に読む
      if [ -n "$prompt_file" ] && [ -f "$prompt_file" ]; then
        prompt_content=$(cat "$prompt_file")
        # REQUIREMENTS.mdの内容も追加（エージェントプロンプトの後に追加）
        # 重要: REQUIREMENTS.mdが長い場合、最初の200行のみを使用（約8KBに制限）
        if [ -f "$PROJECT_ROOT/REQUIREMENTS.md" ]; then
          # REQUIREMENTS.mdの最初の200行のみを読み込む（概要、目的、主要機能のみ）
          requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
          # サイズが大きすぎる場合は警告
          requirements_size=$(echo "$requirements_content" | wc -c)
          if [ $requirements_size -gt 16000 ]; then
            # 最初の150行に制限
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
          # REQUIREMENTS.mdの最初の200行のみを読み込む
          requirements_content=$(head -200 "$PROJECT_ROOT/REQUIREMENTS.md")
          # サイズが大きすぎる場合は警告
          requirements_size=$(echo "$requirements_content" | wc -c)
          if [ $requirements_size -gt 16000 ]; then
            # 最初の150行に制限
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
      
      # Codexを実行（--full-autoで非対話モード、--modelでモデル指定）
      # モデル名をcodex形式に変換（gpt-4 -> gpt-5-codex など）
      codex_model="$model"
      if [ "$model" == "gpt-4" ]; then
        codex_model="gpt-5-codex"
      fi
      
      # Codexを実行
      echo "$prompt_content" | codex exec --full-auto --model "$codex_model" > "$log_file" 2>&1
      exit_code=$?
      
      # 終了コードを保存
      echo "$exit_code" > "$exitcode_file"
      
      # エラーチェック
      if [ $exit_code -ne 0 ]; then
        echo -e "${RED}❌ ${agent_name} の実行に失敗しました（終了コード: $exit_code）${NC}" >&2
        echo -e "${YELLOW}ログファイル: $log_file${NC}" >&2
        if [ -s "$log_file" ]; then
          echo -e "${YELLOW}エラー内容:${NC}" >&2
          tail -10 "$log_file" | sed 's/^/  /' >&2
        fi
      fi
      
    else
      echo -e "${RED}❌ 不明なモデルタイプ: $model_type${NC}" >&2
      echo "1" > "$exitcode_file"
      exit 1
    fi
  ) &
  
  PIDS+=($!)
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
    worktree_path=$(echo "$agent_info" | jq -r '.worktree_path')
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
