/**
 * メインページ
 * 食事中の与件に応じて、このページを修正してデモを作成してください
 */

import DemoLayout from '@/components/DemoLayout';
import Card from '@/components/Card';
import { sampleUsers } from '@/data/sampleData';

export default function Home() {
  return (
    <DemoLayout
      title="デモプロジェクト"
      description="与件に応じてこのページをカスタマイズしてください"
    >
      <div className="space-y-8">
        {/* ウェルカムセクション */}
        <Card title="プロジェクト準備完了">
          <div className="space-y-4">
            <p className="text-gray-700">
              このプロジェクトは食事中に素早くデモを作成するための環境です。
            </p>
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h4 className="font-semibold text-blue-900 mb-2">次のステップ:</h4>
              <ol className="list-decimal list-inside space-y-2 text-blue-800">
                <li>REQUIREMENTS.md に与件をメモしてください</li>
                <li>src/types/index.ts に必要な型を定義してください</li>
                <li>src/data/sampleData.ts にダミーデータを追加してください</li>
                <li>このpage.tsxを編集してUIを構築してください</li>
              </ol>
            </div>
          </div>
        </Card>

        {/* サンプルデータ表示 */}
        <Card title="サンプル: ユーザーリスト">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {sampleUsers.slice(0, 6).map((user) => (
              <div
                key={user.id}
                className="border border-gray-200 rounded-lg p-4 hover:border-blue-400 transition-colors"
              >
                <div className="flex items-start space-x-3">
                  <div className="w-12 h-12 bg-gradient-to-br from-blue-400 to-purple-500 rounded-full flex items-center justify-center text-white font-bold">
                    {user.name.charAt(0)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-gray-900 truncate">
                      {user.name}
                    </p>
                    <p className="text-sm text-gray-600 truncate">{user.email}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>
          <p className="text-sm text-gray-500 mt-4">
            このサンプルは削除して、実際のデモ内容に置き換えてください。
          </p>
        </Card>

        {/* クイックスタート */}
        <Card title="開発コマンド">
          <div className="space-y-3">
            <div className="flex items-center space-x-2 font-mono text-sm">
              <span className="text-gray-500">開発サーバー:</span>
              <code className="bg-gray-100 px-3 py-1 rounded">npm run dev</code>
            </div>
            <div className="flex items-center space-x-2 font-mono text-sm">
              <span className="text-gray-500">ビルド:</span>
              <code className="bg-gray-100 px-3 py-1 rounded">npm run build</code>
            </div>
            <div className="flex items-center space-x-2 font-mono text-sm">
              <span className="text-gray-500">本番起動:</span>
              <code className="bg-gray-100 px-3 py-1 rounded">npm run start</code>
            </div>
          </div>
        </Card>
      </div>
    </DemoLayout>
  );
}
