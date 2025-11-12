# 🔐 マルチエージェント認証ガイド（詳細版）

## 📋 概要

このドキュメントでは、**ターミナルから直接Claude Code MAX / Codexアカウントを使用**して並列開発を行うための認証方法について詳しく説明します。

## 🔑 認証方式の違い

### Codex: CLIログイン方式

**特徴:**
- `codex login` でログイン
- **Cursorにも効く**（ログイン状態を共有）
- あなたのCodex契約を使用
- API課金なし（契約内の割当を使用）

**セットアップ:**
```bash
codex login
codex login status  # ログイン状態を確認
```

### Claude Code: 2つの方式

#### 方式A: Pro/Maxログイン運用（ターミナル用・推奨）

**特徴:**
- `claude login` でPro/Maxアカウントにログイン
- **APIキーは設定しない**（ConsoleのAPI資格情報は入れない）
- **API課金ゼロ**（Pro/Maxの割当を使用）
- 長時間・高並列運用が可能
- ターミナルでの利用に最適
- **Cursorでは使用不可**（Cursorはログイン状態を読みにいかない）

**セットアップ:**
```bash
# 既存のログイン状態をクリア
claude logout

# Pro/Maxアカウントでログイン
# ⚠️ 重要: ConsoleのAPI資格情報は入れない
claude login

# 環境変数をクリア（APIキーが設定されている場合）
unset ANTHROPIC_API_KEY
sed -i.bak '/export ANTHROPIC_API_KEY/d' ~/.zshrc
```

**重要**: ConsoleのAPI資格情報は**入れない**でください。これによりAPI課金を避けてPro/Maxの割当でCLIが動きます。

#### 方式B: APIキー運用（Cursor用）

**特徴:**
- `ANTHROPIC_API_KEY` 環境変数を設定
- API課金あり（使用量に応じて課金）
- Cursorでも使用可能（BYOキー）
- Agent/Editなど一部機能はBYO非対応の可能性

**セットアップ:**
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

## 🚀 推奨ワークフロー

### ハイブリッド運用（APIコスト最小）

**ターミナル側:**
- Claude Code（Pro/Maxログイン運用）
- Codex（CLIログイン）
- 実装・長文処理・並列実行

**Cursor側:**
- レビュー・差分比較・軽作業
- APIキー（BYO）を設定して使用
- Cursorの自社モデル枠を使用

### エージェント割り当て

**ターミナルで実行:**
- Architect: Claude Code（Pro/Maxログイン運用）
- Backend: Claude Code（Pro/Maxログイン運用）
- Review: Claude Code（Pro/Maxログイン運用）
- Frontend: Codex（CLIログイン）
- Testing: Codex（CLIログイン）

**Cursorで実行:**
- レビュー・差分比較
- Worktreeを各ウィンドウで開いて可視化
- 軽作業

## ⚠️ Cursorとの関係

### 重要な制約

1. **CursorはClaude Codeのログイン状態を読みにいきません**
   - CursorでClaudeを使う場合は**APIキー（BYO）**を設定する必要があります
   - Agent/Editなど一部機能はBYO非対応の可能性があります

2. **Codex方式の「ログインをCursorに流用」はできません**
   - CodexはCLIログイン方式でCursorにも効きます
   - Claude Codeはログイン状態をCursorに流用できません

3. **推奨: ターミナルとCursorを分離**
   - ターミナル: Pro/Maxログイン運用（API課金ゼロ）
   - Cursor: APIキー運用（BYO）またはCursorの自社モデル枠

## 🔧 セットアップ手順

### Step 1: 認証セットアップスクリプトを実行

```bash
npm run agent:auth
```

このスクリプトは以下を実行します：
1. Codexのログイン状態を確認・ログイン
2. Claude Codeの認証方式を選択（Pro/Maxログイン or APIキー）
3. 環境変数の設定をサポート
4. 認証テストを実行

### Step 2: 認証方式を選択

#### Pro/Maxログイン運用（ターミナル用・推奨）

```bash
# 既存のログイン状態をクリア
claude logout

# Pro/Maxアカウントでログイン
# ⚠️ 重要: ConsoleのAPI資格情報は入れない
claude login

# 環境変数をクリア
unset ANTHROPIC_API_KEY
sed -i.bak '/export ANTHROPIC_API_KEY/d' ~/.zshrc
```

#### APIキー運用（Cursor用）

```bash
# Anthropic APIキーを取得
# 1. https://console.anthropic.com/ にアクセス
# 2. API Keys セクションで新しいキーを作成
# 3. キーをコピー

# 環境変数として設定
export ANTHROPIC_API_KEY='your-api-key-here'

# 永続的に設定
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.zshrc
source ~/.zshrc
```

### Step 3: 認証テスト

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

