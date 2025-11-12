#!/bin/bash

# ターミナルから直接Claude Code / Codexにログインするセットアップスクリプト
# Claude Codeは「Pro/Maxログイン運用」と「APIキー運用」の2択に対応

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
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}1. Codexのログイン状態を確認中...${NC}"
if codex login status 2>&1 | grep -q "logged in"; then
  echo -e "${GREEN}✅ Codexはログイン済みです${NC}"
  echo -e "${BLUE}   💡 CodexはCLIログイン方式で、Cursorにも効きます${NC}"
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

# Claude Codeの認証方式を選択
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}2. Claude Codeの認証方式を選択${NC}"
echo ""
echo -e "${YELLOW}Claude Codeには2つの認証方式があります:${NC}"
echo ""
echo -e "${GREEN}方式A: Pro/Maxログイン運用（推奨）${NC}"
echo -e "   ✅ API課金ゼロ（Pro/Maxの割当を使用）"
echo -e "   ✅ 長時間・高並列運用が可能"
echo -e "   ✅ ターミナルでの利用に最適"
echo -e "   ⚠️  Cursorでは使用不可（Cursorはログイン状態を読みにいかない）"
echo ""
echo -e "${GREEN}方式B: APIキー運用${NC}"
echo -e "   ✅ API課金あり（使用量に応じて課金）"
echo -e "   ✅ Cursorでも使用可能（BYOキー）"
echo -e "   ⚠️  Agent/Editなど一部機能はBYO非対応の可能性"
echo ""
echo -e "${YELLOW}💡 推奨: ターミナルでは方式A（Pro/Maxログイン）、Cursorでは方式B（APIキー）${NC}"
echo ""

read -p "Claude Codeの認証方式を選択してください (A: Pro/Maxログイン, B: APIキー, S: スキップ): " -n 1 -r
echo
claude_mode=$REPLY

if [[ $claude_mode =~ ^[Aa]$ ]]; then
  # 方式A: Pro/Maxログイン運用
  echo -e "${BLUE}方式A: Pro/Maxログイン運用をセットアップします${NC}"
  echo ""
  echo -e "${YELLOW}⚠️  重要な注意事項:${NC}"
  echo -e "   - ConsoleのAPI資格情報は${RED}入れない${NC}でください"
  echo -e "   - Pro/Maxのアカウント認証のみを行います"
  echo -e "   - これによりAPI課金を避けてPro/Maxの割当でCLIが動きます"
  echo ""
  read -p "続行しますか？ (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}既存のログイン状態をクリア中...${NC}"
    claude logout 2>/dev/null || echo "ログアウト済みまたはエラー（続行）"
    
    echo -e "${BLUE}Pro/Maxアカウントでログイン中...${NC}"
    echo -e "${YELLOW}💡 ブラウザが開きます。Pro/Maxアカウントでログインしてください${NC}"
    echo -e "${YELLOW}💡 ${RED}API資格情報は入力しない${NC}でください${NC}"
    claude login
    
    # 環境変数をクリア（APIキーが設定されている場合）
    if [ -n "$ANTHROPIC_API_KEY" ]; then
      echo -e "${YELLOW}⚠️  ANTHROPIC_API_KEYが設定されています${NC}"
      echo -e "${YELLOW}   Pro/Maxログイン運用では、この環境変数を${RED}削除${NC}することを推奨します${NC}"
      read -p "ANTHROPIC_API_KEYを削除しますか？ (y/n): " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        # ~/.zshrcからANTHROPIC_API_KEYを削除
        sed -i.bak '/export ANTHROPIC_API_KEY/d' ~/.zshrc 2>/dev/null || true
        unset ANTHROPIC_API_KEY
        echo -e "${GREEN}✅ ANTHROPIC_API_KEYを削除しました${NC}"
      fi
    fi
    
    echo -e "${GREEN}✅ Pro/Maxログイン運用のセットアップが完了しました${NC}"
  fi
  
elif [[ $claude_mode =~ ^[Bb]$ ]]; then
  # 方式B: APIキー運用
  echo -e "${BLUE}方式B: APIキー運用をセットアップします${NC}"
  echo ""
  echo -e "${YELLOW}⚠️  重要な注意事項:${NC}"
  echo -e "   - APIキーを使用すると、使用量に応じて課金されます"
  echo -e "   - Cursorでも使用可能です（BYOキー）"
  echo -e "   - Agent/Editなど一部機能はBYO非対応の可能性があります"
  echo ""
  
  # 現在のAPIキー状態を確認
  if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo -e "${GREEN}✅ ANTHROPIC_API_KEY環境変数が設定されています${NC}"
    echo -e "${BLUE}   現在のキー: ${ANTHROPIC_API_KEY:0:10}...${NC}"
    read -p "新しいAPIキーを設定しますか？ (y/n): " -n 1 -r
    echo
  else
    echo -e "${YELLOW}⚠️  ANTHROPIC_API_KEY環境変数が設定されていません${NC}"
    read -p "APIキーを設定しますか？ (y/n): " -n 1 -r
    echo
  fi
  
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Anthropic APIキーの取得方法:${NC}"
    echo -e "   1. https://console.anthropic.com/ にアクセス"
    echo -e "   2. API Keys セクションで新しいキーを作成"
    echo -e "   3. キーをコピー"
    echo ""
    read -p "Anthropic APIキーを入力してください: " api_key
    if [ -n "$api_key" ]; then
      # ~/.zshrcに追加
      # 既存のANTHROPIC_API_KEYを削除
      sed -i.bak '/export ANTHROPIC_API_KEY/d' ~/.zshrc 2>/dev/null || true
      # 新しいキーを追加
      echo "export ANTHROPIC_API_KEY='$api_key'" >> ~/.zshrc
      export ANTHROPIC_API_KEY="$api_key"
      echo -e "${GREEN}✅ APIキーを設定しました（~/.zshrcに追加済み）${NC}"
      echo -e "${YELLOW}💡 新しいターミナルでは自動的に読み込まれます${NC}"
      echo -e "${YELLOW}💡 現在のターミナルでは 'source ~/.zshrc' を実行してください${NC}"
    fi
  fi
  
  # Pro/Maxログインをログアウト（APIキー優先）
  echo -e "${BLUE}Pro/Maxログイン状態を確認中...${NC}"
  if claude logout 2>&1 | grep -q "logged out"; then
    echo -e "${GREEN}✅ Pro/Maxログインをログアウトしました（APIキー優先）${NC}"
  else
    echo -e "${BLUE}   Pro/Maxログインは既にログアウト済みまたは未ログイン${NC}"
  fi
  
  echo -e "${GREEN}✅ APIキー運用のセットアップが完了しました${NC}"
fi

echo ""

# 認証テスト
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}3. 認証テストを実行中...${NC}"
echo ""

# Codexテスト
echo -e "${BLUE}   Codexテスト:${NC}"
if echo "test" | codex exec 2>&1 | head -1 | grep -q "Codex"; then
  echo -e "${GREEN}   ✅ Codexは正常に動作しています${NC}"
else
  echo -e "${YELLOW}   ⚠️  Codexのテストに失敗しました${NC}"
fi

# Claudeテスト
echo -e "${BLUE}   Claudeテスト:${NC}"
if echo "test" | claude --print --model sonnet 2>&1 | head -1 | grep -q -E "(test|こんにちは|hello|Test)"; then
  echo -e "${GREEN}   ✅ Claudeは正常に動作しています${NC}"
  if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo -e "${BLUE}   💡 APIキー運用モードで動作中${NC}"
  else
    echo -e "${BLUE}   💡 Pro/Maxログイン運用モードで動作中${NC}"
  fi
else
  echo -e "${YELLOW}   ⚠️  Claudeのテストに失敗しました${NC}"
  if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo -e "${YELLOW}   💡 Pro/Maxログインが正しく行われているか確認してください${NC}"
  else
    echo -e "${YELLOW}   💡 ANTHROPIC_API_KEYが正しく設定されているか確認してください${NC}"
  fi
fi

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ セットアップ完了！${NC}"
echo ""
echo -e "${BLUE}📝 重要な注意事項:${NC}"
echo ""
echo -e "${YELLOW}1. Cursorとの関係:${NC}"
echo -e "   - CursorはClaude Codeのログイン状態を${RED}読みにいきません${NC}"
echo -e "   - CursorでClaudeを使う場合は${GREEN}APIキー（BYO）${NC}を設定する必要があります"
echo -e "   - Agent/Editなど一部機能はBYO非対応の可能性があります"
echo ""
echo -e "${YELLOW}2. 推奨ワークフロー:${NC}"
echo -e "   - ${GREEN}ターミナル: Claude Code（Pro/MaxログインまたはAPI運用）とCodexで並列実行${NC}"
echo -e "   - ${GREEN}Cursor: レビュー・差分比較・軽作業に限定${NC}"
echo ""
echo -e "${YELLOW}3. 次のステップ:${NC}"
echo -e "   1. 新しいターミナルを開くか、'source ~/.zshrc' を実行"
echo -e "   2. 'npm run agent:run' でエージェントを実行"
echo -e "   3. ターミナルから直接あなたのアカウントで実行されます"
echo ""
