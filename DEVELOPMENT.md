# Cursor Rules - 開発者向けドキュメント

このリポジトリは、Cursor環境でGitHubイシュー駆動開発を実現する、AI支援型のタスク管理システムです。

> **エンドユーザー向けドキュメント**: [README.md](README.md) を参照してください。

## このリポジトリについて

### 目的

Cursor環境でのイシュー駆動開発とタスク管理のためのルールセットを開発・公開する。

### ブランチ戦略

- **main**: 開発用ブランチ
  - `.cursor/rules/` - ルールのソース
  - `.cursor/tasks/` - 開発用タスクファイル
  - 開発ファイル（README.md, docs/, production-README.md など）

- **production**: 公開用ブランチ（orphan ブランチ）
  - `rules/` - エンドユーザーが取得する配布用ルール
  - README.md - エンドユーザー向けドキュメント（production-README.mdから生成）
  - LICENSE
  - install-rules.sh

詳細: [`docs/branch-strategy.md`](docs/branch-strategy.md)

## セットアップ（開発者向け）

### 前提条件

- Git worktreeを使用した開発環境
- Cursor IDE

### クローン

```bash
# メインリポジトリをクローン
git clone https://github.com/nobunosuke/cursor-rules.git main
cd main

# 開発用worktreeを作成（例）
git worktree add ../worktrees/feat-XX-feature-name -b feat/XX-feature-name main
cursor ../worktrees/feat-XX-feature-name
```

## 開発フロー

このリポジトリは、**自分自身のルールに従って開発**されています：

1. **GitHubでイシューを作成**
2. **Cursorでworktreeを作成**（AIに依頼可能）
3. **タスクファイルで開発**（`.cursor/tasks/` 配下）
4. **コミット・PR作成**（各ルールに従う）

### 開発時に参照すべきルール

開発中は以下のルールファイルを参照：

- [`.cursor/rules/global.mdc`](.cursor/rules/global.mdc) - ルールシステム全体のナビゲーション
- [`.cursor/rules/cursor-tasks.mdc`](.cursor/rules/cursor-tasks.mdc) - タスク管理の基本
- [`.cursor/rules/git/`](.cursor/rules/git/) - Git関連のワークフロー

## ディレクトリ構造

```
cursor-rules/
├── .cursor/
│   ├── rules/              # ルールのソース（main開発時に使用）
│   │   ├── cursor-tasks.mdc
│   │   ├── global.mdc
│   │   └── git/
│   │       ├── commit.mdc
│   │       ├── issue.mdc
│   │       ├── pr.mdc
│   │       ├── worktree.mdc
│   │       └── merge-strategy.mdc
│   └── tasks/              # 開発用タスクファイル
│       ├── FEAT-XX_feature.md
│       └── ref/
├── docs/                   # 設計ドキュメント
│   └── branch-strategy.md
├── .github/
│   └── workflows/
│       └── sync-production.yml  # main → production 自動同期
├── README.md               # エンドユーザー向け（production ブランチでも使用）
└── DEVELOPMENT.md          # このファイル（開発者向け）
```

## 貢献

### プルリクエスト

1. イシューを作成
2. worktreeでブランチを作成
3. ルールファイルを修正
4. タスクファイルに変更履歴を記録
5. PRを作成（`.cursor/rules/git/pr.mdc` に従う）

### 注意事項

- `.cursor/rules/` 配下のファイルは、production ブランチに自動同期されます
- `README.md` は production ブランチにもそのままコピーされます
- `DEVELOPMENT.md` は production ブランチには含まれません（開発者向け情報）
- タスクファイル（`.cursor/tasks/`）は production には含まれません

## エンドユーザー向け情報

エンドユーザー（cursor-rulesを使う人）向けの情報は [README.md](README.md) を参照してください。
