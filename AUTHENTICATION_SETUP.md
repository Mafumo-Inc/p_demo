# 🔐 ターミナル認証セットアップガイド

## 🎯 目的

**Cursor 2.0経由ではなく、ターミナルから直接あなたのClaude Code MAX / Codexアカウントを使用**して並列開発を行うための認証セットアップです。

これにより、**Cursorのトークン制限とは独立して**、あなたの契約アカウントを直接使用できます。

## 📋 前提条件

- ✅ Claude Code MAX 契約（Pro/Maxアカウント or Anthropic APIキー）
- ✅ Codex 契約（OpenAI APIキー）
- ✅ ターミナルから `claude` と `codex` コマンドが使用可能

## 🔑 認証方式の違い

### Codex: CLIログイン方式

- **方式**: `codex login` でログイン
- **特徴**: Cursorにも効く（ログイン状態を共有）
- **課金**: あなたのCodex契約を使用

### Claude Code: 2つの方式

#### 方式A: Pro/Maxログイン運用（推奨・ターミナル用）

- **方式**: `claude login` でPro/Maxアカウントにログイン
- **APIキー**: **設定しない**（ConsoleのAPI資格情報は入れない）
- **課金**: **API課金ゼロ**（Pro/Maxの割当を使用）
- **特徴**: 
  - 長時間・高並列運用が可能
  - ターミナルでの利用に最適
  - **Cursorでは使用不可**（Cursorはログイン状態を読みにいかない）

#### 方式B: APIキー運用（Cursor用）

- **方式**: `ANTHROPIC_API_KEY` 環境変数を設定
- **課金**: API課金あり（使用量に応じて課金）
- **特徴**: 
  - Cursorでも使用可能（BYOキー）
  - Agent/Editなど一部機能はBYO非対応の可能性

## 🚀 セットアップ方法

### 方法1: 自動セットアップスクリプト（推奨）

```bash
# 認証セットアップスクリプトを実行
npm run agent:auth
```

このスクリプトは以下を実行します：
1. Codexのログイン状態を確認・ログイン
2. Claude Codeの認証方式を選択（Pro/Maxログイン or APIキー）
3. 環境変数の設定をサポート
4. 認証テストを実行

### 方法2: 手動セットアップ

#### Step 1: Codexにログイン

```bash
# Codexにログイン
codex login

# ログイン状態を確認
codex login status
```

#### Step 2: Claude Codeの認証方式を選択

##### 方式A: Pro/Maxログイン運用（ターミナル用・推奨）

```bash
# 既存のログイン状態をクリア
claude logout

# Pro/Maxアカウントでログイン
# ⚠️ 重要: ConsoleのAPI資格情報は入れない
claude login

# 環境変数をクリア（APIキーが設定されている場合）
unset ANTHROPIC_API_KEY
# ~/.zshrcからも削除
sed -i.bak '/export ANTHROPIC_API_KEY/d' ~/.zshrc
```

**重要**: ConsoleのAPI資格情報は**入れない**でください。これによりAPI課金を避けてPro/Maxの割当でCLIが動きます。

##### 方式B: APIキー運用（Cursor用）

```bash
# Anthropic APIキーを取得
# 1. https://console.anthropic.com/ にアクセス
# 2. API Keys セクションで新しいキーを作成
# 3. キーをコピー

# 環境変数として設定
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

#### Pro/Maxログイン運用

```bash
# ログイン状態を確認（環境変数が設定されていないことを確認）
echo $ANTHROPIC_API_KEY
# 何も出力されないことを確認

# テスト実行
echo "test" | claude --print --model sonnet
```

#### APIキー運用

```bash
# 環境変数を確認
echo $ANTHROPIC_API_KEY

# テスト実行
echo "test" | claude --print --model sonnet
```

## ⚠️ 重要な注意事項

### 1. Cursorとの関係

- **CursorはClaude Codeのログイン状態を読みにいきません**
- CursorでClaudeを使う場合は**APIキー（BYO）**を設定する必要があります
- Agent/Editなど一部機能はBYO非対応の可能性があります
- **Codex方式の「ログインをCursorに流用」はできません**

### 2. 推奨ワークフロー

**ターミナル側:**
- Claude Code（Pro/Maxログイン運用またはAPI運用）
- Codex（CLIログイン）
- 実装・長文処理・並列実行

**Cursor側:**
- レビュー・差分比較・軽作業
- APIキー（BYO）を設定して使用
- Cursorの自社モデル枠を使用

### 3. ハイブリッド運用

**並列開発をAPIコスト最小で回す場合:**

1. **ターミナル**: Claude Code（Pro/Maxログイン）とCodexで並列実行
2. **Cursor**: レビュー・差分比較・軽作業に限定
3. **エージェント割り当て**:
   - Architect/Review: ターミナルClaude（Pro/Maxログイン運用）
   - Testing/小タスク: Codex
   - Cursor: Worktreeを各ウィンドウで開いて可視化

### 4. セキュリティ

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

### Claudeが動作しない（Pro/Maxログイン運用）

```bash
# ログイン状態を確認
claude logout
claude login

# 環境変数を確認（設定されていないことを確認）
echo $ANTHROPIC_API_KEY

# テスト実行
echo "test" | claude --print --model sonnet
```

### Claudeが動作しない（APIキー運用）

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
claude logout
claude login  # または APIキーを設定
```

## 📝 環境変数の設定例

### ~/.zshrc に追加（APIキー運用の場合）

```bash
# Claude Code MAX (APIキー運用)
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
- [ ] Claude Codeの認証方式を選択
  - [ ] Pro/Maxログイン運用: `claude login` 済み、ANTHROPIC_API_KEY未設定
  - [ ] APIキー運用: `ANTHROPIC_API_KEY` 環境変数が設定済み
- [ ] Codexテストが成功 (`echo "test" | codex exec`)
- [ ] Claudeテストが成功 (`echo "test" | claude --print --model sonnet`)
- [ ] `npm run agent:run` が正常に動作

## 🎯 次のステップ

1. **認証セットアップを完了**
   ```bash
   npm run agent:auth
   ```

2. **エージェントを実行**
   ```bash
   npm run agent:run
   ```

3. **進捗を監視**
   ```bash
   npm run agent:watch
   ```

## 📚 参考資料

- [Claude Code - Using Claude Code with your Pro or Max plan](https://support.claude.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan)
- [Claude Docs - Get started](https://docs.claude.com/en/docs/get-started)
- [Cursor Docs - API Keys](https://cursor.com/docs/settings/api-keys)
- [Claude Code Docs - Identity and Access Management](https://code.claude.com/docs/en/iam)

---

**これで、Cursorのトークン制限とは独立して、あなたのアカウントで並列開発が可能になります！** 🚀
