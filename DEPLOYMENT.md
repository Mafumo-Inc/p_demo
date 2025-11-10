# 🚀 デプロイガイド

食事中または食事後にデモを共有したい場合のデプロイ手順です。

## 📦 GitHub連携

### 1. GitHubリポジトリの作成

```bash
# GitHubでリポジトリを作成後、以下を実行
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git branch -M main
git add .
git commit -m "Initial commit: Demo project setup"
git push -u origin main
```

または、GitHub CLIを使用:

```bash
# GitHub CLIのインストール（Macの場合）
brew install gh

# GitHubにログイン
gh auth login

# リポジトリを作成してプッシュ
gh repo create p_demo --public --source=. --remote=origin
git add .
git commit -m "Initial commit: Demo project setup"
git push -u origin main
```

## 🌐 Vercel連携

### 方法1: Vercel CLI（最速）

```bash
# Vercel CLIをインストール（初回のみ）
npm install -g vercel

# Vercelにログイン
vercel login

# デプロイ
vercel

# 本番環境にデプロイ
vercel --prod
```

デプロイ後、URLが発行されるのでそのまま共有できます！

### 方法2: Vercelダッシュボード（推奨）

1. [Vercel](https://vercel.com) にアクセスしてログイン
2. "Add New Project" をクリック
3. GitHubリポジトリを連携
4. `p_demo` リポジトリを選択
5. "Deploy" をクリック

**メリット:**
- GitHubにプッシュするだけで自動デプロイ
- プレビューURLが自動生成
- ロールバックが簡単

## 🔧 環境変数の設定（必要な場合）

### ローカル（.env.local）

```bash
# .env.localファイルを作成
cat > .env.local << EOF
NEXT_PUBLIC_APP_NAME="デモプロジェクト"
# 必要に応じて環境変数を追加
EOF
```

### Vercel

1. Vercelダッシュボードでプロジェクトを選択
2. Settings > Environment Variables
3. 必要な環境変数を追加

## 🎯 デプロイ後のチェックリスト

- [ ] デプロイURLにアクセスして動作確認
- [ ] モバイルでの表示確認
- [ ] ダミーデータが正しく表示されているか
- [ ] 全てのページが正常に動作するか

## 📱 URLの共有

デプロイ後、以下のようなURLが発行されます:

- **本番環境**: `https://p-demo-xxxx.vercel.app`
- **プレビュー**: `https://p-demo-git-branch-xxxx.vercel.app`

このURLを取引先に共有して、デモを見せることができます！

## 🔄 継続的デプロイ

GitHubとVercelを連携した場合:

```bash
# コードを修正
git add .
git commit -m "Update demo"
git push

# 自動的にVercelがデプロイ！
```

数秒〜数分で変更が反映されます。

## 🛑 デプロイの削除

デモが不要になった場合:

### Vercel
1. Vercelダッシュボード
2. プロジェクト設定
3. "Delete Project"

### GitHub
```bash
# ローカル
gh repo delete YOUR_USERNAME/p_demo

# またはGitHub WebUIから削除
```

## 💡 Tips

- **カスタムドメイン**: Vercelで独自ドメインを設定可能
- **パスワード保護**: Vercelの環境変数で簡易的な認証を追加可能
- **Analytics**: Vercelダッシュボードでアクセス解析が見れる

---

**デモを世界に公開しましょう！** 🌍

