# 共有ルールのセットアップ手順

このドキュメントでは、`.cursor/rules` を他のプロジェクトで使用するための手順を説明します。

## 概要

このリポジトリの `.cursor/rules` を、他のプロジェクトにコピーして使用します。

### シンプルな方式（推奨）

- `.cursor/rules` を他のプロジェクトにコピー
- `.git/info/exclude` を使ってローカルで管理（リモートにはプッシュしない）
- 更新時は再度コピーする
- シンプルで分かりやすい

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
  .cursor/rules/         # ローカルで管理
    global.mdc           # コピー
    workflows/           # コピー
      task.mdc
      issue.mdc
      pr.mdc
      worktree.mdc
    requirements.mdc     # プロジェクト固有
    architecture.mdc     # プロジェクト固有
  .git/info/exclude      # .cursor/rules を除外
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

### ステップ2: .git/info/exclude に追加してリモートにプッシュしない

```bash
# .git/info/exclude に追加（ローカルで管理、リモートにはプッシュしない）
echo ".cursor/" >> .git/info/exclude

# 確認
cat .git/info/exclude
```

**ポイント:**
- `.gitignore` ではなく `.git/info/exclude` を使う理由：
  - `.gitignore` はリポジトリで共有されるが、`.git/info/exclude` はローカルのみ
  - チームメンバーには影響を与えない
  - 各自が自由に共有ルールを使うかどうか選択できる

### ステップ3: プロジェクト固有のルールを追加（オプション）

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

### Q2: 共有ルールをリモートにプッシュしたい場合は？

`.git/info/exclude` から削除して、通常通り `git add` してコミットします：

```bash
# .git/info/exclude から削除
# （手動で編集）

# 通常通りコミット
git add .cursor/rules/
git commit -m "feat: Cursor共有ルールを追加"
git push
```

この場合、チームメンバーも自動的に共有ルールを取得できます。

### Q3: もっと高度な管理がしたい

Git Submodule を使った高度な管理方法については、このドキュメントの末尾の「高度な管理方法（オプション）」を参照してください。

---

## コマンド早見表

```bash
# === セットアップ ===
cd /path/to/your-project
mkdir -p .cursor/rules
cp -r /path/to/cursor/.cursor/rules/* .cursor/rules/
echo ".cursor/rules/" >> .git/info/exclude

# === 更新（全て上書き） ===
cp -r /path/to/cursor/.cursor/rules/* .cursor/rules/

# === 特定ファイルだけ更新 ===
cp /path/to/cursor/.cursor/rules/global.mdc .cursor/rules/global.mdc
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
