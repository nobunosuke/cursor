# 共有ルールのセットアップ手順（Git Submodule 方式）

このドキュメントでは、`.cursor/rules/` を Git Submodule として他のプロジェクトで使用するための手順を説明します。

## 概要

このリポジトリ（`cursor-workspace`）の `.cursor/rules/` を、専用リポジトリ（`cursor-rules`）に切り出し、Git Submodule として複数のプロジェクトで共有します。

### Git Submodule 方式のメリット

- ルールの変更は専用リポジトリでのみ行う（厳格な一元管理）
- `git submodule update --remote` で簡単に最新版を取得
- 特定のコミットに固定可能（バージョン管理）
- worktree との相性が良い（シンボリックリンク不要）
- 個人利用にもチーム開発にも対応

### アーキテクチャ

```
このリポジトリ（cursor-workspace）
  .cursor/
    rules/      # ← これを切り出す
    tasks/
  README.md
  SETUP_SHARED_RULES.md

      ↓ (切り出して専用リポジトリを作成)

cursor-rules リポジトリ（新規作成・公開）
  rules/
    global.mdc
    cursor-tasks.mdc
    git/
      commit.mdc
      issue.mdc
      pr.mdc
      worktree.mdc
  README.md

      ↓ (git submodule add)

プロジェクトA/
  .gitmodules           # Submodule の設定
  .cursor/
    rules/              # Submodule（cursor-rulesへの参照）
    tasks/              # プロジェクトAのタスクファイル
```

---

## セットアップ手順

### 前提条件

専用リポジトリ `cursor-rules` (https://github.com/nobunosuke/cursor-rules) が作成済みであることを前提とします。

### ステップ1: プロジェクトに Submodule を追加

```bash
# プロジェクトのルートディレクトリで実行
cd /path/to/your-project

# Submodule として追加
git submodule add https://github.com/nobunosuke/cursor-rules.git .cursor/rules

# 結果を確認
git status
# → 以下が表示される:
#    new file:   .gitmodules
#    new file:   .cursor/rules
```

### ステップ2: .cursor/tasks/ ディレクトリを確認

```bash
# 既存のタスクファイルがある場合はそのまま使用
ls -la .cursor/
# → rules/  (Submodule)
# → tasks/  (既存または新規作成)

# ない場合は作成
mkdir -p .cursor/tasks
```

### ステップ3: コミット

```bash
# 変更をコミット
git add .gitmodules .cursor/rules
git commit -m "feat: Cursor共有ルールをSubmoduleとして追加"

# プッシュ
git push origin <branch-name>
```

**補足**: `.cursor/rules` をコミットしていますが、実ファイルは含まれません。

含まれるもの：
- 「cursor-rules リポジトリの特定のコミット（abc123 など）を参照する」という情報だけ

これにより：
- プロジェクトAのリポジトリサイズは増えない
- ルールファイルの実体は cursor-rules リポジトリで一元管理される

### ステップ4: 動作確認

```bash
# Cursor で開き直す
cursor .

# AI に質問して、ルールが適用されているか確認
# 例: 「現在のブランチに対応するタスクファイルを確認して」
```

---

## Submodule の更新方法

### ケース1: cursor-rules が更新されたとき

```bash
# プロジェクトAで最新版を取得
cd /path/to/project-a
git submodule update --remote .cursor/rules

# 変更を確認
git status
# → .cursor/rules に変更があることが表示される

# 新しいバージョンをコミット
git add .cursor/rules
git commit -m "chore: Cursor共有ルールを最新版に更新"
git push
```

`git submodule update --remote` で cursor-rules の最新版を取得すると、プロジェクトAは「新しいコミットハッシュを参照する」というコミットを作成します。実ファイルはプロジェクトAのリポジトリに含まれません。

### ケース2: 特定のバージョンに固定したいとき

```bash
# Submodule ディレクトリに移動
cd .cursor/rules

# 特定のコミットをチェックアウト
git checkout v1.0.0  # タグを指定
# または
git checkout abc123  # コミットハッシュを指定

# プロジェクトAに戻る
cd ../..

# 変更をコミット
git add .cursor/rules
git commit -m "chore: Cursor共有ルールをv1.0.0に固定"
git push
```

---

## 基本コマンド

```bash
# Submodule を追加
git submodule add <URL> .cursor/rules

# Submodule を初期化（clone 後）
git submodule update --init --recursive

# Submodule を最新版に更新
git submodule update --remote .cursor/rules
```

**重要**: worktree は Submodule の参照を自動的に引き継ぎます。シンボリックリンク不要！
