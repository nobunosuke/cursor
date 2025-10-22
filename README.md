# Cursor Rules

Cursor環境でGitHubイシュー駆動開発を実現する、AI支援型のタスク管理システムです。

## 特徴

- **GitHubイシュー駆動**: すべての開発タスクはGitHubイシューから始まる
- **Git Worktree**: 複数イシューの並列開発をサポート
- **AI連携**: worktree作成、タスクファイル管理をAIが支援
- **Markdownチェックリスト**: `[ ]` / `[x]` で視覚的にタスクを管理

## クイックスタート

### 1. インストール

このルールをプロジェクトにインストール（詳細は後述）:

```bash
cd /path/to/your-project
rm -rf .cursor/rules
git clone -b production --depth 1 https://github.com/nobunosuke/cursor-rules.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp
git add .cursor/rules
git commit -m "feat: Cursor共有ルールを追加"
```

### 2. GitHubでイシューを作成

例: Issue #42「ユーザー認証機能を実装」

### 3. Cursorでイシュー情報をAIに伝える

```
イシュー #42 を作成しました。タイトルは「ユーザー認証機能を実装」です。
worktreeを作成してください。
```

### 4. AIが自動実行

- ブランチ名を生成・提案（例: `feat/42-user-authentication`）
- git worktreeとして作成
- タスクファイルを作成（`.cursor/tasks/FEAT-42_user-authentication.md`）

### 5. 作成されたworktreeをCursorで開く

```bash
cursor ../worktrees/feat-42-user-authentication
```

### 6. AIと一緒に開発

タスクファイルのチェックリストが自動更新されます：

```markdown
## In Progress Tasks
- [x] ユーザー認証用のJWTミドルウェアを実装
- [ ] ログイン画面のUIを作成
```

## 📦 インストール

**実行場所:** メインリポジトリのルートディレクトリ（`.git` があるディレクトリ）

### 推奨フォルダ構成

このルールは git worktree での開発を前提としています：

```
your-project/
  main/              ← ここでインストールコマンドを実行
    .git/
    .cursor/
      rules/         ← ここにルールがインストールされる
      tasks/
  worktrees/         ← 各イシュー用のworktreeディレクトリ
    feat-42-feature-a/
    feat-43-feature-b/
```

詳細は含まれているルール（`git/worktree.mdc`）を参照してください。

### コマンドで実行

```bash
# メインリポジトリのルートディレクトリで実行
cd /path/to/your-project/main

rm -rf .cursor/rules
git clone -b production --depth 1 https://github.com/nobunosuke/cursor-rules.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp
```

### スクリプトで実行

```bash
# メインリポジトリのルートディレクトリで実行
cd /path/to/your-project/main

curl -sSL https://raw.githubusercontent.com/nobunosuke/cursor-rules/production/install-rules.sh | bash
```

### バージョン指定

```bash
# メインリポジトリのルートディレクトリで実行
cd /path/to/your-project/main

git clone -b production https://github.com/nobunosuke/cursor-rules.git .cursor/rules-temp
cd .cursor/rules-temp && git checkout v1.0.0 && cd ..
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp
```

## 📚 ドキュメント

インストール後、以下のルールファイルを参照してください：

### コアルール
- **cursor-tasks.mdc** - タスク管理の基本ルール（命名規則、ファイル構造、AIの振る舞い）
- **global.mdc** - ルールシステム全体のナビゲーション

### Git関連ルール
- **git/issue.mdc** - worktree・タスクファイル作成支援
- **git/worktree.mdc** - Git Worktreeの使い方（並列開発）
- **git/commit.mdc** - コミットメッセージ規約（Conventional Commits）
- **git/pr.mdc** - PRメッセージ作成ルール
- **git/merge-strategy.mdc** - ブランチマージ戦略

## 📁 フォルダ構成

```
your-project/
  .cursor/
    rules/                 # ← このリポジトリから取得
      cursor-tasks.mdc
      global.mdc
      git/
        commit.mdc
        issue.mdc
        pr.mdc
        worktree.mdc
        merge-strategy.mdc
    tasks/                 # ← 各プロジェクトのタスクファイル（自分で作成）
      FEAT-42_feature.md
```

## 🔄 更新

```bash
# メインリポジトリのルートディレクトリで実行
cd /path/to/your-project/main

rm -rf .cursor/rules
git clone -b production --depth 1 https://github.com/nobunosuke/cursor-rules.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp
git add .cursor/rules
git commit -m "chore: Cursor共有ルールを最新版に更新"
```

## 🔧 トラブルシューティング

### ❌ `.cursor/rules/rules/` になってしまう（二重ネスト）

**原因:** 既存の `.cursor/rules` がある状態で `mv` を実行

**解決策:**
```bash
# メインリポジトリのルートディレクトリで実行
rm -rf .cursor/rules
# その後、通常のインストール手順を実行
```

**修正方法:**
```bash
# 既に二重ネストしてしまった場合（メインリポジトリのルートで実行）
mv .cursor/rules/rules .cursor/rules-fixed
rm -rf .cursor/rules
mv .cursor/rules-fixed .cursor/rules
```

## 開発に参加したい方へ

このプロジェクトへの貢献を検討されている方は、mainブランチの [DEVELOPMENT.md](https://github.com/nobunosuke/cursor-rules/blob/main/DEVELOPMENT.md) を参照してください。

開発環境のセットアップ、ブランチ戦略、貢献方法などを記載しています。

## 参考

- [playbooks.com - Task Lists](https://playbooks.com/rules/task-lists) - タスクファイルの構造化手法

## 📄 License

MIT
