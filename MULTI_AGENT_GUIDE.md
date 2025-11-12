# 🤖 マルチエージェント開発環境ガイド

Cursor 2.0 + Claude Code MAX + Codex + GitHub を活用した並列マルチエージェント開発環境のセットアップと使用方法です。

## 📋 目次

1. [概要](#概要)
2. [前提条件](#前提条件)
3. [セットアップ](#セットアップ)
4. [エージェントの役割](#エージェントの役割)
5. [使用方法](#使用方法)
6. [ワークフロー](#ワークフロー)
7. [トラブルシューティング](#トラブルシューティング)

## 📖 概要

このプロジェクトでは、**複数のAIエージェントを並列実行**して、高速にデモを開発できます。

### 特徴

- 🚀 **並列実行**: 複数のエージェントが同時に作業
- 💰 **コスト効率**: Claude Code MAX / Codex をターミナルから直接実行
- 🔐 **認証方式**: Claude Codeは「Pro/Maxログイン運用」と「APIキー運用」の2択
- 🔄 **自動化**: スクリプトベースで自動実行
- 📊 **可視化**: 各エージェントの進捗を確認
- 🔀 **Git統合**: Worktreeとブランチで分離管理
- 🎯 **Cursor独立**: Cursorのトークン制限とは独立して動作

## ✅ 前提条件

### 必要なもの

1. **Claude Code MAX 契約**
   - AnthropicのClaude Code MAXにアクセス可能
   - ターミナルから `claude` コマンドが使用可能
   - **認証方式**: Pro/Maxログイン運用（推奨・API課金ゼロ）またはAPIキー運用

2. **Codex (OpenAI) 契約**
   - OpenAIのCodexにアクセス可能
   - ターミナルから `codex` コマンドが使用可能
   - **認証方式**: CLIログイン方式（Cursorにも効く）

3. **Cursor 2.0**
   - Cursor 2.0がインストールされていること
   - マルチエージェント機能が利用可能

4. **Git**
   - Gitがインストールされていること
   - Worktree機能が使用可能

5. **jq** (オプション)
   - JSON処理用: `brew install jq` (Mac) または `apt-get install jq` (Linux)

## 🚀 セットアップ

### Step 1: 認証セットアップ（重要）

```bash
# 認証セットアップスクリプトを実行
npm run agent:auth
```

このスクリプトは以下を実行します：
- Codexのログイン状態を確認・ログイン
- Claude Codeの認証方式を選択（Pro/Maxログイン or APIキー）
- 環境変数の設定をサポート
- 認証テストを実行

**重要**: 
- **Claude Code**: 「Pro/Maxログイン運用」（API課金ゼロ・ターミナル専用）または「APIキー運用」（Cursorでも使用可能）
- **Codex**: CLIログイン方式（Cursorにも効く）
- **Cursor**: Claude Codeのログイン状態を読みにいかない（APIキーが必要）

詳しくは [AUTHENTICATION_SETUP.md](./AUTHENTICATION_SETUP.md) を参照してください。

### Step 2: マルチエージェント環境のセットアップ

```bash
# プロジェクトディレクトリに移動
cd /Users/masafumikikuchi/Dev/p_demo

# マルチエージェント環境をセットアップ
npm run agent:setup
```

このコマンドで以下が作成されます:
- 各エージェント用のWorktree
- エージェント設定ファイル (`.agents/agent-config.json`)
- Cursor用ワークスペース設定 (`.agents/multi-agent.code-workspace`)

### Step 2: Cursorワークスペースを開く

```bash
# Cursorでワークスペースを開く
cursor .agents/multi-agent.code-workspace
```

これで、メインプロジェクトと各エージェントのWorktreeが同時に表示されます。

### Step 3: エージェント設定の確認

```bash
# エージェントの状態を確認
npm run agent:status
```

## 👥 エージェントの役割

### 1. Architect (アーキテクト)
- **役割**: システム設計・アーキテクチャ担当
- **モデル**: Claude Sonnet 4.5 (Claude Code MAX)
- **作業内容**:
  - システム全体の設計
  - データモデル設計
  - API設計
  - 技術選定

### 2. Backend (バックエンド)
- **役割**: バックエンドAPI実装担当（ただし、このプロジェクトはフロントエンドのみ）
- **モデル**: Claude Opus (Claude Code MAX)
- **作業内容**:
  - データ構造の設計
  - ダミーデータの生成
  - データ処理ロジックの実装

### 3. Frontend (フロントエンド)
- **役割**: フロントエンドUI実装担当
- **モデル**: GPT-4 (Codex)
- **作業内容**:
  - UI実装
  - コンポーネント開発
  - 状態管理
  - UX改善

### 4. Testing (テスト)
- **役割**: テスト実装担当
- **モデル**: GPT-4 (Codex)
- **作業内容**:
  - ユニットテストの作成
  - コンポーネントテストの作成
  - テストカバレッジの確保

### 5. Review (レビュー)
- **役割**: コードレビュー・リファクタリング担当
- **モデル**: Claude Sonnet 4.5 (Claude Code MAX)
- **作業内容**:
  - コードレビュー
  - リファクタリング
  - 性能改善
  - セキュリティ監査

## 🎯 使用方法

### 全エージェントを並列実行

```bash
# 全エージェントを並列実行
npm run agent:run
```

### 特定のエージェントを実行

```bash
# Architectエージェントのみ実行
npm run agent:run:architect

# Frontendエージェントのみ実行
npm run agent:run:frontend

# 複数のエージェントを指定
bash scripts/run-agents.sh architect frontend
```

### エージェントの状態確認

```bash
# エージェントの状態を確認
npm run agent:status
```

### エージェント設定の確認

```bash
# エージェント設定ファイルを確認
cat .agents/agent-config.json
```

## 🔄 ワークフロー

### 1. 与件をメモ

`REQUIREMENTS.md` に与件を記載します。

### 2. エージェント環境をセットアップ

```bash
npm run agent:setup
```

### 3. エージェントを実行

```bash
# 全エージェントを並列実行
npm run agent:run
```

### 4. 各エージェントの作業を確認

各Worktreeで変更を確認:

```bash
# 各Worktreeに移動して確認
cd ../p_demo-worktrees/agent-architect-YYYYMMDD
git status
git diff
```

### 5. 変更をコミット

```bash
# 各Worktreeで変更をコミット
git add .
git commit -m "feat: アーキテクチャ設計を実装"
```

### 6. PRを作成

```bash
# 各ブランチからPRを作成
git push origin agent/architect-YYYYMMDD
```

GitHubでPRを作成して、各エージェントの成果を比較します。

### 7. 最良案を選択してマージ

レビュー後、最良案を選択してmainブランチにマージします。

## 📁 ディレクトリ構造

```
p_demo/
├── .agents/
│   ├── agent-config.json          # エージェント設定
│   └── multi-agent.code-workspace # Cursorワークスペース
├── scripts/
│   ├── setup-multi-agent.sh       # セットアップスクリプト
│   ├── run-agents.sh              # エージェント実行スクリプト
│   ├── agent-status.sh            # 状態確認スクリプト
│   └── agent-prompts/             # プロンプトテンプレート
│       ├── architect.prompt.md
│       ├── backend.prompt.md
│       ├── frontend.prompt.md
│       ├── testing.prompt.md
│       └── review.prompt.md
└── ../p_demo-worktrees/           # Worktreeディレクトリ
    ├── agent-architect-YYYYMMDD/
    ├── agent-backend-YYYYMMDD/
    ├── agent-frontend-YYYYMMDD/
    ├── agent-testing-YYYYMMDD/
    └── agent-review-YYYYMMDD/
```

## 🛠️ カスタマイズ

### エージェント設定の変更

`.agents/agent-config.json` を編集して、エージェントの設定を変更できます。

```json
{
  "agents": [
    {
      "name": "architect",
      "model": "claude-sonnet-4.5",
      "model_type": "claude-code-max",
      ...
    }
  ]
}
```

### プロンプトテンプレートのカスタマイズ

`scripts/agent-prompts/` 内のプロンプトテンプレートを編集して、エージェントの動作をカスタマイズできます。

## 🔍 トラブルシューティング

### Worktreeが作成されない

```bash
# Worktreeディレクトリを確認
ls -la ../p_demo-worktrees/

# 手動でWorktreeを作成
git worktree add ../p_demo-worktrees/agent-architect-YYYYMMDD agent/architect-YYYYMMDD
```

### エージェントが実行されない

```bash
# Claude Code MAX / Codex がインストールされているか確認
which claude
which codex

# エージェント設定ファイルを確認
cat .agents/agent-config.json
```

### ログファイルを確認

各Worktreeにログファイルが生成されます:

```bash
# ログファイルを確認
cat ../p_demo-worktrees/agent-architect-YYYYMMDD/.agent-architect.log
```

### jqがインストールされていない

```bash
# Macの場合
brew install jq

# Linuxの場合
apt-get install jq
```

## 💡 ベストプラクティス

1. **与件を明確に**: REQUIREMENTS.mdに詳細な与件を記載
2. **エージェントを並列実行**: 複数エージェントを同時に実行して高速化
3. **定期的に状態確認**: `npm run agent:status` で進捗を確認
4. **PRで比較**: 各エージェントの成果をPRで比較して最良案を選択
5. **ログを確認**: エラーが発生した場合はログファイルを確認

## 🚀 次のステップ

1. **REQUIREMENTS.mdに与件を追加**
2. **エージェント環境をセットアップ**: `npm run agent:setup`
3. **エージェントを実行**: `npm run agent:run`
4. **成果を確認**: 各Worktreeで変更を確認
5. **PRを作成**: GitHubでPRを作成して比較
6. **最良案を選択**: レビュー後、最良案をマージ

---

**素晴らしいデモを高速で作成しましょう！** 🚀

