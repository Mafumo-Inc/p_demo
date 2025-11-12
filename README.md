# 🍽️ デモプロジェクト - 食事中に爆速でデモを作る

取引先との食事の時間内で企画を決めて一気にデモを作成するためのプロジェクトです。

## ✨ 特徴

- 🚀 **高速開発**: Next.js + TypeScript + Tailwind CSS
- 🎨 **美しいUI**: モダンで洗練されたデザイン
- 📊 **ダミーデータ**: 充実したダミーデータ生成ユーティリティ
- 🔄 **ホットリロード**: 変更が即座に反映
- 📝 **与件管理**: REQUIREMENTS.mdで要件を整理
- 🤖 **マルチエージェント**: Cursor 2.0 + Claude Code MAX + Codex で並列開発（新機能）

## 🚀 クイックスタート

```bash
# 開発サーバー起動
npm run dev
```

ブラウザで [http://localhost:3000](http://localhost:3000) を開いてください。

## 📖 使い方

詳しい使い方は [SETUP.md](./SETUP.md) を参照してください。

### 1. 与件をメモ
食事中にヒアリングした内容を `REQUIREMENTS.md` に記載

### 2. AIエージェントに指示
**新しいチャットを開く場合は、[AI_PROMPT_TEMPLATE.md](./AI_PROMPT_TEMPLATE.md) のテンプレートを使用してください。**

与件に基づいて型定義、ダミーデータ、UIを生成

### 3. デモ完成！
その場でデモを見せて提案をブラッシュアップ

## 🔄 新しいチャットで作業する場合

新しいチャットセッションでは、コンテキストが引き継がれないため、**プロンプトが必要**です。

1. `REQUIREMENTS.md` に与件を追加
2. 新しいチャットを開く
3. `AI_PROMPT_TEMPLATE.md` のテンプレートを使ってAIエージェントに指示

詳しくは [AI_PROMPT_TEMPLATE.md](./AI_PROMPT_TEMPLATE.md) を参照してください。

## 📁 主要ファイル

| ファイル | 用途 |
|---------|------|
| `REQUIREMENTS.md` | 与件・要件メモ（ここに食事中の内容を記載） |
| `MULTI_AGENT_GUIDE.md` | **🤖 マルチエージェント開発環境ガイド** |
| `AI_PROMPT_TEMPLATE.md` | **新しいチャット用のプロンプトテンプレート** |
| `SETUP.md` | セットアップと使い方の詳細ガイド |
| `src/app/page.tsx` | メインページ（デモのUI） |
| `src/types/index.ts` | 型定義 |
| `src/data/sampleData.ts` | ダミーデータ |
| `src/lib/dummyData.ts` | ダミーデータ生成ヘルパー |

## 🤖 マルチエージェント開発（新機能）

Cursor 2.0 + Claude Code MAX + Codex を活用した並列マルチエージェント開発環境が利用可能です。

### クイックスタート

```bash
# 1. 認証セットアップ（重要！）
npm run agent:auth

# 2. マルチエージェント環境をセットアップ
npm run agent:setup

# 3. 全エージェントを並列実行
npm run agent:run

# 4. エージェントの状態を確認
npm run agent:status

# 5. リアルタイム監視（別タブで）
npm run agent:watch
```

**重要**: 
- **Claude Code**: 「Pro/Maxログイン運用」（API課金ゼロ）または「APIキー運用」（Cursorでも使用可能）
- **Codex**: CLIログイン方式（Cursorにも効く）
- **Cursor**: Claude Codeのログイン状態を読みにいかない（APIキーが必要）

詳しくは [MULTI_AGENT_GUIDE.md](./MULTI_AGENT_GUIDE.md) と [AUTHENTICATION_SETUP.md](./AUTHENTICATION_SETUP.md) を参照してください。

## 🛠️ 技術スタック

- [Next.js 16](https://nextjs.org/) - Reactフレームワーク
- [TypeScript](https://www.typescriptlang.org/) - 型安全性
- [Tailwind CSS](https://tailwindcss.com/) - ユーティリティファーストCSS
- [React](https://react.dev/) - UIライブラリ

## 🌐 デプロイ

### Vercelへのデプロイ（推奨）

```bash
# Vercel CLIでデプロイ
npx vercel
```

または、GitHubにプッシュして [Vercel](https://vercel.com) のダッシュボードから連携。

## 📝 その他のコマンド

```bash
# ビルド
npm run build

# 本番サーバー起動
npm run start

# リントチェック
npm run lint
```

## 💡 Tips

- **型定義を先に**: まず型を定義すると開発がスムーズ
- **ダミーデータは多めに**: 見栄えが良くなります
- **コンポーネント再利用**: 同じUIはすぐにコンポーネント化

## 📄 ライセンス

このプロジェクトはデモ・プロトタイプ作成用です。

---

**準備完了！ 素晴らしいデモを作ってください！** 🎉
