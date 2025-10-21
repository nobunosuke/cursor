# Git Submodule で `.cursor/` を複数リポジトリで共有する

## 課題

このリポジトリの `.cursor/` ディレクトリを複数のプロジェクトで共有したい。

**`.cursor/` に定義する内容**:
- 開発プロセスのルール（イシュー駆動開発、タスク管理、Git運用など）
- AIとの建設的な会話をするためのルール（コミュニケーションの取り方、期待する振る舞いなど）

**プロジェクト固有の情報は `.cursor/` に含めない**:
- Linter設定、アーキテクチャ、言語固有のルールなど → `docs/` に記載

**FEAT-12 との違い**:
- FEAT-12: シンプルなコピー方式をドキュメント化
- FEAT-24: Git Submodule による自動同期を実装（更新の連携が容易）

## Completed Tasks

- [x] Git Submodule の基礎知識を整理
  - Submodule とは何か、メリット・デメリット、基本コマンド
  - タスクファイルに詳細を記載
- [x] 実装方針の決定
  - `.cursor/rules/` だけを Submodule にする
  - リポジトリ名は `cursor-rules`
  - `.cursor/tasks/` は通常のファイルとして管理
- [x] .cursor/rules/ の全ルールファイルを Submodule 方式に更新
  - `git/commit.mdc` - シンプルなコミット規約に全面書き直し（.gitignore 関連を削除）
  - `git/worktree.mdc` - Submodule の初期化手順を追加、.gitignore 関連を削除
  - `global.mdc` - 参照を更新
  - `cursor-tasks.mdc` - コミット関連の記述を更新
- [x] README.md と SETUP_SHARED_RULES.md を更新
  - 古いコピー方式の記述を削除
  - Submodule 方式の詳細なドキュメントに全面書き換え
  - .gitignore 関連の記述を全て削除（.cursor/tasks/ も普通にコミット）
  - セットアップ手順、トラブルシューティング、FAQ を追加
- [x] リポジトリ名の決定とドキュメント更新
  - 新規リポジトリ名: `cursor-rules`
  - 親リポジトリリネーム: `cursor` → `cursor-workspace`
  - タスクファイル、README、SETUP_SHARED_RULES の記述を更新
  - .gitignore の誤った記述を削除（`.cursor/tasks/` は通常のファイルとして管理）
- [x] 専用リポジトリ `cursor-rules` の作成準備
  - `.cursor-rules-repo/` ディレクトリに構造を準備
  - README.md を作成（簡潔でクイックアクセス重視）
  - LICENSE を作成（MIT）
  - .gitignore を作成
  - `.cursor/rules/` の内容をコピー
- [x] GitHubアカウント名の修正
  - `horinoburo` → `nobunosuke` に全ドキュメントを更新
- [x] 専用リポジトリ `cursor-rules` の作成とプッシュ
  - GitHub でリポジトリ作成（Public）
  - `.cursor-rules-repo/` の内容をプッシュ
- [x] このリポジトリでの Submodule 設定
  - `.cursor/rules/` を削除
  - `git submodule add` で Submodule として追加
  - 動作確認完了

## In Progress Tasks

なし

## Future Tasks
- [ ] 実際のプロジェクトで動作検証
  - 既存の2つのプロジェクトに Submodule を適用
  - worktree 環境での動作確認
  - 更新フローの確認
- [ ] このリポジトリのリネーム（オプション）
  - GitHub で `cursor` → `cursor-workspace` にリネーム
  - ローカルのリモートURL更新

## Implementation Plan

### 目標

`.cursor/` を Git Submodule として管理し、複数のプロジェクトで共有・自動同期できるようにする。

### Git Submodule とは

**概要**:
- リポジトリの中に別のリポジトリを参照する仕組み
- サブモジュールは独立したGitリポジトリとして管理される
- 親リポジトリは特定のコミットハッシュを参照する

**イメージ**:
```
プロジェクトA/
  .git/
  src/
  .cursor/  ← これが Submodule（別リポジトリへの参照）
    .git    ← ファイル（親リポジトリの .git/modules/ へのポインタ）
    rules/
    tasks/
```

**メリット**:
- 一元管理: `.cursor/` の更新を1箇所で管理
- 自動同期: `git submodule update --remote` で最新版を取得
- バージョン管理: 特定のコミットに固定可能（安定性）

**デメリット**:
- 初期セットアップがやや複雑
- チームメンバーも Submodule の理解が必要
- clone 時に `--recurse-submodules` が必要

**基本コマンド**:
```bash
# Submodule を追加
git submodule add <リポジトリURL> <配置先パス>

# Submodule を初期化（clone 後）
git submodule update --init --recursive

# Submodule を最新版に更新
git submodule update --remote

# Submodule を削除
git submodule deinit <パス>
git rm <パス>
```

### アーキテクチャ

**ステップ1: 専用リポジトリの作成**

```
新規リポジトリ: cursor-rules
  .cursor/
    rules/
      global.mdc
      cursor-tasks.mdc
      git/
        commit.mdc
        issue.mdc
        pr.mdc
        worktree.mdc
    tasks/  # 空ディレクトリ（各プロジェクトで使用）
  README.md
  LICENSE
```

**ステップ2: 各プロジェクトで Submodule として使用**

```
プロジェクトA/
  .git/
  src/
  docs/              # プロジェクト固有の情報
    architecture.md
    linter.md
  .cursor/           # Submodule
    rules/           # 共有ルール
    tasks/           # プロジェクトAのタスク（Git管理外）
```

### データフロー

```
cursor-rules リポジトリ（マスター）
    ↓ (git submodule add)
プロジェクトA/.cursor/
プロジェクトB/.cursor/
プロジェクトC/.cursor/
    ↓ (git submodule update --remote)
最新版を取得
```

### 実装手順

#### フェーズ1: Submodule の理解と方針決定

1. Git Submodule の動作を理解
2. `.cursor/` 全体 vs `.cursor/rules/` のみ、どちらを切り出すか決定
3. リポジトリ名、説明、ライセンスの決定

#### フェーズ2: 専用リポジトリの作成

1. GitHub で新しいリポジトリを作成
2. `.cursor/` の内容を移行
3. README, LICENSE を作成

#### フェーズ3: 動作検証

1. このリポジトリで Submodule として使ってみる
2. worktree 環境での動作確認
3. トラブルシューティング

#### フェーズ4: ドキュメント化

1. 利用手順を README に記載
2. SETUP_SHARED_RULES.md を更新
3. 実際のユースケースを追加

### 決定事項

#### 1. Submodule 方式を採用

- **理由**: 厳密な一元管理、worktree との相性、個人利用に最適
- **Subtree は不採用**: 各プロジェクトで独立して変更可能になり、一元管理できない

#### 2. `.cursor/rules/` だけを Submodule にする

- **構成**:
  ```
  プロジェクトA/
    .cursor/
      rules/  ← Submodule（読み取り専用、一元管理）
      tasks/  ← ローカル管理（プロジェクト固有）
  ```
- **理由**: 
  - `tasks/` はプロジェクト固有なのでローカルで管理
  - シンボリックリンク不要（Submodule が直接配置される）
  - worktree でも自動的に引き継がれる

#### 3. リポジトリ名

**決定**: `cursor-rules`（シンプルで分かりやすい）

**親リポジトリのリネーム**: `cursor` → `cursor-workspace`（実際のworktree作業場を表す）

### Submodule とコミットの関係

#### プロジェクトAでコミットしたとき、Submodule はどう扱われるか？

**重要**: Submodule の**ファイル自体はコミットに含まれません**。

**コミットに含まれるもの**:
1. `.gitmodules` ファイル（Submodule の設定）
   ```
   [submodule ".cursor/rules"]
       path = .cursor/rules
       url = https://github.com/nobunosuke/cursor-rules.git
   ```

2. Submodule ディレクトリへの**参照**（コミットハッシュ）
   ```bash
   # プロジェクトAのコミットには、こんな情報が含まれる：
   # ".cursor/rules は cursor-rules リポジトリの abc123 というコミットを参照"
   ```

**つまり**:
- ✅ プロジェクトAのリポジトリサイズは増えない
- ✅ `.cursor/rules/` の実ファイルは `cursor-rules` リポジトリで管理
- ✅ プロジェクトAは「どのバージョンを使うか」だけを記録

**コミット例**:
```bash
cd /path/to/project-a

# Submodule を追加
git submodule add https://github.com/nobunosuke/cursor-rules.git .cursor/rules

# この時点で git status を見ると：
$ git status
Changes to be committed:
  new file:   .gitmodules          # Submodule の設定
  new file:   .cursor/rules        # Submodule への参照（ファイルではない）

# コミット
git commit -m "feat: Cursor共有ルールをSubmoduleとして追加"

# .cursor/rules/ の実ファイルはコミットに含まれない！
# cursor-rules リポジトリへの参照だけが記録される
```

#### プロジェクトAのコミット履歴にルールファイルは含まれない

```bash
# プロジェクトAのコミット履歴を見ても
git log --oneline .cursor/rules/

# cursor-rules リポジトリのコミット履歴は表示されない
# 「Submoduleの参照を更新した」というコミットだけが表示される
```

これが**厳密な一元管理**を実現する仕組みです。

### 別プロジェクトでのセットアップ方法

#### パターンA: 新規プロジェクトでセットアップ

```bash
# 1. プロジェクトディレクトリに移動
cd /path/to/project-a

# 2. Submodule を追加
git submodule add https://github.com/your/cursor-rules.git .cursor/rules

# 3. .cursor/tasks/ 用のディレクトリを作成
mkdir -p .cursor/tasks

# 4. コミット
git add .gitmodules .cursor/rules
git commit -m "feat: Cursor共有ルールをSubmoduleとして追加"
git push
```

**結果**:
```
プロジェクトA/
  .gitmodules              # Submodule の設定
  .cursor/
    rules/                 # Submodule（cursor-rulesリポジトリ）
      global.mdc
      cursor-tasks.mdc
      git/
        commit.mdc
        ...
    tasks/                 # 通常のファイルとして管理（プロジェクト固有）
      （空）
```

#### パターンB: 既存リポジトリを clone した場合

```bash
# 1. リポジトリを clone
git clone https://github.com/your/project-a.git
cd project-a

# 2. Submodule を初期化・取得
git submodule update --init --recursive

# 3. .cursor/tasks/ を作成（必要に応じて）
mkdir -p .cursor/tasks

# 4. 完了！
```

**注意**: `git clone` だけでは Submodule は空のまま。必ず `git submodule update --init` を実行。

#### パターンC: worktree でブランチを切った場合

```bash
# メインリポジトリ
cd /path/to/project-a
git worktree add ../worktrees/feat-42-feature -b feat/42-feature

# worktree に移動
cd ../worktrees/feat-42-feature

# Submodule を初期化（初回のみ）
git submodule update --init

# 完了！.cursor/rules/ が使える
```

**重要**: worktree は Submodule の参照を自動的に引き継ぎます。シンボリックリンク不要！

### Submodule の更新方法

#### ケース1: cursor-rules が更新されたとき

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

**説明**:
- `git submodule update --remote` で cursor-rules の最新版を取得
- プロジェクトAは「新しいコミットハッシュを参照する」というコミットを作成
- 実ファイルはプロジェクトAのリポジトリに含まれない

#### ケース2: 特定のバージョンに固定したいとき

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
```

### トラブルシューティング

#### 問題1: Submodule が空のまま

```bash
# 症状
ls .cursor/rules/
# → 空

# 解決方法
git submodule update --init --recursive
```

#### 問題2: worktree で Submodule が使えない

```bash
# worktree に移動
cd ../worktrees/feat-42-feature

# Submodule を初期化
git submodule update --init

# ✅ 解決！
```

#### 問題3: Submodule 内で誤って変更してしまった

```bash
# Submodule ディレクトリに移動
cd .cursor/rules

# 変更を破棄
git reset --hard
git clean -fd

# プロジェクトAに戻る
cd ../..

# ✅ 元に戻った
```

**重要**: Submodule 内では変更しない。必ず cursor-rules リポジトリで変更してから、各プロジェクトで更新する。

### その他

- FEAT-12 で作成した SETUP_SHARED_RULES.md との関係性を整理
- シンプルコピー方式も残し、選択肢として提示
- Submodule を使わないプロジェクト向けのドキュメントも維持

## Relevant Files

- `.cursor/rules/` - Submodule として切り出す対象ディレクトリ
- `.cursor/rules/git/commit.mdc` - コミット時のルール ✅
- `.cursor/rules/git/worktree.mdc` - worktree との統合 ✅
- `.cursor/rules/global.mdc` - グローバルルール ✅
- `.cursor/rules/cursor-tasks.mdc` - タスク管理ルール ✅
- `README.md` - プロジェクトのメインドキュメント ✅
- `SETUP_SHARED_RULES.md` - 共有ルールのセットアップ手順（Git Submodule 方式） ✅
- `.cursor/tasks/FEAT-12_share-rules.md` - 関連タスク（旧・コピー方式、非推奨）
- `.cursor/tasks/FEAT-24_sync-rules-across-repos.md` - このタスクファイル

