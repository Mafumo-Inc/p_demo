#!/bin/bash

# エージェントの進捗をリアルタイムで監視するスクリプト
# 使用例: bash scripts/watch-agent-progress.sh

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORKTREE_DIR="$PROJECT_ROOT/../p_demo-worktrees"

# クリア
clear

while true; do
  # カーソルを先頭に移動
  tput cup 0 0
  
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ progress.sh
${BLUE}📊 エージェント進捗状況 (リアルタイム監視) - $(date '+%Y-%m-%d %H:%M:%S')${NC}"
  echo ""

  for agent_dir in "$WORKTREE_DIR"/agent-*; do
    if [ -d "$agent_dir" ]; then
      agent_name=$(basename "$agent_dir" | sed 's/agent-//' | sed 's/-[0-9]*$//')
      log_file="$agent_dir/.agent-${agent_name}.log"
      
      echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
      echo -e "${BLUE}🤖 ${agent_name}${NC}"
      
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
        if [ $log_lines -gt 0 ]; then
          echo -e "  ログ: ${GREEN}${log_size}${NC} (${log_lines}行)"
        else
          echo -e "  ログ: ${YELLOW}${log_size}${NC} (空)"
        fi
        
        # 最後の5行を表示
        if [ $log_lines -gt 0 ]; then
          echo -e "  最新の出力:"
          tail -5 "$log_file" | sed 's/^/    /' | head -5
        fi
      else
        echo -e "  ログ: ${YELLOW}ファイルが存在しません${NC}"
      fi
      
      # 変更ファイル数
      (
        cd "$agent_dir" 2>/dev/null
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          changed_files=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
          if [ "$changed_files" -gt 0 ]; then
            echo -e "  変更ファイル: ${GREEN}${changed_files}件${NC}"
            # 変更されたファイルのリスト（最大5件）
            echo -e "  変更されたファイル:"
            git status --porcelain 2>/dev/null | head -5 | sed 's/^/    /' | head -5
          else
            echo -e "  変更ファイル: ${YELLOW}なし${NC}"
          fi
        else
          echo -e "  変更ファイル: ${YELLOW}Gitリポジトリではありません${NC}"
        fi
      )
      
      echo ""
    fi
  done
  
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}💡 Ctrl+C で終了${NC}"
  
  # 3秒待機
  sleep 3
done

