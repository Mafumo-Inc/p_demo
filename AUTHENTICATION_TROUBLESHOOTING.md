# 🔧 認証トラブルシューティングガイド

## 🚨 よくある問題と解決方法

### 問題1: `claude login`が対話モードで止まる

**症状:**
- `npm run agent:auth`を実行すると、`claude login`が対話モードに入って止まる
- ターミナルが応答しなくなる

**解決方法:**

1. **即座の対処（現在のターミナルから抜ける）:**
   ```bash
   # Ctrl+C を押す
   # 効かない場合は Ctrl+D を押す
   # それでも戻れない場合は、別ターミナルで以下を実行
   pkill -f '^claude( |$)'
   ```

2. **画面が乱れた場合:**
   ```bash
   # ターミナルをリセット
   reset
   # または
   stty sane
   ```

3. **再発防止（スクリプト修正）:**
   - `scripts/setup-authentication.sh`は既に修正済み
   - `claude login`を非対話モードで実行（`</dev/null`、タイムアウト60秒）
   - 対話モードに入らないように修正済み

### 問題2: Pro/Maxログインが確認できない

**症状:**
- `claude whoami`を実行しても、ログイン状態が確認できない
- APIキーが設定されている場合、Pro/Maxログインが使用されない

**解決方法:**

1. **APIキーを一時的に無効化:**
   ```bash
   # 現在のセッションでのみAPIキーを無効化
   unset ANTHROPIC_API_KEY
   
   # Pro/Maxログイン状態を確認
   claude whoami
   ```

2. **Pro/Maxログインを実行:**
   ```bash
   # 既存のログイン状態をクリア
   claude logout
   
   # Pro/Maxログインを実行（非対話モード）
   claude login </dev/null
   ```

3. **APIキーを復元:**
   ```bash
   # ~/.zshrcからAPIキーを読み込む
   source ~/.zshrc
   ```

### 問題3: ターミナルでAPIキーが使用される

**症状:**
- ターミナルで`claude`を実行すると、APIキーが使用される
- Pro/Maxログインが使用されない

**解決方法:**

1. **一時的にAPIキーを無効化:**
   ```bash
   # 現在のセッションでのみAPIキーを無効化
   unset ANTHROPIC_API_KEY
   ```

2. **プロジェクトローカルでAPIキーを無効化:**
   ```bash
   # .env.localファイルを作成してAPIキーをコメントアウト
   echo "# ANTHROPIC_API_KEY=your-api-key" > .env.local
   ```

3. **スクリプトで自動的にPro/Maxログインを優先:**
   - `scripts/run-agents.sh`は既に修正済み
   - APIキーが設定されていても、Pro/Maxログインが可能な場合はPro/Maxログインを使用

### 問題4: CursorでClaudeが使用できない

**症状:**
- CursorでClaudeを使用しようとすると、エラーが発生する
- BYOキーが認識されない

**解決方法:**

1. **APIキーを設定:**
   ```bash
   # ~/.zshrcにAPIキーを追加
   echo 'export ANTHROPIC_API_KEY="your-api-key"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **CursorでAPIキーを設定:**
   - Cursorの設定でAPIキーを設定
   - Settings → API Keys → Anthropic API Key

3. **Agent/Editが使用できない場合:**
   - Agent/Editなど一部機能はBYO非対応の可能性があります
   - Cursorの自社モデル枠を使用することを検討

### 問題5: 両方の認証方式を設定したい

**症状:**
- ターミナルではPro/Maxログイン、CursorではAPIキーを使いたい
- 両方設定する方法がわからない

**解決方法:**

1. **両方設定:**
   ```bash
   # 1. Pro/Maxログインを設定
   npm run agent:auth
   # 方式A: Pro/Maxログイン運用を選択（y）
   
   # 2. APIキーを設定
   npm run agent:auth
   # 方式B: APIキー運用を選択（y）
   ```

2. **使い分け:**
   - **ターミナル**: Pro/Maxログインを使用（API課金ゼロ）
     ```bash
     # 一時的にAPIキーを無効化
     unset ANTHROPIC_API_KEY
     ```
   - **Cursor**: APIキーを使用（BYOキー）
     ```bash
     # APIキーが設定されたまま（CursorはAPIキーを読みます）
     ```

3. **自動的な使い分け:**
   - `scripts/run-agents.sh`は既に修正済み
   - APIキーが設定されていても、Pro/Maxログインが可能な場合はPro/Maxログインを使用

## 🔍 認証状態の確認

### Pro/Maxログイン状態の確認

```bash
# APIキーを一時的に無効化
unset ANTHROPIC_API_KEY

# Pro/Maxログイン状態を確認
claude whoami
```

### APIキー状態の確認

```bash
# APIキーが設定されているか確認
echo $ANTHROPIC_API_KEY

# ~/.zshrcから読み込まれているか確認
grep ANTHROPIC_API_KEY ~/.zshrc
```

### 認証テスト

```bash
# Codexテスト
echo "test" | codex exec

# Claudeテスト（Pro/Maxログイン）
unset ANTHROPIC_API_KEY
echo "test" | claude --print --model sonnet

# Claudeテスト（APIキー）
export ANTHROPIC_API_KEY="your-api-key"
echo "test" | claude --print --model sonnet
```

## 📝 推奨ワークフロー

### ターミナルでの使用

```bash
# 1. APIキーを一時的に無効化（Pro/Maxログインを使用）
unset ANTHROPIC_API_KEY

# 2. エージェントを実行
npm run agent:run

# 3. Pro/Maxログインで実行（API課金ゼロ）
```

### Cursorでの使用

```bash
# 1. APIキーが設定されていることを確認
echo $ANTHROPIC_API_KEY

# 2. CursorでClaudeを使用
# CursorはAPIキーを自動的に読み込みます
```

### 両方を使用する場合

```bash
# 1. 両方設定
npm run agent:auth
# 方式A: Pro/Maxログイン運用を選択（y）
# 方式B: APIキー運用を選択（y）

# 2. ターミナルではPro/Maxログインを使用
unset ANTHROPIC_API_KEY
npm run agent:run

# 3. CursorではAPIキーを使用
# APIキーが設定されたまま（CursorはAPIキーを読みます）
```

## 🎯 次のステップ

1. **認証セットアップを完了**
   ```bash
   npm run agent:auth
   ```

2. **認証状態を確認**
   ```bash
   # Pro/Maxログイン状態
   unset ANTHROPIC_API_KEY
   claude whoami
   
   # APIキー状態
   echo $ANTHROPIC_API_KEY
   ```

3. **エージェントを実行**
   ```bash
   # ターミナルではPro/Maxログインを使用
   unset ANTHROPIC_API_KEY
   npm run agent:run
   ```

---

**これで、認証に関する問題を解決できます！** 🚀

