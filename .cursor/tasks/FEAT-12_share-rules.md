# このリポジトリのルールを他のリポジトリでも使用したい

このリポジトリで管理している `.cursor/rules` を、他のプロジェクトでも使えるようにする仕組みを作る。プロジェクト固有のルール（要件定義など）との共存方法も検討する必要がある。

## Completed Tasks

- [x] Cursor のルール共有の方法をネットで調査
  - 公式ドキュメントの確認
  - コミュニティでの事例調査
  - ベストプラクティスの確認
- [x] プロジェクト固有ルールと共通ルールの共存方法を検討
  - ディレクトリ構造の設計
  - 命名規則の検討
  - 優先順位の仕組み
- [x] 実装方針を決定
  - ハイブリッド案（選択肢BとCの組み合わせ）を採用
  - Git Submodule + シンボリックリンクで実現
- [x] セットアップ手順のドキュメント作成
  - SETUP_SHARED_RULES.md を作成
  - README.md に概要を追加
- [x] シンプルなコピー方式のドキュメント作成
  - `.git/info/exclude` を使ってローカルで管理
  - 他のプロジェクトには手動でコピー
  - README と SETUP_SHARED_RULES.md に記載
  - 将来の拡張（Submodule 方式）も記載

## In Progress Tasks

なし

## Future Tasks

- [ ] 既存プロジェクトでの動作検証
- [ ] 実装後の振り返りとルールの改善

### 将来の拡張: Git Submodule 方式のセットアップ

より高度な管理が必要になった場合、Git Submodule 方式に移行する：

1. **cursor-workflow-rules リポジトリを作成**
   ```bash
   mkdir cursor-workflow-rules
   cd cursor-workflow-rules
   git init
   cp -r /path/to/cursor/.cursor/rules/* .
   git add .
   git commit -m "feat: 初期バージョン"
   git remote add origin https://github.com/your-username/cursor-workflow-rules.git
   git push -u origin main
   ```

2. **各プロジェクトで Submodule として使用**
   ```bash
   cd /path/to/your-project
   git submodule add https://github.com/your-username/cursor-workflow-rules.git .cursor-shared
   mkdir -p .cursor/rules
   ln -s ../../.cursor-shared/global.mdc .cursor/rules/global.mdc
   ln -s ../../.cursor-shared/workflows .cursor/rules/workflows
   git add .gitmodules .cursor-shared .cursor/rules/
   git commit -m "feat: Cursor共有ルールを追加"
   ```

3. **更新**
   ```bash
   git submodule update --remote .cursor-shared
   git add .cursor-shared
   git commit -m "chore: 共有ルールを最新版に更新"
   ```

詳細は [SETUP_SHARED_RULES.md](../../SETUP_SHARED_RULES.md) を参照。

## Implementation Plan

### 目標
- このリポジトリの `.cursor/rules` を複数のプロジェクトで共有できるようにする
- プロジェクト固有のルールとバッティングしないようにする
- メンテナンス性を保つ（マスターで更新したら、各プロジェクトに反映できる）

### アーキテクチャ

**採用: シンプルなコピー方式**
- このリポジトリの `.cursor/rules` を他のプロジェクトに手動でコピー
- `.git/info/exclude` を使ってローカルで管理（リモートにはプッシュしない）
- 更新時は再度コピーする
- シンプルで分かりやすい

**将来の拡張（オプション）**: Git Submodule 方式
- より高度な管理が必要な場合は SETUP_SHARED_RULES.md を参照
- 現時点ではオーバースペックなので採用しない

#### リポジトリ構成

```
cursor-workflow-rules/  ← 新しい共有ルール専用リポジトリ
  global.mdc
  workflows/
    task.mdc
    issue.mdc
    pr.mdc
    worktree.mdc
  README.md  # セットアップ手順
```

#### 各プロジェクトでの構成

```
プロジェクトA/
  .cursor-shared/        # git submodule
    global.mdc
    workflows/
      task.mdc
      ...
  .cursor/
    rules/
      global.mdc → ../.cursor-shared/global.mdc        # シンボリックリンク
      workflows/ → ../.cursor-shared/workflows/        # シンボリックリンク
      requirements.mdc                                  # プロジェクト固有
      architecture.mdc                                  # プロジェクト固有
```

### データフロー

```
cursor-workflow-rules リポジトリ
    ↓ (git submodule add)
プロジェクトA/.cursor-shared/
    ↓ (シンボリックリンク)
プロジェクトA/.cursor/rules/
    ↓ (Cursor が読み込み)
Cursor AI（共有ルール + プロジェクト固有ルール）
```

### 調査結果

#### Cursor の `.mdc` ファイルの仕様（✅ 完了）
`.mdc` ファイルは以下の構造を持つ：

```yaml
---
description: ルールの説明
alwaysApply: true/false  # 常に適用するかどうか
---

# ルールの内容（Markdown形式）
```

- **`alwaysApply: true`**: 常に適用される（例: `global.mdc`, `workflows/task.mdc`）
- **`alwaysApply: false`**: 必要に応じて参照される（例: `workflows/issue.mdc`）
- **`@` 参照構文**: `@workflows/task.mdc` のように他のルールを参照可能

#### 共有方法の比較（✅ 完了）

**1. Git Submodule（最有力候補）**
- メリット:
  - 共有ルールの一元管理が可能
  - 各プロジェクトで最新のルールを簡単に取得できる
  - バージョン管理が明確
- デメリット:
  - サブモジュールの管理がやや複雑
  - プロジェクト固有のルールとの統合に工夫が必要

**2. Git Subtree**
- メリット:
  - サブモジュールよりも管理が容易
  - プロジェクトに完全に統合される
- デメリット:
  - 更新の同期が複雑
  - プロジェクトごとに更新の適用が必要

**3. テンプレートリポジトリ**
- メリット:
  - 新規プロジェクトの初期設定が容易
- デメリット:
  - 既存プロジェクトへの適用が難しい
  - ルールの更新を反映させるのが困難

**4. スクリプトによる同期**
- メリット:
  - シンプルな仕組み
- デメリット:
  - 手動での同期作業が必要
  - バージョン管理が曖昧

#### 推奨アプローチ（暫定）

**Git Submodule + シンボリックリンク（パターン3）** を使用する方法が最適と判断。

### プロジェクト固有ルールと共通ルールの共存方法（✅ 完了）

**採用するパターン: パターン3（フラットに配置）**

```
プロジェクトA/
  .cursor/
    rules/
      # ===== 共有ルール（シンボリックリンク） =====
      global.mdc → ../.cursor-shared/.cursor/rules/global.mdc
      workflows/ → ../.cursor-shared/.cursor/rules/workflows/
      
      # ===== プロジェクト固有のルール =====
      requirements.mdc
      architecture.mdc
```

**理由:**
- `@workflows/task.mdc` の参照パスが変わらない（最重要）
- 共有ルールとプロジェクト固有ルールが同じディレクトリに配置され、Cursor が自然に認識
- シンボリックリンクで実ファイルは Submodule で管理
- ファイル名の衝突に注意すれば、管理が容易

### 実装方法の3つの選択肢

**選択肢A: このリポジトリ全体を Submodule として追加**
```bash
cd /path/to/project-a
git submodule add https://github.com/your/cursor.git .cursor-shared
ln -s ../.cursor-shared/.cursor/rules/global.mdc .cursor/rules/global.mdc
ln -s ../.cursor-shared/.cursor/rules/workflows .cursor/rules/workflows
```
- メリット: このリポジトリをそのまま利用
- デメリット: 不要なファイル（README.md など）も含まれる

**選択肢B: `.cursor/rules` だけを別リポジトリとして切り出す**
```bash
# 新しいリポジトリ cursor-workflow-rules を作成
cd /path/to/project-a
git submodule add https://github.com/your/cursor-workflow-rules.git .cursor-shared
ln -s ../.cursor-shared/global.mdc .cursor/rules/global.mdc
ln -s ../.cursor-shared/workflows .cursor/rules/workflows
```
- メリット: 共有ルールだけを管理、クリーンな構造
- デメリット: 新しいリポジトリを作成する必要がある

**選択肢C: `.cursor/rules` 自体を Submodule にする（高度）**
```bash
cd /path/to/project-a
git submodule add https://github.com/your/cursor-workflow-rules.git .cursor/rules
# プロジェクト固有のルールは .gitignore で管理
```
- メリット: シンボリックリンク不要
- デメリット: プロジェクト固有ルールの管理が複雑

### 推奨: 選択肢B

新しいリポジトリを作成し、`.cursor/rules` だけを管理する方法が最もクリーンで管理しやすい。

### その他の考慮事項
- 共有ルールの更新: `git submodule update --remote`
- プロジェクトごとのカスタマイズ: プロジェクト固有ルールを `.cursor/rules/` に直接追加
- バージョン管理: Submodule の commit hash で管理
- ファイル名の衝突: 共有ルールとプロジェクト固有ルールでファイル名が重複しないよう注意

## Relevant Files

- `.cursor/rules/` - 共有したいルール群
  - `global.mdc` - グローバルルール
  - `workflows/task.mdc` - タスク管理ルール
  - `workflows/issue.mdc` - イシュー駆動開発ルール
  - `workflows/pr.mdc` - PRメッセージ作成ルール
  - `workflows/worktree.mdc` - Git Worktree ルール
- `README.md` - プロジェクトのドキュメント ✅
- `SETUP_SHARED_RULES.md` - 共有ルールのセットアップ手順 ✅
- `.cursor/tasks/FEAT-12_share-rules.md` - このタスクファイル

