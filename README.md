# 🍽️ デモプロジェクト - 食事中に爆速でデモを作る

取引先との食事の時間内で企画を決めて一気にデモを作成するためのプロジェクトです。

## ✨ 特徴

- 🚀 **高速開発**: Next.js + TypeScript + Tailwind CSS
- 🎨 **美しいUI**: モダンで洗練されたデザイン
- 📊 **ダミーデータ**: 充実したダミーデータ生成ユーティリティ
- 🔄 **ホットリロード**: 変更が即座に反映
- 📝 **与件管理**: REQUIREMENTS.mdで要件を整理

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
与件に基づいて型定義、ダミーデータ、UIを生成

### 3. デモ完成！
その場でデモを見せて提案をブラッシュアップ

## 📁 主要ファイル

| ファイル | 用途 |
|---------|------|
| `REQUIREMENTS.md` | 与件・要件メモ（ここに食事中の内容を記載） |
| `SETUP.md` | セットアップと使い方の詳細ガイド |
| `src/app/page.tsx` | メインページ（デモのUI） |
| `src/types/index.ts` | 型定義 |
| `src/data/sampleData.ts` | ダミーデータ |
| `src/lib/dummyData.ts` | ダミーデータ生成ヘルパー |

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
