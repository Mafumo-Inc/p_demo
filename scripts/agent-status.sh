#!/bin/bash

# エージェント状態確認スクリプト

set -e

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
  echo -e "${RED}❌ エージェント設定ファイルが見つかりません${NC}"
  exit 1
fi

echo -e "${BLUE}📊 エージェント状態一覧${NC}"
echo ""

# jqがインストールされているか確認
if ! command -v jq &> /dev/null; then
  echo -e "${YELLOW}⚠️  jqがインストールされていません。簡単な状態表示のみ行います。${NC}"
  echo ""
  
  # jqなしで簡単な表示
  agents=$(cat "$AGENT_CONFIG" | grep -o '"name": "[^"]*"' | cut -d'"' -f4)
  for agent in $agents; do
    echo -e "${GREEN}• ${agent}${NC}"
  done
  exit 0
fi

# 各エージェントの状態を表示
agents_count=$(jq '.agents | length' "$AGENT_CONFIG")

for i in $(seq 0 $((agents_count - 1))); do
  agent_info=$(jq ".agents[$i]" "$AGENT_CONFIG")
  name=$(echo "$agent_info" | jq -r '.name')
  role=$(echo "$agent_info" | jq -r '.role')
  worktree_path=$(echo "$agent_info" | jq -r '.worktree_path')
  model=$(echo "$agent_info" | jq -r '.model')
  model_type=$(echo "$agent_info" | jq -r '.model_type')
  
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}エージェント: ${name}${NC}"
  echo -e "  役割: ${role}"
  echo -e "  モデル: ${model} (${model_type})"
  
  # Worktreeの存在確認
  if [ -d "$worktree_path" ]; then
    echo -e "  Worktree: ${GREEN}✅ 存在${NC}"
    
    # 変更があるか確認
    cd "$worktree_path"
    if [ -n "$(git status --porcelain)" ]; then
      echo -e "  変更: ${YELLOW}⚠️  あり${NC}"
      echo -e "  変更ファイル数: $(git status --porcelain | wc -l | tr -d ' ')"
    else
      echo -e "  変更: ${GREEN}なし${NC}"
    fi
    
    # ブランチ情報
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo -e "  ブランチ: ${branch}"
    
    # ログファイルの確認
    log_file="$worktree_path/.agent-${name}.log"
    if [ -f "$log_file" ]; then
      log_size=$(ls -lh "$log_file" | awk '{print $5}')
      echo -e "  ログ: ${log_file} (${log_size})"
    fi
  else
    echo -e "  Worktree: ${RED}❌ 存在しない${NC}"
  fi
  
  cd "$PROJECT_ROOT"
  echo ""
done

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

