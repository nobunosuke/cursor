# Cursor Rules

Cursor環境でのイシュー駆動開発とタスク管理のための共有ルール集。

## 📦 クイックスタート

```bash
# プロジェクトのルートディレクトリで実行
cd /path/to/your-project

# production ブランチから .cursor/rules/ を取得
git clone -b production --single-branch --depth 1 \
  https://github.com/nobunosuke/cursor-rules.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# タスクディレクトリを作成（任意）
mkdir -p .cursor/tasks

# コミット
git add .cursor/
git commit -m "feat: Cursor共有ルールを追加"
git push
```

## 📚 含まれるルール

### グローバルルール
- **global.mdc** - プロジェクト全体のクイックリファレンス
- **cursor-tasks.mdc** - タスク管理と開発フロー（playbooks.com方式）

### Git ワークフロー
- **git/commit.mdc** - コミットメッセージ規約（Conventional Commits）
- **git/issue.mdc** - GitHubイシュー駆動開発
- **git/pr.mdc** - プルリクエストメッセージ作成
- **git/worktree.mdc** - git worktreeによる並列開発
- **git/merge-strategy.mdc** - マージ戦略とコンフリクト解決

## 🎯 特徴

- **イシュー駆動**: すべての開発はGitHubイシューから始まる
- **タスクファイル**: `.cursor/tasks/` でマークダウンチェックリストで進捗管理
- **worktree統合**: 複数イシューの並列開発をサポート
- **AI協調**: Cursorエージェントが自動でタスクファイルを更新

## 🔄 ルールの更新方法

### 最新版に更新

```bash
# 現在の .cursor/rules/ を削除
rm -rf .cursor/rules

# production ブランチの最新版を取得
git clone -b production --single-branch --depth 1 \
  https://github.com/nobunosuke/cursor-rules.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# 変更をコミット
git add .cursor/rules
git commit -m "chore: Cursor共有ルールを最新版に更新"
git push
```

### 特定のバージョンに固定

```bash
# 特定のタグをチェックアウト
git clone -b production --single-branch \
  https://github.com/nobunosuke/cursor-rules.git .cursor/rules-temp
cd .cursor/rules-temp
git checkout v1.0.0  # 特定のタグを指定
cd ..
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# 変更をコミット
git add .cursor/rules
git commit -m "chore: Cursor共有ルールをv1.0.0に固定"
git push
```

## 📁 ディレクトリ構成

```
your-project/
  .cursor/
    rules/                 # このリポジトリから取得
      global.mdc
      cursor-tasks.mdc
      git/
        commit.mdc
        issue.mdc
        pr.mdc
        worktree.mdc
        merge-strategy.mdc
    tasks/                 # プロジェクト固有のタスク
      FEAT-42_feature.md
```

## 🔗 詳細情報

このリポジトリは **production ブランチ**（orphan ブランチ）で公開されています。

- 開発用ブランチ（main）: `.cursor/rules/` + `.cursor/tasks/` + 開発ファイル
- 公開用ブランチ（production）: `rules/` のみ（タスクファイルなし）

タグでバージョン管理（`v1.0.0`, `v1.1.0` など）しています。

## 📄 License

MIT

