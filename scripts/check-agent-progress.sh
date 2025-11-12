#!/bin/bash

# エージェントの進捗を確認するスクリプト

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKTREE_DIR="$PROJECT_ROOT/../p_demo-worktrees"

echo -e "${BLUE}📊 エージェント進捗状況${NC}"
echo ""

for agent_dir in "$WORKTREE_DIR"/agent-*; do
  if [ -d "$agent_dir" ]; then
    agent_name=$(basename "$agent_dir" | sed 's/agent-//' | sed 's/-[0-9]*$//')
    log_file="$agent_dir/.agent-${agent_name}.log"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}エージェント: ${agent_name}${NC}"
    
    # プロセス確認
    exit_code_file="$agent_dir/.agent-${agent_name}.exitcode"
    if ps aux | grep -E "(claude|codex)" | grep -v grep | grep -q "$agent_name\|$agent_dir"; then
      echo -e "  状態: ${GREEN}🟢 実行中${NC}"
    elif [ -f "$exit_code_file" ]; then
      exit_code=$(cat "$exit_code_file" 2>/dev/null || echo "N/A")
      if [ "$exit_code" -eq 0 ] 2>/dev/null; then
        echo -e "  状態: ${GREEN}✅ 完了${NC}"
      elif [ "$exit_code" -eq 124 ] 2>/dev/null; then
        echo -e "  状態: ${YELLOW}⚠️  タイムアウト${NC}"
      elif [ "$exit_code" != "N/A" ] 2>/dev/null; then
        echo -e "  状態: ${RED}❌ エラー（終了コード: $exit_code）${NC}"
      else
        echo -e "  状態: ${YELLOW}⚪ 停止中${NC}"
      fi
    else
      echo -e "  状態: ${YELLOW}⚪ 未実行${NC}"
    fi
    
    # ログファイルサイズ
    if [ -f "$log_file" ]; then
      log_size=$(ls -lh "$log_file" | awk '{print $5}')
      log_lines=$(wc -l < "$log_file" 2>/dev/null || echo 0)
      echo -e "  ログ: ${log_size} (${log_lines}行)"
      
      # 最後の数行を表示
      if [ $log_lines -gt 0 ]; then
        echo -e "  最新の出力:"
        tail -3 "$log_file" | sed 's/^/    /'
      fi
    else
      echo -e "  ログ: ${YELLOW}ファイルが存在しません${NC}"
    fi
    
    # 変更ファイル数
    cd "$agent_dir"
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      changed_files=$(git status --porcelain | wc -l | tr -d ' ')
      echo -e "  変更ファイル: ${GREEN}${changed_files}件${NC}"
    else
      echo -e "  変更ファイル: ${YELLOW}なし${NC}"
    fi
    
    echo ""
  fi
done

echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

