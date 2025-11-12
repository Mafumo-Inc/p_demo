# ⚡ マルチエージェント開発 クイックスタート

5分で始めるマルチエージェント開発環境のセットアップです。

## 🚀 3ステップで開始

### Step 1: 環境セットアップ

```bash
# マルチエージェント環境をセットアップ
npm run agent:setup
```

これで以下が作成されます:
- 各エージェント用のWorktree
- エージェント設定ファイル
- Cursor用ワークスペース設定

### Step 2: Cursorワークスペースを開く

```bash
# Cursorでワークスペースを開く
cursor .agents/multi-agent.code-workspace
```

### Step 3: エージェントを実行

```bash
# 全エージェントを並列実行
npm run agent:run

# または特定のエージェントを実行
npm run agent:run:frontend
```

## 📋 前提条件

- ✅ Claude Code MAX 契約（`claude` コマンドが使用可能）
- ✅ Codex 契約（`codex` コマンドが使用可能）
- ✅ Cursor 2.0 がインストールされていること
- ✅ Git がインストールされていること

## 🔍 エージェントの状態確認

```bash
# エージェントの状態を確認
npm run agent:status
```

## 📁 主要コマンド

| コマンド | 説明 |
|---------|------|
| `npm run agent:setup` | マルチエージェント環境をセットアップ |
| `npm run agent:run` | 全エージェントを並列実行 |
| `npm run agent:status` | エージェントの状態を確認 |
| `npm run agent:run:architect` | Architectエージェントのみ実行 |
| `npm run agent:run:backend` | Backendエージェントのみ実行 |
| `npm run agent:run:frontend` | Frontendエージェントのみ実行 |
| `npm run agent:run:testing` | Testingエージェントのみ実行 |
| `npm run agent:run:review` | Reviewエージェントのみ実行 |

## 🎯 エージェントの役割

- **Architect**: システム設計・アーキテクチャ（Claude Sonnet 4.5）
- **Backend**: データ構造・ダミーデータ生成（Claude Opus）
- **Frontend**: UI実装（GPT-4）
- **Testing**: テスト実装（GPT-4）
- **Review**: コードレビュー・リファクタリング（Claude Sonnet 4.5）

## 💡 ヒント

1. **与件を明確に**: `REQUIREMENTS.md` に詳細な与件を記載
2. **並列実行**: 複数エージェントを同時に実行して高速化
3. **状態確認**: 定期的に `npm run agent:status` で進捗を確認
4. **PRで比較**: 各エージェントの成果をPRで比較して最良案を選択

## 📚 詳細情報

- [MULTI_AGENT_GUIDE.md](./MULTI_AGENT_GUIDE.md) - 詳細なガイド
- [scripts/README.md](./scripts/README.md) - スクリプトの説明

---

**さあ、始めましょう！** 🚀

