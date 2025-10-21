# Cursor Rules

Cursor環境でのイシュー駆動開発とタスク管理のための共有ルール集。

## 📦 クイックスタート

```bash
# プロジェクトに追加
git submodule add https://github.com/horinoburo/cursor-rules.git .cursor/rules

# 最新版に更新
git submodule update --remote .cursor/rules

# clone後に初期化
git submodule update --init --recursive
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

## 🚀 使い方

### 1. プロジェクトに追加

```bash
cd /path/to/your-project
git submodule add https://github.com/horinoburo/cursor-rules.git .cursor/rules
mkdir -p .cursor/tasks
git commit -m "feat: Cursor共有ルールを追加"
```

### 2. 開発フロー

1. GitHubでイシュー作成（例: #42）
2. worktreeでブランチ作成
   ```bash
   git worktree add ../worktrees/feat-42-feature -b feat/42-feature main
   cd ../worktrees/feat-42-feature
   git submodule update --init  # 初回のみ
   ```
3. Cursorで開いて開発開始
   - AIがタスクファイル（`FEAT-42_feature.md`）を作成・更新
   - イシュー番号でブランチとタスクファイルが自動連携

### 3. ルールを更新

```bash
# 最新版を取得
git submodule update --remote .cursor/rules

# 変更をコミット
git add .cursor/rules
git commit -m "chore: Cursor共有ルールを更新"
```

## 🔧 よく使うコマンド

```bash
# Submodule の状態確認
git submodule status

# Submodule を特定バージョンに固定
cd .cursor/rules
git checkout v1.0.0
cd ../..
git add .cursor/rules
git commit -m "chore: ルールをv1.0.0に固定"

# worktree一覧
git worktree list

# worktree削除
git worktree remove ../worktrees/feat-42-feature
```

## 📁 ディレクトリ構成

```
your-project/
  .gitmodules              # Submodule設定
  .cursor/
    rules/                 # このリポジトリ（Submodule）
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

## 🤝 Contributing

個人用ですが、改善案があれば Issue か PR をどうぞ。

## 📄 License

MIT

