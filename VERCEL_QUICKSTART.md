# ⚡ Vercelクイックスタート

食事中または食事後に**即座にデプロイ**して、デモを共有する方法です。

## 🚀 方法1: Vercel CLI（最速！）

### 1回目のデプロイ（初回のみ）

```bash
# Vercel CLIをインストール
npm install -g vercel

# Vercelにログイン
vercel login

# デプロイ（プロンプトに従って進む）
vercel

# 本番環境にデプロイ
vercel --prod
```

**所要時間: 約2-3分**

### 2回目以降のデプロイ

```bash
# コードを修正後
git add .
git commit -m "Update demo"

# デプロイ
vercel --prod
```

**所要時間: 約1分**

---

## 🌐 方法2: Vercelダッシュボード（推奨）

### Step 1: GitHubにプッシュ

```bash
# GitHub CLIでリポジトリ作成（推奨）
gh auth login
gh repo create p_demo --public --source=. --remote=origin --push

# または手動で
# 1. GitHubで新規リポジトリを作成
# 2. 以下を実行
git remote add origin https://github.com/YOUR_USERNAME/p_demo.git
git branch -M main
git push -u origin main
```

### Step 2: Vercelと連携

1. [Vercel Dashboard](https://vercel.com/new) にアクセス
2. "Import Git Repository" をクリック
3. GitHubアカウントと連携
4. `p_demo` リポジトリを選択
5. "Deploy" をクリック

**所要時間: 約3-5分（初回のみ）**

### Step 3: 自動デプロイ完了！

以降はGitHubにプッシュするだけで自動デプロイされます：

```bash
git add .
git commit -m "Update demo"
git push

# 自動的にVercelがデプロイ！（30秒〜1分）
```

---

## 📱 デプロイ後のURL

デプロイが完了すると、以下のようなURLが発行されます：

```
本番環境:
https://p-demo.vercel.app

プレビュー環境（ブランチごと）:
https://p-demo-git-feature-xxx.vercel.app
```

このURLを取引先に**即座に共有**できます！

---

## 🎯 食事中のデプロイフロー

### パターンA: 食事中に即デプロイ（CLI）

```bash
# デモを作成したら即座に
vercel --prod

# URLをメールやSlackで共有
# 「今作ったデモです！→ https://p-demo-xxx.vercel.app」
```

### パターンB: 食事後にデプロイ（GitHub連携）

```bash
# 食事後に落ち着いて
git add .
git commit -m "feat: 顧客管理システムのデモ"
git push

# 自動デプロイされる（Vercel連携済みの場合）
```

---

## ⚙️ 環境変数の設定（必要な場合）

### ローカル

```bash
# .env.localファイルを作成
cat > .env.local << EOF
NEXT_PUBLIC_APP_NAME="デモプロジェクト"
EOF
```

### Vercel

1. Vercelダッシュボード > プロジェクト選択
2. Settings > Environment Variables
3. 変数を追加
4. 再デプロイ

---

## 🔧 トラブルシューティング

### ビルドエラーが出る

```bash
# ローカルでビルドテスト
npm run build

# エラーがなければOK
# エラーがあれば修正してから再デプロイ
```

### デプロイが遅い

- 初回は3-5分かかることがあります
- 2回目以降は1-2分で完了します

### URLが動かない

- デプロイ完了まで数分待つ
- ブラウザのキャッシュをクリア（Cmd+Shift+R）

---

## 📊 Vercelの機能

### 自動プレビュー
- Pull RequestごとにプレビューURLが生成される
- レビューが簡単

### Analytics（分析）
- Vercelダッシュボードでアクセス解析
- どのページが見られているか確認可能

### カスタムドメイン
- 独自ドメインの設定も可能
- Settings > Domains から設定

---

## ✅ デプロイ完了チェックリスト

- [ ] Vercelアカウントを作成した
- [ ] プロジェクトがデプロイされた
- [ ] URLにアクセスして動作確認
- [ ] モバイルでも表示確認
- [ ] URLを取引先に共有

---

## 🎉 準備完了！

Vercelへのデプロイ準備は**完璧**です！

### 今すぐデプロイするなら：

```bash
# ターミナルで実行
vercel login
vercel --prod
```

### 後でデプロイするなら：

1. GitHubにプッシュ
2. Vercelダッシュボードで連携
3. 自動デプロイ

**どちらも簡単です！** 🚀

