# 📜 スクリプトディレクトリ

マルチエージェント開発環境で使用するスクリプトの説明です。

## 📁 ファイル一覧

### `setup-multi-agent.sh`
マルチエージェント環境のセットアップスクリプト

**使用方法:**
```bash
npm run agent:setup
# または
bash scripts/setup-multi-agent.sh
```

**機能:**
- 各エージェント用のWorktreeを作成
- エージェント設定ファイルを生成
- Cursor用ワークスペース設定を生成

### `run-agents.sh`
エージェントを並列実行するスクリプト

**使用方法:**
```bash
# 全エージェントを実行
npm run agent:run

# 特定のエージェントを実行
npm run agent:run:architect
bash scripts/run-agents.sh architect frontend
```

**機能:**
- 複数のエージェントを並列実行
- Claude Code MAX / Codex をターミナルから直接実行
- 各エージェントのログを記録

### `agent-status.sh`
エージェントの状態を確認するスクリプト

**使用方法:**
```bash
npm run agent:status
# または
bash scripts/agent-status.sh
```

**機能:**
- 各エージェントの状態を表示
- Worktreeの存在確認
- 変更ファイルの確認
- ログファイルの確認

## 📂 ディレクトリ

### `agent-prompts/`
各エージェント用のプロンプトテンプレート

- `architect.prompt.md` - アーキテクトエージェント用
- `backend.prompt.md` - バックエンドエージェント用
- `frontend.prompt.md` - フロントエンドエージェント用
- `testing.prompt.md` - テストエージェント用
- `review.prompt.md` - レビューエージェント用

## 🔧 カスタマイズ

各スクリプトは編集可能です。必要に応じてカスタマイズしてください。

### エージェント設定の変更

`.agents/agent-config.json` を編集して、エージェントの設定を変更できます。

### プロンプトテンプレートの変更

`agent-prompts/` 内のプロンプトテンプレートを編集して、エージェントの動作をカスタマイズできます。

## 💡 ヒント

- スクリプトは `set -e` で実行されているため、エラーが発生すると即座に停止します
- ログファイルは各Worktreeに `.agent-{name}.log` として保存されます
- スクリプトはプロジェクトルートから実行することを想定しています

---

**詳細は [MULTI_AGENT_GUIDE.md](../MULTI_AGENT_GUIDE.md) を参照してください。**

