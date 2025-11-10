# 🎯 クイックリファレンス

食事中に素早く参照できるチートシートです。

## 📝 よく使うコマンド

```bash
# 開発サーバー起動
npm run dev

# 新しいページ追加
# src/app/[ページ名]/page.tsx を作成

# 新しいコンポーネント追加
# src/components/[コンポーネント名].tsx を作成
```

## 🎨 利用可能なコンポーネント

### DemoLayout
```typescript
import DemoLayout from '@/components/DemoLayout';

<DemoLayout title="タイトル" description="説明">
  {/* コンテンツ */}
</DemoLayout>
```

### Card
```typescript
import Card from '@/components/Card';

<Card title="カードタイトル">
  {/* コンテンツ */}
</Card>
```

### Button
```typescript
import Button from '@/components/Button';

<Button variant="primary" size="md" onClick={handleClick}>
  クリック
</Button>

// variant: 'primary' | 'secondary' | 'danger' | 'success'
// size: 'sm' | 'md' | 'lg'
```

### Table
```typescript
import Table from '@/components/Table';

const columns = [
  { key: 'name', header: '名前' },
  { key: 'email', header: 'メール' },
  { key: 'status', header: 'ステータス', render: (item) => <Badge>{item.status}</Badge> },
];

<Table data={data} columns={columns} onRowClick={handleRowClick} />
```

### Badge
```typescript
import Badge from '@/components/Badge';

<Badge variant="success">完了</Badge>

// variant: 'default' | 'primary' | 'success' | 'warning' | 'danger' | 'info'
```

## 📊 ダミーデータ生成

```typescript
import {
  generateRandomName,
  generateRandomEmail,
  generateRandomPhone,
  generateRandomPrice,
  generateArray,
  generateId,
} from '@/lib/dummyData';

// 単一データ
const name = generateRandomName();        // "田中 太郎"
const email = generateRandomEmail();      // "user@example.com"
const phone = generateRandomPhone();      // "03-1234-5678"
const price = generateRandomPrice();      // 25000

// 配列データ
const users = generateArray(10, (i) => ({
  id: generateId('user-'),
  name: generateRandomName(),
  email: generateRandomEmail(),
}));
```

## 🎨 Tailwind CSS よく使うクラス

### レイアウト
```
grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4
flex items-center justify-between
space-y-4 space-x-4
```

### 余白
```
p-4 px-6 py-4         (padding)
m-4 mx-auto my-8      (margin)
```

### 色
```
bg-blue-600 text-white
bg-gray-100 text-gray-900
hover:bg-blue-700
```

### ボーダー
```
border border-gray-200 rounded-lg
shadow-md hover:shadow-lg
```

### テキスト
```
text-sm text-base text-lg text-xl
font-normal font-semibold font-bold
```

## 🔄 よくあるパターン

### リスト表示
```typescript
{items.map((item) => (
  <Card key={item.id} title={item.name}>
    <p>{item.description}</p>
  </Card>
))}
```

### グリッドレイアウト
```typescript
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {/* カード */}
</div>
```

### ステータス表示
```typescript
<Badge variant={status === 'active' ? 'success' : 'danger'}>
  {status}
</Badge>
```

### モーダル風の表示
```typescript
<div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
  <Card className="max-w-2xl w-full">
    {/* コンテンツ */}
  </Card>
</div>
```

## 📱 レスポンシブデザイン

```typescript
// モバイル: 1列、タブレット: 2列、デスクトップ: 3列
grid-cols-1 md:grid-cols-2 lg:grid-cols-3

// モバイルで非表示、デスクトップで表示
hidden lg:block

// テキストサイズの調整
text-sm md:text-base lg:text-lg
```

## 🎯 型定義のパターン

```typescript
// src/types/index.ts
export interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
  status: 'available' | 'out_of_stock';
  createdAt: Date;
}

// src/data/sampleData.ts
export const sampleProducts: Product[] = generateArray(20, (i) => ({
  id: generateId('prod-'),
  name: `商品${i + 1}`,
  price: generateRandomPrice(1000, 50000),
  category: pickRandom(['電子機器', '書籍', '食品', '衣類']),
  status: pickRandom(['available', 'out_of_stock']),
  createdAt: generateRandomDate(new Date(2024, 0, 1), new Date()),
}));
```

## 🚀 新しいページの追加

```bash
# 1. ページファイルを作成
# src/app/products/page.tsx

# 2. コンテンツを追加
export default function ProductsPage() {
  return (
    <DemoLayout title="商品一覧">
      {/* コンテンツ */}
    </DemoLayout>
  );
}

# 3. ブラウザで確認
# http://localhost:3000/products
```

## 💡 デバッグ

```typescript
// コンソールにデータ出力
console.log('データ:', data);

// 型チェック
const test: Product = sampleProducts[0]; // エラーが出れば型が間違っている
```

---

**このファイルをブラウザで開いておくと便利です！** 📖

