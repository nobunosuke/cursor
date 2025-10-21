# Cursor タスク管理システム

このプロジェクトでは、Cursor環境でGitHubイシュー駆動開発を採用しています。AIと協力しながら効率的に開発を進めることができます。

## 概要

- **イシュー駆動開発**: すべての開発はGitHubイシューから始まる
- **ブランチとタスクファイルの紐付け**: 各イシューに対応するブランチとタスクファイルで進捗を管理
- **マークダウンチェックリスト**: `[ ]` / `[x]` で視覚的にタスクを管理
- **AI連携**: ブランチ作成、description生成、タスクファイル作成・更新をAIが支援

## 開発フロー

### 基本的な流れ

1. **GitHubでイシューを作成**
2. **git worktreeでブランチを作成**（AIまたは手動）
3. **イシューのdescriptionを作成**（AIまたは手動）
4. **タスクファイルで開発を進める**（AI支援）

> **注**: どこからAIに任せるかは自由です。すべて手動でも、すべてAIに任せても構いません。基本的にはgit worktreeでブランチを作成することを推奨します。

### パターン1: AIに全部任せる（推奨）

#### 手順

1. **GitHubでイシューを作成**（手動）
   - 例: Issue #42「ユーザー認証機能を実装」

2. **Cursorでイシュー情報をAIに伝える**
   ```
   イシュー #42 を作成しました。タイトルは「ユーザー認証機能を実装」です。
   ブランチを作成してください。
   ```

3. **AIが自動的に実行**
   - イシュー内容から適切なtype（feat/bug/docsなど）を判定
   - ブランチ名を生成・提案: `feat/42-user-authentication`
   - **git worktreeとしてブランチを作成**: `git worktree add ../worktrees/feat-42-user-authentication -b feat/42-user-authentication main`
   - イシューのdescription（詳細説明）を生成
   - タスクファイル（`.cursor/tasks/FEAT-42_user-authentication.md`）を作成

4. **GitHub UIでdescriptionをコピペ**
   - AIが生成したdescriptionをGitHubのイシューページに貼り付け

5. **作成されたworktreeをCursorで開く**
   - ターミナルで `cursor {worktree-path}` を実行（例: `cursor ../worktrees/feat-42-user-authentication`）
   - またはCursor UIから直接開く
   - AIと一緒にタスクを実装
   - タスクファイルが自動更新される

### パターン2: ブランチ・descriptionまで手動でやる

#### 手順

1. **GitHubでイシューを作成**（手動）
2. **git worktreeでブランチを作成**（手動）
   ```bash
   # メインリポジトリから実行
   git worktree add ../worktrees/feat-42-user-authentication -b feat/42-user-authentication main
   ```
3. **イシューのdescriptionを記述**（手動）
4. **作成したworktreeをCursorで開く**
   ```bash
   cursor ../worktrees/feat-42-user-authentication
   ```
   - 対応するタスクファイルが存在しない場合、AIが作成を提案
5. **開発を進める**
   - AIと一緒にタスクを実装
   - タスクファイルが自動更新される

### 共通: タスクを進める

AIと一緒にタスクを実装しながら、タスクファイルのチェックリストが自動更新されます：

```markdown
## In Progress Tasks
- [x] ユーザー認証用のJWTミドルウェアを実装
- [ ] ログイン画面のUIを作成
```

### 共通: 完了時のコミット

すべてのタスクが完了すると、AIがコミット・プッシュを提案します。

## Git Worktree の詳細

### 複数イシューの並列開発

基本的にgit worktreeを使用しますが、複数のイシューを同時に作業したい場合、複数のworktreeを作成することで、同じリポジトリの異なるブランチを並列で開発できます。

#### 基本的な使い方

```bash
# worktreeを作成（メインリポジトリから実行）
git worktree add ../worktrees/feat-42-feature-a feat/42-feature-a

# worktreeをCursorで開く
cursor ../worktrees/feat-42-feature-a

# worktree一覧を表示
git worktree list

# worktreeを削除
git worktree remove ../worktrees/feat-42-feature-a
```

#### AI駆動開発での活用

1. **複数のCursorウィンドウで並列作業**
   - ウィンドウ1: メインリポジトリで`main`ブランチ
   - ウィンドウ2: worktree Aで`feat/42-feature-a`ブランチ
   - ウィンドウ3: worktree Bで`feat/43-feature-b`ブランチ

2. **各ウィンドウで独立したAI作業**
   - 各worktreeには対応するタスクファイルが存在
   - AIは各worktreeで自動的に正しいブランチとタスクファイルを検出
   - 複数のイシューをAIに並列実装させることが可能

#### ディレクトリ構造例

```
~/projects/
  main/                          # メインリポジトリ
    .git/                        # Gitリポジトリ本体
      worktrees/                 # worktreeメタデータ
    .cursor/                     # mainブランチのCursor設定
      rules/
      tasks/
  
  worktrees/                     # worktree専用ディレクトリ
    feat-42-feature-a/          # worktree A
      .git                       # ファイル（main/.git/worktrees/へのポインタ）
      .cursor/                   # feat/42-feature-aブランチのCursor設定
      src/                       # feat/42-feature-aブランチの内容
    feat-43-feature-b/          # worktree B
      .git                       # ファイル（main/.git/worktrees/へのポインタ）
      .cursor/                   # feat/43-feature-bブランチのCursor設定
      src/                       # feat/43-feature-bブランチの内容
```

#### 重要なポイント

- 各worktreeディレクトリには、そのブランチのファイルが全てチェックアウトされます
- 各worktreeでCursorを開けば、それぞれ独立した環境として動作します
- worktree削除前に、作業中の変更はコミットまたは退避してください

詳細は [`.cursor/rules/workflows/worktree.mdc`](.cursor/rules/workflows/worktree.mdc) を参照してください。

## ブランチとタスクファイルの命名規則

### ブランチ名
`{type}/{id}-{description}`

例:
- `feat/42-user-authentication`
- `bug/123-fix-login-error`
- `docs/1-issue-driven`

### タスクファイル名
`{TYPE}-{ID}_{description}.md`

例:
- `.cursor/tasks/FEAT-42_user-authentication.md`
- `.cursor/tasks/BUG-123_fix-login-error.md`
- `.cursor/tasks/DOCS-1_issue-driven.md`

## タスクファイルの構造

各タスクファイルは[playbooks.com方式](https://playbooks.com/rules/task-lists)に従って構造化されています：

```markdown
# 機能名

機能の概要説明

## Completed Tasks
- [x] 完了したタスク1
- [x] 完了したタスク2

## In Progress Tasks
- [ ] 現在進行中のタスク1
- [ ] 現在進行中のタスク2

## Future Tasks
- [ ] 今後実装予定のタスク1

## Implementation Plan
実装の詳細計画

## Relevant Files
- path/to/file1.ts - ファイルの説明
- path/to/file2.ts - ファイルの説明
```

## 詳細なルール

プロジェクトの詳細なルールは以下のファイルを参照してください：

- [`.cursor/rules/global.mdc`](.cursor/rules/global.mdc) - グローバルルールとクイックリファレンス
- [`.cursor/rules/workflows/task.mdc`](.cursor/rules/workflows/task.mdc) - タスク管理と開発フローの統合ルール（命名規則、ファイル構造、AIの動作）
- [`.cursor/rules/workflows/issue.mdc`](.cursor/rules/workflows/issue.mdc) - GitHubイシュー駆動開発ワークフロー
- [`.cursor/rules/workflows/pr.mdc`](.cursor/rules/workflows/pr.mdc) - プルリクエストメッセージ作成ルール

## 他のプロジェクトで共有ルールを使う

このリポジトリの `.cursor/rules/` は、**production ブランチ**で公開されており、複数のプロジェクトから使用できます。

詳しくは **[SETUP_SHARED_RULES.md](SETUP_SHARED_RULES.md)** を参照してください。

### クイックスタート

```bash
# 他のプロジェクトで実行
cd /path/to/your-project

# production ブランチから .cursor/rules/ をクローン
git clone -b production --single-branch --depth 1 \
  https://github.com/nobunosuke/cursor-workspace.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# コミット
git add .cursor/rules
git commit -m "feat: Cursor共有ルールを追加"
```

**ポイント:**
- production ブランチには `.cursor/rules/` の内容のみが含まれる（タスクファイルなし）
- タグでバージョン管理（`v1.0.0`, `v1.1.0` など）
- 自分のプロジェクトでは `.cursor/tasks/` でタスク管理が可能
- 個人利用にもチーム開発にも対応

### ブランチ構成

このリポジトリは2つのブランチで管理されています：

- **main**: 開発用（`.cursor/rules/` + `.cursor/tasks/` + 開発ファイル）
- **production**: 公開用（`rules/` のみ、タスクファイルなし）

詳細は [`.cursor/rules/git/branch-strategy.mdc`](.cursor/rules/git/branch-strategy.mdc) を参照。

詳細な手順とトラブルシューティングは [SETUP_SHARED_RULES.md](SETUP_SHARED_RULES.md) を参照。

## 参考資料

- [playbooks.com - Task Lists](https://playbooks.com/rules/task-lists)
