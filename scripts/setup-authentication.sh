#!/bin/bash

# ターミナルから直接Claude Code / Codexにログインするセットアップスクリプト
# Claude Codeは「Pro/Maxログイン運用」と「APIキー運用」の両方をサポート

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
    echo -e "${BLUE}   Codexログインを開始します...${NC}"
    echo -e "${YELLOW}   💡 ブラウザが開きます。ログイン後、このターミナルは自動的に戻ります${NC}"
    # 非対話モードでログイン（ブラウザが開く）
    # stdinを切って、バックグラウンドで実行
    (
      codex login </dev/null >/dev/null 2>&1 &
      codex_login_pid=$!
      sleep 15
      kill -INT $codex_login_pid >/dev/null 2>&1 || true
      wait $codex_login_pid 2>/dev/null || true
    ) &
    wait $! 2>/dev/null || true
    echo -e "${GREEN}   ✅ Codexログイン処理が完了しました${NC}"
  fi
fi

echo ""

# Claude Codeの認証方式を設定
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}2. Claude Codeの認証方式を設定${NC}"
echo ""
echo -e "${YELLOW}Claude Codeには2つの認証方式があります:${NC}"
echo ""
echo -e "${GREEN}方式A: Pro/Maxログイン運用（推奨・ターミナル用）${NC}"
echo -e "   ✅ API課金ゼロ（Pro/Maxの割当を使用）"
echo -e "   ✅ 長時間・高並列運用が可能"
echo -e "   ✅ ターミナルでの利用に最適"
echo -e "   ⚠️  Cursorでは使用不可（Cursorはログイン状態を読みにいかない）"
echo ""
echo -e "${GREEN}方式B: APIキー運用（Cursor用）${NC}"
echo -e "   ✅ API課金あり（使用量に応じて課金）"
echo -e "   ✅ Cursorでも使用可能（BYOキー）"
echo -e "   ⚠️  Agent/Editなど一部機能はBYO非対応の可能性"
echo ""
echo -e "${YELLOW}💡 推奨: ターミナルでは方式A（Pro/Maxログイン）、Cursorでは方式B（APIキー）${NC}"
echo -e "${YELLOW}💡 両方設定することで、ターミナルとCursorの両方で最適に使用できます${NC}"
echo ""

# 方式A: Pro/Maxログイン運用
read -p "方式A: Pro/Maxログイン運用をセットアップしますか？ (y/n): " -n 1 -r
echo
setup_pro_max=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
  setup_pro_max=true
fi

# 方式B: APIキー運用
read -p "方式B: APIキー運用をセットアップしますか？ (y/n): " -n 1 -r
echo
setup_api_key=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
  setup_api_key=true
fi

# 方式A: Pro/Maxログイン運用
if [ "$setup_pro_max" = true ]; then
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}方式A: Pro/Maxログイン運用をセットアップします${NC}"
  echo ""
  echo -e "${YELLOW}⚠️  重要な注意事項:${NC}"
  echo -e "   - ConsoleのAPI資格情報は${RED}入れない${NC}でください"
  echo -e "   - Pro/Maxのアカウント認証のみを行います"
  echo -e "   - これによりAPI課金を避けてPro/Maxの割当でCLIが動きます"
  echo -e "   - ブラウザが開きます。Pro/Maxアカウントでログインしてください"
  echo ""
  read -p "続行しますか？ (y/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}既存のログイン状態をクリア中...${NC}"
    claude logout >/dev/null 2>&1 || echo -e "${YELLOW}   ログアウト済みまたはエラー（続行）${NC}"
    
    echo -e "${BLUE}Pro/Maxアカウントでログイン中...${NC}"
    echo -e "${YELLOW}💡 ブラウザが開きます。Pro/Maxアカウントでログインしてください${NC}"
    echo -e "${YELLOW}💡 ${RED}API資格情報は入力しない${NC}でください${NC}"
    echo -e "${YELLOW}💡 ログイン後、ブラウザで完了を確認してください${NC}"
    echo ""
    
    # 非対話モードでログイン（対話モードに入らないようにする）
    echo -e "${BLUE}   ログイン処理を開始します...${NC}"
    echo -e "${YELLOW}   💡 この処理は自動的に終了します（対話モードに入りません）${NC}"
    
    # APIキーを一時的に無効化（Pro/Maxログインを優先）
    original_api_key="$ANTHROPIC_API_KEY"
    unset ANTHROPIC_API_KEY
    
    # 非対話モードでログインを実行
    # バックグラウンドで実行し、タイムアウトを設定
    (
      # stdinを切って実行（対話モードに入らないようにする）
      # 標準出力と標準エラー出力を/dev/nullにリダイレクト（対話プロンプトを抑制）
      claude login </dev/null >/dev/null 2>&1 &
      claude_login_pid=$!
      
      # 60秒でタイムアウト（ブラウザでログインする時間を確保）
      sleep 60
      
      # プロセスがまだ生きている場合は終了
      if kill -0 $claude_login_pid 2>/dev/null; then
        kill -INT $claude_login_pid >/dev/null 2>&1 || true
        sleep 1
        kill -TERM $claude_login_pid >/dev/null 2>&1 || true
      fi
      wait $claude_login_pid 2>/dev/null || true
    ) &
    login_pid=$!
    
    # ログイン処理の完了を待つ（最大65秒）
    echo -e "${BLUE}   ログイン処理中...（ブラウザでログインを完了してください）${NC}"
    echo -e "${YELLOW}   💡 このターミナルは自動的に戻ります（最大60秒）${NC}"
    wait $login_pid 2>/dev/null || true
    
    # APIキーを復元（設定されていた場合）
    if [ -n "$original_api_key" ]; then
      export ANTHROPIC_API_KEY="$original_api_key"
    fi
    
    echo ""
    echo -e "${GREEN}✅ Pro/Maxログイン処理が完了しました${NC}"
    echo -e "${YELLOW}💡 ブラウザでログインが完了していれば、ターミナルから使用可能です${NC}"
    
    # ログイン状態を確認（APIキーを一時的に無効化）
    unset ANTHROPIC_API_KEY
    if claude whoami 2>&1 | grep -q -E "(masafumikikuchi|logged in|authenticated)"; then
      echo -e "${GREEN}✅ Pro/Maxログイン状態を確認しました${NC}"
      claude whoami
    else
      echo -e "${YELLOW}⚠️  Pro/Maxログイン状態が確認できません${NC}"
      echo -e "${YELLOW}   💡 ブラウザでログインが完了していない可能性があります${NC}"
      echo -e "${YELLOW}   💡 手動で 'claude login' を実行してください${NC}"
    fi
    
    # APIキーを復元（設定されていた場合）
    if [ -n "$original_api_key" ]; then
      export ANTHROPIC_API_KEY="$original_api_key"
    fi
  fi
fi

echo ""

# 方式B: APIキー運用
if [ "$setup_api_key" = true ]; then
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
    echo -e "${BLUE}   現在のキー: ${ANTHROPIC_API_KEY:0:15}...${NC}"
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
  
  echo -e "${GREEN}✅ APIキー運用のセットアップが完了しました${NC}"
fi

echo ""

# 認証方式の確認
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}3. 認証方式の確認${NC}"
echo ""

# Pro/Maxログイン状態の確認
echo -e "${BLUE}   Pro/Maxログイン状態:${NC}"
claude_whoami_output=$(claude whoami 2>&1)
if echo "$claude_whoami_output" | grep -q -E "(masafumikikuchi|logged in|authenticated)"; then
  echo -e "${GREEN}   ✅ Pro/Maxログイン済み${NC}"
  echo -e "${BLUE}      ユーザー: $(echo "$claude_whoami_output" | head -1)${NC}"
elif [ -n "$ANTHROPIC_API_KEY" ]; then
  echo -e "${YELLOW}   ⚠️  Pro/Maxログイン状態が確認できません（APIキーが設定されているため）${NC}"
  echo -e "${YELLOW}   💡 APIキーが優先されるため、Pro/Maxログインは使用されません${NC}"
  echo -e "${YELLOW}   💡 ターミナルでPro/Maxログインを使う場合は、一時的にAPIキーをunsetしてください${NC}"
else
  echo -e "${YELLOW}   ⚠️  Pro/Maxログイン状態が確認できません${NC}"
  echo -e "${YELLOW}   💡 'claude login' を手動で実行してください${NC}"
fi

# APIキー状態の確認
echo -e "${BLUE}   APIキー状態:${NC}"
if [ -n "$ANTHROPIC_API_KEY" ]; then
  echo -e "${GREEN}   ✅ APIキーが設定されています${NC}"
  echo -e "${BLUE}      キー: ${ANTHROPIC_API_KEY:0:15}...${NC}"
  echo -e "${YELLOW}   💡 この状態では、ターミナルでもAPIキーが使用されます${NC}"
  echo -e "${YELLOW}   💡 ターミナルでPro/Maxログインを使う場合は、一時的に 'unset ANTHROPIC_API_KEY' を実行${NC}"
else
  echo -e "${YELLOW}   ⚠️  APIキーが設定されていません${NC}"
  echo -e "${YELLOW}   💡 CursorでClaudeを使う場合は、APIキーを設定してください${NC}"
fi

echo ""
echo -e "${YELLOW}💡 両方設定する場合の使い分け:${NC}"
if [ "$setup_pro_max" = true ] && [ "$setup_api_key" = true ]; then
  echo -e "${GREEN}   ✅ 両方設定済み${NC}"
  echo -e "${BLUE}   - ターミナルでPro/Maxログインを使う: 'unset ANTHROPIC_API_KEY' を実行${NC}"
  echo -e "${BLUE}   - ターミナルでAPIキーを使う: ANTHROPIC_API_KEYが設定されたまま${NC}"
  echo -e "${BLUE}   - CursorでAPIキーを使う: ANTHROPIC_API_KEYが設定されたまま（CursorはAPIキーを読みます）${NC}"
elif [ "$setup_pro_max" = true ]; then
  echo -e "${GREEN}   ✅ Pro/Maxログインのみ設定済み${NC}"
  echo -e "${YELLOW}   ⚠️  CursorでClaudeを使う場合は、APIキーを設定してください${NC}"
elif [ "$setup_api_key" = true ]; then
  echo -e "${GREEN}   ✅ APIキーのみ設定済み${NC}"
  echo -e "${YELLOW}   ⚠️  ターミナルでPro/Maxログインを使う場合は、'claude login' を実行してください${NC}"
else
  echo -e "${YELLOW}   ⚠️  認証方式が設定されていません${NC}"
fi

echo ""

# 認証テスト
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}4. 認証テストを実行中...${NC}"
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
claude_test_result=$(echo "test" | claude --print --model sonnet 2>&1 | head -1)
if echo "$claude_test_result" | grep -q -E "(test|こんにちは|hello|Test|現在)"; then
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
    echo -e "${YELLOW}   💡 手動で 'claude login' を実行してください${NC}"
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
echo -e "${YELLOW}3. 認証方式の使い分け:${NC}"
if [ "$setup_pro_max" = true ] && [ "$setup_api_key" = true ]; then
  echo -e "   - ${GREEN}Pro/Maxログイン: ターミナルでの並列実行（API課金ゼロ）${NC}"
  echo -e "   - ${GREEN}APIキー: Cursorでの使用${NC}"
  echo -e "   - ${YELLOW}💡 両方設定済みです。ターミナルではPro/Maxログイン、CursorではAPIキーを使用します${NC}"
elif [ "$setup_pro_max" = true ]; then
  echo -e "   - ${GREEN}Pro/Maxログイン: ターミナルでの並列実行（API課金ゼロ）${NC}"
  echo -e "   - ${YELLOW}⚠️  CursorでClaudeを使う場合は、APIキーを設定してください${NC}"
elif [ "$setup_api_key" = true ]; then
  echo -e "   - ${GREEN}APIキー: ターミナルとCursorの両方で使用可能${NC}"
  echo -e "   - ${YELLOW}⚠️  API課金が発生します${NC}"
else
  echo -e "   - ${YELLOW}⚠️  認証方式が設定されていません${NC}"
  echo -e "   - ${YELLOW}💡 ターミナルではPro/Maxログイン、CursorではAPIキーを推奨します${NC}"
fi
echo ""
echo -e "${YELLOW}4. 次のステップ:${NC}"
echo -e "   1. 新しいターミナルを開くか、'source ~/.zshrc' を実行"
echo -e "   2. 'npm run agent:run' でエージェントを実行"
echo -e "   3. ターミナルから直接あなたのアカウントで実行されます"
echo ""
