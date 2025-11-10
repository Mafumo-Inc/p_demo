/**
 * 共通型定義
 * プロジェクトで使用する基本的な型をここに定義
 */

// 基本的なエンティティの型
export interface BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

// サンプル: ユーザー型（必要に応じて修正・削除）
export interface User extends BaseEntity {
  name: string;
  email: string;
  phone?: string;
  avatar?: string;
}

// サンプル: ステータス型（必要に応じて修正・削除）
export type Status = 'active' | 'inactive' | 'pending' | 'completed';

// API レスポンス型
export interface ApiResponse<T> {
  data: T;
  message?: string;
  error?: string;
}

// ページネーション型
export interface Pagination {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: Pagination;
}

