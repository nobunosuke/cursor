# Git Worktree による並列開発環境の構築

git worktreeを使用した複数ブランチの並列作業環境を整備し、AI駆動開発で複数のイシューを効率的に進められる仕組みを構築する。

## Completed Tasks

- [x] README.mdにgit worktreeのクイックリファレンスを追加
- [x] AI用のworktreeワークフロールール（`.cursor/rules/workflows/worktree.mdc`）を作成
- [x] 既存のワークフロー（issue.mdc, task.mdc, global.mdc）との統合方法を明確化
- [x] イシュー #11 のdescriptionを作成
- [x] ユーザーフィードバックを受けてworktreeの仕様を正確に修正
  - ディレクトリ構造の正確な記述
  - .cursor/が共有されるという誤りを修正
  - 不要なユースケース2, 3とトラブルシューティングを削除
  - 公式ドキュメントと参考リンクを追加
- [x] git worktreeを基本的なチェックアウト方法として位置づける
  - README.mdの開発フローをworktreeベースに変更
  - issue.mdcでデフォルトをworktreeに変更（通常のブランチ作成はオプション扱い）
  - worktree.mdcの概要を更新し、基本的な方法として明記
  - `cursor {directory}`コマンドの使い方を各ドキュメントに追記

## In Progress Tasks

## Future Tasks

## Implementation Plan

### 目標
1. git worktreeの基本的な使い方をREADME.mdに追加（クイックリファレンス形式）
2. AI用の詳細なワークフロールールを作成（`.cursor/rules/workflows/worktree.mdc`）
3. 既存のイシュー駆動開発ワークフローとの統合を明確化
4. 複数ブランチでAIに並列作業させるためのガイドラインを整備

### 背景
- AI駆動開発で複数のイシューを並列で進めたい
- git worktreeを使えば、同じリポジトリの異なるブランチを複数のディレクトリで同時に開ける
- 各worktreeで独立したCursorセッションを起動し、AIに並列作業させることが可能

### ユースケース
1. **複数イシューの並列作業**
   - イシュー #42（機能A）とイシュー #43（機能B）を同時に進める
   - worktree A: `feat/42-feature-a` ブランチ
   - worktree B: `feat/43-feature-b` ブランチ

2. **レビュー待ちブランチの保持**
   - PR作成済みのブランチをworktreeに残しつつ、新しい作業を開始

3. **AI並列作業**
   - Cursorウィンドウ1: worktree A で AI に機能Aを実装させる
   - Cursorウィンドウ2: worktree B で AI に機能Bを実装させる

### アーキテクチャ

#### ディレクトリ構造
```
~/projects/
  main/                          # メインリポジトリ（プライマリworktree）
    .git/                        # Gitリポジトリ本体
    .cursor/                     # Cursor設定（共有）
      rules/
      tasks/
    README.md
  
  worktrees/                     # worktree専用ディレクトリ
    feat-42-feature-a/          # worktree A
      .git                       # worktreeへのリンク
      src/                       # ブランチfeat/42-feature-aの内容
    feat-43-feature-b/          # worktree B
      .git                       # worktreeへのリンク
      src/                       # ブランチfeat/43-feature-bの内容
```

#### worktreeとタスクファイルの対応
- 各worktreeは異なるブランチをcheckout
- `.cursor/tasks/`は全worktreeで共有（メインリポジトリの`.git`に含まれる）
- AIは各worktreeで`git branch --show-current`を実行し、対応するタスクファイルを特定

### データフロー

1. **worktree作成**
   ```bash
   cd ~/projects/main
   git worktree add ../worktrees/feat-42-feature-a feat/42-feature-a
   ```

2. **Cursorで開く**
   - Cursorで`~/projects/worktrees/feat-42-feature-a`を開く
   - AIは現在のブランチ`feat/42-feature-a`を検出
   - 対応するタスクファイル`.cursor/tasks/FEAT-42_feature-a.md`を読み込み

3. **並列作業**
   - 別のCursorウィンドウで`~/projects/worktrees/feat-43-feature-b`を開く
   - 独立してタスクを進行

4. **worktree削除**
   ```bash
   git worktree remove ../worktrees/feat-42-feature-a
   ```

### 既存ワークフローとの統合

#### issue.mdcとの統合
- イシュー作成後、ブランチ作成時に**worktreeとして作成するか**をユーザーに確認
- worktreeとして作成する場合、適切なディレクトリに作成

#### task.mdcとの統合
- AIの`git branch --show-current`による検出は、worktree内でも正常に動作
- タスクファイルの作成・更新ロジックは変更不要
- `.cursor/tasks/`ディレクトリは全worktreeで共有

### その他

#### git worktreeの基本コマンド
```bash
# worktree追加
git worktree add <path> <branch>

# worktree一覧
git worktree list

# worktree削除
git worktree remove <path>

# 孤立したworktreeの削除
git worktree prune
```

#### 注意点
- `.cursor/`ディレクトリは全worktreeで共有される
- worktree削除時は、作業中の変更をコミットまたは退避すること
- worktreeのパスは相対パスでも絶対パスでも可

## Relevant Files

- `README.md` - git worktreeのクイックリファレンスを追加 ✅
- `.cursor/rules/workflows/worktree.mdc` - worktree用ワークフロールール ✅
- `.cursor/rules/workflows/issue.mdc` - イシューワークフロー（worktreeオプション追加） ✅
- `.cursor/rules/global.mdc` - グローバルルール（worktree言及追加） ✅
- `.cursor/tasks/DOCS-11_git-worktree.md` - このタスクファイル ✅

