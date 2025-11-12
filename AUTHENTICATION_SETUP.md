# 🔐 ターミナル認証セットアップガイド

## 🎯 目的

**Cursor 2.0経由ではなく、ターミナルから直接あなたのClaude Code MAX / Codexアカウントを使用**して並列開発を行うための認証セットアップです。

これにより、**Cursorのトークン制限とは独立して**、あなたの契約アカウントを直接使用できます。

## 📋 前提条件

- ✅ Claude Code MAX 契約（Anthropic APIキー）
- ✅ Codex 契約（OpenAI APIキー）
- ✅ ターミナルから `claude` と `codex` コマンドが使用可能

## 🚀 セットアップ方法

### 方法1: 自動セットアップスクリプト（推奨）

```bash
# 認証セットアップスクリプトを実行
bash scripts/setup-authentication.sh
```

このスクリプトは以下を実行します：
1. Codexのログイン状態を確認
2. Claude Codeの認証状態を確認
3. 必要に応じてログインを促す
4. 環境変数の設定をサポート
5. 認証テストを実行

### 方法2: 手動セットアップ

#### Step 1: Codexにログイン

```bash
# Codexにログイン
codex login

# ログイン状態を確認
codex login status
```

#### Step 2: Claude Codeの認証設定

**Anthropic APIキーを取得:**
1. [Anthropic Console](https://console.anthropic.com/) にアクセス
2. API Keys セクションで新しいキーを作成
3. キーをコピー

**環境変数として設定:**

```bash
# 一時的に設定（現在のターミナルセッションのみ）
export ANTHROPIC_API_KEY='your-api-key-here'

# 永続的に設定（~/.zshrc に追加）
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

#### Step 3: 認証テスト

```bash
# Codexテスト
echo "test" | codex exec

# Claudeテスト
echo "test" | claude --print --model sonnet
```

## 🔍 認証状態の確認

### Codex

```bash
# ログイン状態を確認
codex login status

# 設定ファイルを確認
cat ~/.codex/config.toml
```

### Claude Code

```bash
# 環境変数を確認
echo $ANTHROPIC_API_KEY

# テスト実行
echo "test" | claude --print --model sonnet
```

## ⚠️ 重要な注意事項

### 1. Cursor経由 vs ターミナル直接

- **Cursor経由**: Cursorのトークン制限に影響される
- **ターミナル直接**: あなたの契約アカウントを直接使用（制限なし）

### 2. APIキーの管理

- **環境変数**: セキュアで推奨
- **設定ファイル**: `~/.anthropic/config.json` または `~/.codex/config.toml`
- **.envファイル**: プロジェクトローカル（Gitにコミットしないこと）

### 3. セキュリティ

- APIキーは**絶対にGitにコミットしない**
- `.env` ファイルは `.gitignore` に追加
- 環境変数を使用することを推奨

## 🔧 トラブルシューティング

### Codexがログインできない

```bash
# ログアウトして再ログイン
codex logout
codex login

# 設定ファイルを確認
cat ~/.codex/config.toml
```

### Claudeが動作しない

```bash
# 環境変数を確認
echo $ANTHROPIC_API_KEY

# 環境変数を再設定
export ANTHROPIC_API_KEY='your-api-key'
source ~/.zshrc

# テスト実行
echo "test" | claude --print --model sonnet
```

### 認証エラーが発生する

```bash
# 認証状態を確認
codex login status
echo $ANTHROPIC_API_KEY

# 再認証
codex login
export ANTHROPIC_API_KEY='your-api-key'
```

## 📝 環境変数の設定例

### ~/.zshrc に追加

```bash
# Claude Code MAX
export ANTHROPIC_API_KEY='sk-ant-api03-...'

# Codex (必要な場合)
export OPENAI_API_KEY='sk-...'
```

### プロジェクトローカル (.env.local)

```bash
# .env.local (Gitにコミットしない)
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-...
```

## ✅ セットアップ完了チェックリスト

- [ ] Codexにログイン済み (`codex login status`)
- [ ] Anthropic APIキーが設定済み (`echo $ANTHROPIC_API_KEY`)
- [ ] Codexテストが成功 (`echo "test" | codex exec`)
- [ ] Claudeテストが成功 (`echo "test" | claude --print --model sonnet`)
- [ ] `npm run agent:run` が正常に動作

## 🎯 次のステップ

1. **認証セットアップを完了**
   ```bash
   bash scripts/setup-authentication.sh
   ```

2. **エージェントを実行**
   ```bash
   npm run agent:run
   ```

3. **進捗を監視**
   ```bash
   npm run agent:watch
   ```

---

**これで、Cursorのトークン制限とは独立して、あなたのアカウントで並列開発が可能になります！** 🚀

