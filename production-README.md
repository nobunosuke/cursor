# Cursor Rules

Cursor環境でのイシュー駆動開発とタスク管理のための共有ルール集。

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

## 📚 含まれるルール

- **cursor-tasks.mdc** - タスク管理と開発フロー（[playbooks.com方式](https://playbooks.com/rules/task-lists)）
- **global.mdc** - プロジェクト全体のクイックリファレンス
- **git/commit.mdc** - コミットメッセージ規約（Conventional Commits）
- **git/issue.mdc** - GitHubイシュー駆動開発
- **git/pr.mdc** - プルリクエスト作成
- **git/worktree.mdc** - 並列開発（複数イシューの同時作業）
- **git/merge-strategy.mdc** - マージ戦略とコンフリクト解決

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

## 📄 License

MIT
