/**
 * ダミーデータ生成ユーティリティ
 * 食事中に素早くダミーデータを生成するためのヘルパー関数
 */

// ランダムな日本の名前を生成
const firstNames = ['太郎', '花子', '次郎', '美咲', '健太', '由美', '翔太', 'さくら', '大輔', '愛'];
const lastNames = ['田中', '鈴木', '佐藤', '高橋', '渡辺', '伊藤', '山本', '中村', '小林', '加藤'];

export const generateRandomName = (): string => {
  const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
  const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
  return `${lastName} ${firstName}`;
};

// ランダムなメールアドレスを生成
export const generateRandomEmail = (name?: string): string => {
  const domains = ['example.com', 'test.jp', 'demo.co.jp', 'sample.jp'];
  const domain = domains[Math.floor(Math.random() * domains.length)];
  const prefix = name ? name.replace(/\s/g, '.').toLowerCase() : `user${Math.floor(Math.random() * 10000)}`;
  return `${prefix}@${domain}`;
};

// ランダムな電話番号を生成
export const generateRandomPhone = (): string => {
  const areaCode = ['03', '06', '045', '075', '092'];
  const area = areaCode[Math.floor(Math.random() * areaCode.length)];
  const number = Math.floor(Math.random() * 90000000) + 10000000;
  return `${area}-${number.toString().slice(0, 4)}-${number.toString().slice(4)}`;
};

// ランダムな日付を生成
export const generateRandomDate = (startDate: Date, endDate: Date): Date => {
  const start = startDate.getTime();
  const end = endDate.getTime();
  return new Date(start + Math.random() * (end - start));
};

// ランダムな数値を生成
export const generateRandomNumber = (min: number, max: number): number => {
  return Math.floor(Math.random() * (max - min + 1)) + min;
};

// ランダムな金額を生成
export const generateRandomPrice = (min: number = 1000, max: number = 100000): number => {
  return Math.floor(Math.random() * (max - min + 1) / 100) * 100 + min;
};

// ランダムなステータスを生成
export const generateRandomStatus = <T extends string>(statuses: T[]): T => {
  return statuses[Math.floor(Math.random() * statuses.length)];
};

// ランダムなテキストを生成
const loremIpsum = [
  '迅速な対応が必要です',
  '品質を重視しています',
  '顧客満足度を向上させたい',
  'コスト削減が課題です',
  '業務効率化を図りたい',
  '売上向上を目指しています',
  'ユーザー体験の改善が必要',
  'データ分析を活用したい'
];

export const generateRandomText = (sentences: number = 1): string => {
  const result = [];
  for (let i = 0; i < sentences; i++) {
    result.push(loremIpsum[Math.floor(Math.random() * loremIpsum.length)]);
  }
  return result.join('。') + '。';
};

// 配列からランダムに要素を選択
export const pickRandom = <T>(array: T[]): T => {
  return array[Math.floor(Math.random() * array.length)];
};

// ランダムな配列を生成
export const generateArray = <T>(length: number, generator: (index: number) => T): T[] => {
  return Array.from({ length }, (_, i) => generator(i));
};

// IDを生成
let idCounter = 1;
export const generateId = (prefix: string = ''): string => {
  return `${prefix}${idCounter++}`;
};

export const resetIdCounter = (): void => {
  idCounter = 1;
};

