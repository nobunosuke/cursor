# 共有ルールのセットアップ手順

このドキュメントでは、`.cursor/rules` を他のプロジェクトで使用するための手順を説明します。

## 概要

このリポジトリの `.cursor/rules` を、他のプロジェクトにコピーして使用します。

### シンプルな方式（推奨）

- `.cursor/rules` を他のプロジェクトにコピー
- Git管理下に置く（コミット時は必ず `.cursor/` を除外）
- 更新時は再度コピーする
- シンプルで分かりやすい
- worktree でも正しく引き継がれる

### アーキテクチャ

```
このリポジトリ（cursor）
  .cursor/rules/
    global.mdc
    workflows/
      task.mdc
      issue.mdc
      pr.mdc
      worktree.mdc

      ↓ コピー

プロジェクトA/
  .cursor/rules/         # Git管理下（コミット時は除外）
    global.mdc           # コピー
    git/                 # コピー
      commit.mdc
      issue.mdc
      pr.mdc
      worktree.mdc
    cursor-tasks.mdc     # コピー
    requirements.mdc     # プロジェクト固有
    architecture.mdc     # プロジェクト固有
```

---

## セットアップ手順

### ステップ1: 他のプロジェクトに共有ルールをコピー

```bash
# プロジェクトのルートディレクトリで実行
cd /path/to/your-project

# .cursor/rules ディレクトリを作成（存在しない場合）
mkdir -p .cursor/rules

# このリポジトリから共有ルールをコピー
cp -r /path/to/cursor/.cursor/rules/* .cursor/rules/

# または、rsync を使う場合（既存ファイルを上書きしない）
# rsync -av --ignore-existing /path/to/cursor/.cursor/rules/ .cursor/rules/
```

### ステップ2: プロジェクト固有のルールを追加（オプション）

```bash
# プロジェクト固有のルールを追加
cat > .cursor/rules/requirements.mdc << 'EOF'
---
description: プロジェクトの要件定義ルール
alwaysApply: true
---

# 要件定義

（プロジェクト固有の内容を記述）
EOF
```

### ステップ3: .cursor/ の運用ルール（個人利用時）

**対象**: チームでCursorを使っていないプロジェクトで、個人的に `.cursor/` を活用する場合

#### 基本方針

`.cursor/` ディレクトリは**Git管理下に置きますが、コミット時には必ず除外します**。

```bash
# .cursor/ はGit管理下に置く（.gitignore に追加しない）
# worktree で引き継がれるようにするため

# ⚠️ コミット時は必ず除外
git add .  # すべてのファイルを add
git restore --staged .cursor/  # .cursor/ だけ除外
git commit -m "feat: 新機能を追加"
```

#### なぜ `.git/info/exclude` を使わないのか？

以前は `.git/info/exclude` に `.cursor/` を追加する方法を推奨していましたが、以下の問題があることが分かりました：

**問題点**:
- `.git/info/exclude` は `.gitignore` と同じ挙動（Git管理外）
- Git worktree 作成時に `.cursor/` が引き継がれない
- 並列開発で不便

**解決策**:
- `.cursor/` を Git 管理下に置く
- コミット時に必ず除外する（リモートにプッシュしない）
- この運用により worktree でも引き継がれる

#### コミット時のチェックリスト

**すべてのコミットで必ず実行してください：**

```bash
# 1. ファイルを add
git add .

# 2. .cursor/ を除外（必須）
git restore --staged .cursor/

# 3. ステージングエリアを確認
git status  # .cursor/ が含まれていないことを確認

# 4. コミット
git commit -m "feat: 新機能を追加"

# 5. プッシュ
git push origin <branch-name>
```

#### トラブルシューティング

##### 誤って .cursor/ を add してしまった場合

```bash
# ステージングエリアから削除（ファイルは残る）
git restore --staged .cursor/
```

##### 誤って .cursor/ をコミットしてしまった場合

```bash
# 方法1: 直前のコミットをやり直す
git reset HEAD~
git add .  # .cursor/ 以外を add（または個別にファイルを指定）
git commit -m "..."

# 方法2: rebase で修正
git rebase -i HEAD~N
# エディタで該当コミットを 'edit' に変更
git restore --staged .cursor/
git commit --amend
git rebase --continue
```

##### 誤って .cursor/ をリモートにプッシュしてしまった場合

```bash
# ⚠️ 注意: force push が必要です（チームへの影響を考慮してください）

# .cursor/ を削除
git rm -r --cached .cursor/
git commit -m "chore: .cursor/ をリポジトリから削除"

# 強制プッシュ（慎重に実行）
git push --force origin <branch-name>
```

#### git worktree との併用

`.cursor/` を Git 管理下に置くことで、worktree でも正しく引き継がれます：

```bash
# worktree を作成
git worktree add ../worktrees/feat-42-feature -b feat/42-feature main

# .cursor/ が自動的に引き継がれる ✅
cd ../worktrees/feat-42-feature
ls .cursor/  # ルールやタスクファイルが存在
```

詳細は共有ルール内の `@git/worktree.mdc` および `@git/commit.mdc` を参照してください。

### ステップ4: 動作確認

```bash
# Cursor で開き直す
cursor .

# AI に質問して、ルールが適用されているか確認
# 例: 「現在のブランチに対応するタスクファイルを確認して」
```

---

## 共有ルールの更新

このリポジトリ（cursor）で共有ルールを更新した場合、他のプロジェクトに再度コピーします。

### 方法1: 全て上書きコピー

```bash
cd /path/to/your-project
cp -r /path/to/cursor/.cursor/rules/* .cursor/rules/
```

**注意**: プロジェクト固有のルールも上書きされないよう注意してください。

### 方法2: 特定のファイルだけ更新

```bash
cd /path/to/your-project
cp /path/to/cursor/.cursor/rules/global.mdc .cursor/rules/global.mdc
cp /path/to/cursor/.cursor/rules/workflows/task.mdc .cursor/rules/workflows/task.mdc
```

---

## よくある質問

### Q1: プロジェクト固有のルールと共有ルールを区別したい

ファイル名で区別することをおすすめします：

```
.cursor/rules/
  global.mdc           # 共有ルール
  workflows/           # 共有ルール
  project-*.mdc        # プロジェクト固有（project- プレフィックス）
```

### Q2: チームでCursorを使っている場合は？

チームでCursorを使っている場合は、`.cursor/` をリモートにプッシュして共有することをおすすめします：

```bash
# 通常通りコミット
git add .cursor/rules/
git commit -m "feat: Cursor共有ルールを追加"
git push
```

この場合、チームメンバーも自動的に共有ルールを取得できます。

**メリット**:
- チーム全体で統一された開発環境
- 新メンバーのオンボーディングが簡単
- ルール更新が自動的に共有される

### Q3: もっと高度な管理がしたい

Git Submodule を使った高度な管理方法については、このドキュメントの末尾の「高度な管理方法（オプション）」を参照してください。

---

## コマンド早見表

```bash
# === セットアップ ===
cd /path/to/your-project
mkdir -p .cursor/rules
cp -r /path/to/cursor/.cursor/rules/* .cursor/rules/

# === 更新（全て上書き） ===
cp -r /path/to/cursor/.cursor/rules/* .cursor/rules/

# === 特定ファイルだけ更新 ===
cp /path/to/cursor/.cursor/rules/global.mdc .cursor/rules/global.mdc

# === プッシュ前の確認（個人利用の場合） ===
git status                        # .cursor/ が含まれていないか確認
git restore --staged .cursor/     # 含まれていたら除外
```

---

## 高度な管理方法（オプション）

より高度な管理が必要な場合（例: 複数のプロジェクトで常に最新の共有ルールを同期したい）は、Git Submodule を使った方法もあります。

### Git Submodule 方式の概要

1. 共有ルールを専用リポジトリ（cursor-workflow-rules）として切り出す
2. 各プロジェクトで Submodule として追加
3. シンボリックリンクで `.cursor/rules/` に配置

**メリット:**
- 共有ルールの一元管理
- `git submodule update` で簡単に更新

**デメリット:**
- セットアップが複雑
- Submodule の理解が必要
- チームメンバーも Submodule を理解する必要がある

### 詳細な手順

<details>
<summary>Git Submodule 方式の詳細手順（クリックで展開）</summary>

#### 1. cursor-workflow-rules リポジトリを作成

```bash
# 新しいディレクトリを作成
mkdir cursor-workflow-rules
cd cursor-workflow-rules
git init

# このリポジトリから .cursor/rules をコピー
cp -r /path/to/cursor/.cursor/rules/* .

# README を作成
cat > README.md << 'EOF'
# Cursor Workflow Rules

Cursor AI 用のワークフロー管理ルール集です。
EOF

# コミット & プッシュ
git add .
git commit -m "feat: 初期バージョン"
git remote add origin https://github.com/your-username/cursor-workflow-rules.git
git push -u origin main
```

#### 2. プロジェクトで Submodule として使用

```bash
# プロジェクトのルートディレクトリで実行
cd /path/to/your-project

# Submodule として追加
git submodule add https://github.com/your-username/cursor-workflow-rules.git .cursor-shared

# シンボリックリンクを作成
mkdir -p .cursor/rules
ln -s ../../.cursor-shared/global.mdc .cursor/rules/global.mdc
ln -s ../../.cursor-shared/workflows .cursor/rules/workflows

# コミット
git add .gitmodules .cursor-shared .cursor/rules/
git commit -m "feat: Cursor共有ルールを追加"
```

#### 3. 更新

```bash
# 最新版を取得
git submodule update --remote .cursor-shared

# 変更をコミット
git add .cursor-shared
git commit -m "chore: 共有ルールを最新版に更新"
```

</details>

---

## まとめ

**推奨**: シンプルなコピー方式
- 簡単でわかりやすい
- チームメンバーへの影響なし
- 個人での使用に最適

**将来の選択肢**: Git Submodule 方式
- チーム全体で統一的に管理したい場合
- 複数プロジェクトで常に最新版を同期したい場合
