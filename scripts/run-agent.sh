#!/bin/bash

# エージェントを個別に実行するスクリプト（worktreeディレクトリからでも実行可能）
# 使用例: bash scripts/run-agent.sh backend

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
  echo -e "${YELLOW}   npm run agent:run:$1${NC}"
  echo -e "${YELLOW}   または、まず 'npm run agent:setup' を実行してください${NC}"
  exit 1
fi

# プロジェクトルートディレクトリに移動
cd "$PROJECT_ROOT"

# メインプロジェクトのrun-agents.shを実行
exec "$PROJECT_ROOT/scripts/run-agents.sh" "$@"

