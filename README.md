## 概要
写真検索と閲覧ができるアプリケーション

## ブランチ命名規則
ブランチ名の先頭には変更内容を示すプレフィックスを付けます。
- `impl_XXX`：新しい機能の実装
- `add_XXX`：小規模な追加や補助的な要素
- `fix_XXX`：バグや不具合の修正
- `update_XXX`：既存機能や設定の更新、ライブラリのアップデート

### 使用例
- 写真検索機能の実装 → `impl_photo_search`
- ログイン画面にボタンを追加 → `add_login_button`
- ページネーションの不具合修正 → `fix_search_pagination`
- CI設定の更新 → `update_ci_config`

### 運用ルール
すべての変更は `main` ブランチへ直接 push せず、必ずPullRequestを通してマージします。
