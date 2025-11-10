/**
 * サンプルダミーデータ
 * 食事中に与件を聞いたら、このファイルに必要なダミーデータを追加してください
 */

import { generateRandomName, generateRandomEmail, generateId, generateArray } from '@/lib/dummyData';
import { User } from '@/types';

// サンプル: ユーザーデータ
export const sampleUsers: User[] = generateArray(10, (i) => ({
  id: generateId('user-'),
  name: generateRandomName(),
  email: generateRandomEmail(),
  createdAt: new Date(),
  updatedAt: new Date(),
}));

// ここに与件に応じたダミーデータを追加していきます
// 例:
// export const sampleProducts = [...];
// export const sampleOrders = [...];
// export const sampleTransactions = [...];

