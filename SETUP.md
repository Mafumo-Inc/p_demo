# 🚀 クイックセットアップガイド

## プロジェクト概要
食事中に取引先の与件を聞きながら、素早くデモを作成するためのプロジェクトです。

## 技術スタック
- **Next.js 16** (App Router)
- **TypeScript**
- **Tailwind CSS**
- **React**

## 📁 プロジェクト構造

```
p_demo/
├── REQUIREMENTS.md          # 🔥 与件メモはここに！
├── SETUP.md                # このファイル
├── src/
│   ├── app/                # Next.js App Router
│   │   ├── page.tsx        # メインページ（デモのメイン画面）
│   │   ├── layout.tsx      # ルートレイアウト
│   │   └── globals.css     # グローバルスタイル
│   ├── components/         # 再利用可能なコンポーネント
│   │   ├── DemoLayout.tsx  # デモ用レイアウト
│   │   └── Card.tsx        # カードコンポーネント
│   ├── types/              # TypeScript型定義
│   │   └── index.ts        # 共通の型定義
│   ├── lib/                # ユーティリティ関数
│   │   └── dummyData.ts    # ダミーデータ生成ヘルパー
│   └── data/               # ダミーデータ
│       └── sampleData.ts   # サンプルダミーデータ
├── public/                 # 静的ファイル
└── package.json
```

## 🍽️ 食事中の作業フロー

### 1️⃣ 与件をヒアリング
食事が始まったら、取引先の要望を `REQUIREMENTS.md` にメモ

### 2️⃣ AIエージェントに指示
例: 
```
REQUIREMENTS.mdに以下を追加してください:
- 顧客管理システムを作りたい
- 顧客一覧、詳細、検索機能が必要
- 営業担当者も管理したい
```

### 3️⃣ 型定義とダミーデータを生成
- `src/types/index.ts` に必要な型を追加
- `src/data/sampleData.ts` にダミーデータを生成

### 4️⃣ UIを構築
- `src/app/page.tsx` をメインに編集
- 必要に応じてコンポーネントを追加

## 🛠️ 開発コマンド

```bash
# 開発サーバー起動（http://localhost:3000）
npm run dev

# ビルド
npm run build

# 本番サーバー起動
npm run start

# リントチェック
npm run lint
```

## 🎨 利用可能なユーティリティ

### ダミーデータ生成 (`src/lib/dummyData.ts`)
```typescript
import {
  generateRandomName,      // 日本の名前
  generateRandomEmail,     // メールアドレス
  generateRandomPhone,     // 電話番号
  generateRandomDate,      // 日付
  generateRandomNumber,    // 数値
  generateRandomPrice,     // 金額
  generateRandomStatus,    // ステータス
  generateRandomText,      // テキスト
  generateArray,           // 配列生成
  generateId,             // ID生成
} from '@/lib/dummyData';
```

### 基本コンポーネント
- `DemoLayout`: ヘッダー・フッター付きレイアウト
- `Card`: 美しいカードコンポーネント

## 📦 Vercelへのデプロイ（オプション）

食事後、デモを共有したい場合:

```bash
# Vercel CLIをインストール（初回のみ）
npm install -g vercel

# デプロイ
vercel
```

または、GitHubにプッシュしてVercelのWebダッシュボードから連携。

## 💡 ヒント

1. **型定義を先に**: 与件を聞いたら、まず型を定義すると開発がスムーズ
2. **ダミーデータは多めに**: 10〜20件あると見栄えが良い
3. **Tailwind CSS活用**: クラス名だけで美しいUIを素早く構築
4. **コンポーネント分割**: 同じUIは即座にコンポーネント化

## 🔄 次回の準備

プロジェクトをリセットして再利用する場合:

```bash
# REQUIREMENTS.mdをクリア
echo "# プロジェクト与件メモ" > REQUIREMENTS.md

# src/app/page.tsx を初期状態に戻す
# src/data/sampleData.ts をクリア
```

---

**準備完了！ 素晴らしいデモを作成してください！ 🎉**

