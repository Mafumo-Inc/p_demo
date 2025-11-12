#!/bin/bash

# マルチエージェント開発環境セットアップスクリプト
# Cursor 2.0 + Claude Code MAX + Codex + GitHub 並列開発用

set -e

# カラー定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 マルチエージェント開発環境セットアップを開始します${NC}"

# プロジェクトルートディレクトリを取得
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# worktreeディレクトリの作成
WORKTREE_DIR="$PROJECT_ROOT/../p_demo-worktrees"
mkdir -p "$WORKTREE_DIR"

# エージェントブランチのプレフィックス定義
AGENT_BRANCHES=(
  "agent/architect"      # 設計・アーキテクチャ担当
  "agent/backend"        # バックエンドAPI実装担当
  "agent/frontend"       # フロントエンドUI実装担当
  "agent/testing"        # テスト実装担当
  "agent/review"         # レビュー・リファクタリング担当
)

echo -e "${YELLOW}📁 Worktreeディレクトリ: $WORKTREE_DIR${NC}"

# 日付サフィックスを生成
DATE_SUFFIX=$(date +%Y%m%d)

# 各エージェント用のworktreeを作成
for branch in "${AGENT_BRANCHES[@]}"; do
  branch_name="${branch}-${DATE_SUFFIX}"
  worktree_path="$WORKTREE_DIR/${branch_name//\//-}"

  echo -e "${GREEN}➤ ${branch_name} 用のworktreeを作成中...${NC}"

  # ブランチが存在しない場合は作成
  if ! git show-ref --verify --quiet "refs/heads/$branch_name"; then
    git branch "$branch_name" main 2>/dev/null || git branch "$branch_name" origin/main 2>/dev/null || git branch "$branch_name" $(git rev-parse --abbrev-ref HEAD)
    echo -e "  ✅ ブランチ作成: $branch_name"
  fi

  # worktreeがまだ存在しない場合のみ作成
  if [ ! -d "$worktree_path" ]; then
    git worktree add "$worktree_path" "$branch_name" 2>/dev/null || echo -e "  ⚠️  Worktree作成スキップ（既存の可能性）"
    echo -e "  ✅ Worktree作成完了: $worktree_path"
  else
    echo -e "  ℹ️  既存のworktreeを使用: $worktree_path"
  fi
done

# エージェント管理用ディレクトリの作成
AGENT_CONFIG_DIR="$PROJECT_ROOT/.agents"
mkdir -p "$AGENT_CONFIG_DIR"

# エージェント設定ファイルの作成
cat > "$AGENT_CONFIG_DIR/agent-config.json" << EOF
{
  "agents": [
    {
      "name": "architect",
      "role": "設計・アーキテクチャ担当",
      "branch_prefix": "agent/architect",
      "worktree_path": "$WORKTREE_DIR/agent-architect-${DATE_SUFFIX}",
      "model": "claude-sonnet-4.5",
      "model_type": "claude-code-max",
      "focus_areas": ["システム設計", "データモデル", "API設計", "技術選定"],
      "prompt_template": "scripts/agent-prompts/architect.prompt.md"
    },
    {
      "name": "backend",
      "role": "バックエンドAPI実装担当",
      "branch_prefix": "agent/backend",
      "worktree_path": "$WORKTREE_DIR/agent-backend-${DATE_SUFFIX}",
      "model": "claude-opus",
      "model_type": "claude-code-max",
      "focus_areas": ["API実装", "データベース操作", "認証・認可", "ビジネスロジック"],
      "prompt_template": "scripts/agent-prompts/backend.prompt.md"
    },
    {
      "name": "frontend",
      "role": "フロントエンドUI実装担当",
      "branch_prefix": "agent/frontend",
      "worktree_path": "$WORKTREE_DIR/agent-frontend-${DATE_SUFFIX}",
      "model": "gpt-4",
      "model_type": "codex",
      "focus_areas": ["UI実装", "コンポーネント開発", "状態管理", "UX改善"],
      "prompt_template": "scripts/agent-prompts/frontend.prompt.md"
    },
    {
      "name": "testing",
      "role": "テスト実装担当",
      "branch_prefix": "agent/testing",
      "worktree_path": "$WORKTREE_DIR/agent-testing-${DATE_SUFFIX}",
      "model": "gpt-4",
      "model_type": "codex",
      "focus_areas": ["ユニットテスト", "統合テスト", "E2Eテスト", "テストカバレッジ"],
      "prompt_template": "scripts/agent-prompts/testing.prompt.md"
    },
    {
      "name": "review",
      "role": "レビュー・リファクタリング担当",
      "branch_prefix": "agent/review",
      "worktree_path": "$WORKTREE_DIR/agent-review-${DATE_SUFFIX}",
      "model": "claude-sonnet-4.5",
      "model_type": "claude-code-max",
      "focus_areas": ["コードレビュー", "リファクタリング", "性能改善", "セキュリティ監査"],
      "prompt_template": "scripts/agent-prompts/review.prompt.md"
    }
  ],
  "workflow": {
    "parallel_execution": true,
    "auto_merge_strategy": "pull_request",
    "conflict_resolution": "manual_review",
    "date_suffix": "${DATE_SUFFIX}"
  },
  "worktree_base": "$WORKTREE_DIR"
}
EOF

echo -e "${GREEN}✅ エージェント設定ファイルを作成: $AGENT_CONFIG_DIR/agent-config.json${NC}"

# Cursor用のワークスペース設定を生成
cat > "$AGENT_CONFIG_DIR/multi-agent.code-workspace" << EOF
{
  "folders": [
    {
      "name": "🏠 Main Project",
      "path": "."
    },
    {
      "name": "📐 Architect Agent",
      "path": "$WORKTREE_DIR/agent-architect-${DATE_SUFFIX}"
    },
    {
      "name": "🔧 Backend Agent",
      "path": "$WORKTREE_DIR/agent-backend-${DATE_SUFFIX}"
    },
    {
      "name": "🎨 Frontend Agent",
      "path": "$WORKTREE_DIR/agent-frontend-${DATE_SUFFIX}"
    },
    {
      "name": "🧪 Testing Agent",
      "path": "$WORKTREE_DIR/agent-testing-${DATE_SUFFIX}"
    },
    {
      "name": "🔍 Review Agent",
      "path": "$WORKTREE_DIR/agent-review-${DATE_SUFFIX}"
    }
  ],
  "settings": {
    "git.branchProtection": ["main"],
    "git.confirmSync": false,
    "editor.formatOnSave": true,
    "typescript.preferences.importModuleSpecifier": "relative",
    "files.exclude": {
      "**/node_modules": true,
      "**/.next": true
    }
  }
}
EOF

echo -e "${GREEN}✅ Cursorワークスペース設定を作成: $AGENT_CONFIG_DIR/multi-agent.code-workspace${NC}"

# エージェントプロンプトテンプレートディレクトリの確認
if [ ! -d "$PROJECT_ROOT/scripts/agent-prompts" ]; then
  mkdir -p "$PROJECT_ROOT/scripts/agent-prompts"
  echo -e "${YELLOW}📝 プロンプトテンプレートディレクトリを作成しました${NC}"
fi

echo -e "${GREEN}✅ マルチエージェント環境のセットアップが完了しました！${NC}"
echo -e ""
echo -e "${BLUE}📝 次のステップ:${NC}"
echo -e "1. Cursorで '.agents/multi-agent.code-workspace' を開く"
echo -e "2. scripts/agent-prompts/ 内のプロンプトテンプレートを確認・カスタマイズ"
echo -e "3. scripts/run-agents.sh でエージェントを実行"
echo -e "4. 各エージェントフォルダで独立した作業を開始"
echo -e ""
echo -e "${YELLOW}💡 ヒント:${NC}"
echo -e "- 'npm run agent:setup' で再セットアップ"
echo -e "- 'npm run agent:status' で各エージェントの状態を確認"
echo -e "- 'npm run agent:run' で全エージェントを並列実行"

