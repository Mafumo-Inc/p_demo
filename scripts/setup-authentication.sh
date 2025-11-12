#!/bin/bash

# ターミナルから直接Claude Code / Codexにログインするセットアップスクリプト

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔐 ターミナル認証セットアップ${NC}"
echo ""

# Codexのログイン状態を確認
echo -e "${YELLOW}1. Codexのログイン状態を確認中...${NC}"
if codex login status 2>&1 | grep -q "logged in"; then
  echo -e "${GREEN}✅ Codexはログイン済みです${NC}"
else
  echo -e "${YELLOW}⚠️  Codexはログインしていません${NC}"
  echo -e "${BLUE}   以下のコマンドでログインしてください:${NC}"
  echo -e "   ${GREEN}codex login${NC}"
  echo ""
  read -p "今すぐログインしますか？ (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    codex login
  fi
fi

echo ""

# Claude Codeの認証状態を確認
echo -e "${YELLOW}2. Claude Codeの認証状態を確認中...${NC}"

# Anthropic APIキーの確認
if [ -n "$ANTHROPIC_API_KEY" ]; then
  echo -e "${GREEN}✅ ANTHROPIC_API_KEY環境変数が設定されています${NC}"
else
  echo -e "${YELLOW}⚠️  ANTHROPIC_API_KEY環境変数が設定されていません${NC}"
  echo -e "${BLUE}   以下の方法で設定できます:${NC}"
  echo ""
  echo -e "   ${GREEN}方法1: 環境変数として設定${NC}"
  echo -e "   export ANTHROPIC_API_KEY='your-api-key'"
  echo ""
  echo -e "   ${GREEN}方法2: ~/.zshrc または ~/.bashrc に追加${NC}"
  echo -e "   echo 'export ANTHROPIC_API_KEY=\"your-api-key\"' >> ~/.zshrc"
  echo -e "   source ~/.zshrc"
  echo ""
  echo -e "   ${GREEN}方法3: .envファイルを使用（プロジェクトローカル）${NC}"
  echo -e "   echo 'ANTHROPIC_API_KEY=your-api-key' > .env.local"
  echo ""
  
  read -p "APIキーを今すぐ設定しますか？ (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Anthropic APIキーを入力してください: " api_key
    if [ -n "$api_key" ]; then
      echo "export ANTHROPIC_API_KEY='$api_key'" >> ~/.zshrc
      export ANTHROPIC_API_KEY="$api_key"
      echo -e "${GREEN}✅ APIキーを設定しました（~/.zshrcに追加済み）${NC}"
      echo -e "${YELLOW}💡 新しいターミナルでは自動的に読み込まれます${NC}"
      echo -e "${YELLOW}💡 現在のターミナルでは 'source ~/.zshrc' を実行してください${NC}"
    fi
  fi
fi

echo ""

# 設定ファイルの確認
echo -e "${YELLOW}3. 設定ファイルの確認中...${NC}"

# Claude設定ディレクトリ
CLAUDE_CONFIG_DIR="$HOME/.anthropic"
if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
  mkdir -p "$CLAUDE_CONFIG_DIR"
  echo -e "${GREEN}✅ Claude設定ディレクトリを作成: $CLAUDE_CONFIG_DIR${NC}"
fi

# Codex設定ファイル
CODEX_CONFIG="$HOME/.codex/config.toml"
if [ -f "$CODEX_CONFIG" ]; then
  echo -e "${GREEN}✅ Codex設定ファイルが存在: $CODEX_CONFIG${NC}"
  echo -e "${BLUE}   現在の設定:${NC}"
  cat "$CODEX_CONFIG" | head -5
else
  echo -e "${YELLOW}⚠️  Codex設定ファイルが見つかりません${NC}"
fi

echo ""

# テスト実行
echo -e "${YELLOW}4. 認証テストを実行中...${NC}"

# Codexテスト
echo -e "${BLUE}   Codexテスト:${NC}"
if echo "test" | codex exec 2>&1 | head -1 | grep -q "Codex"; then
  echo -e "${GREEN}   ✅ Codexは正常に動作しています${NC}"
else
  echo -e "${YELLOW}   ⚠️  Codexのテストに失敗しました${NC}"
fi

# Claudeテスト
echo -e "${BLUE}   Claudeテスト:${NC}"
if echo "test" | claude --print --model sonnet 2>&1 | head -1 | grep -q -E "(test|こんにちは|hello)"; then
  echo -e "${GREEN}   ✅ Claudeは正常に動作しています${NC}"
else
  echo -e "${YELLOW}   ⚠️  Claudeのテストに失敗しました${NC}"
  echo -e "${YELLOW}   💡 ANTHROPIC_API_KEYが正しく設定されているか確認してください${NC}"
fi

echo ""
echo -e "${GREEN}✅ セットアップ完了！${NC}"
echo ""
echo -e "${BLUE}📝 次のステップ:${NC}"
echo -e "1. 新しいターミナルを開くか、'source ~/.zshrc' を実行"
echo -e "2. 'npm run agent:run' でエージェントを実行"
echo -e "3. ターミナルから直接あなたのアカウントで実行されます"

