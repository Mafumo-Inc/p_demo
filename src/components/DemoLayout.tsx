/**
 * デモ用の基本レイアウトコンポーネント
 */

import React from 'react';

interface DemoLayoutProps {
  children: React.ReactNode;
  title?: string;
  description?: string;
}

export default function DemoLayout({ children, title, description }: DemoLayoutProps) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
      {/* ヘッダー */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">
                {title || 'デモプロジェクト'}
              </h1>
              {description && (
                <p className="text-sm text-gray-600 mt-1">{description}</p>
              )}
            </div>
            <div className="text-sm text-gray-500">
              Demo Build
            </div>
          </div>
        </div>
      </header>

      {/* メインコンテンツ */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>

      {/* フッター */}
      <footer className="bg-white border-t mt-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <p className="text-center text-sm text-gray-500">
            © 2025 Demo Project - All data is dummy data for demonstration purposes
          </p>
        </div>
      </footer>
    </div>
  );
}

