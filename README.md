# Rails Development Environment

個人開発用のRails環境です。Dockerを使用して環境を構築しています。

## 環境

- Ruby: 3.2.2
- Rails: 7.1.0
- PostgreSQL: 16
- Tailwind CSS

## セットアップ

1. リポジトリをクローン
```bash
git clone https://github.com/keita1899/docker_rails_template.git
cd docker_rails_template
```

2. コンテナをビルド
```bash
docker compose build
```

3. データベースを作成
```bash
docker compose run --rm web rails db:create
```

## 開発

1. アプリケーションを起動
```bash
docker compose up
```

2. ブラウザでアクセス
```
http://localhost:3001
```

## コマンド

- マイグレーション実行
```bash
docker compose run --rm web rails db:migrate
```

- テスト実行
```bash
docker compose run --rm web bundle exec rspec
```

## ポート

- Rails: 3001
- PostgreSQL: 5433

## 注意事項

- データベースのデータは `postgres_data` ボリュームに保存されます
- 必要に応じて リポジトリ名、リポジトリのURL、`docker-compose.yml` のポート番号を変更してください
