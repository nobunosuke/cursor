# .cursor/ の Git 管理方法の修正とルール構成の再設計

別のプロジェクトで `.git/info/exclude` を使った方法を試したところ、worktree 作成時に `.cursor/` ディレクトリが引き継がれない問題が発生した。

この問題を解決するため、以下を実施：
1. `SETUP_SHARED_RULES.md` のセットアップ手順を修正
2. ルール構成を再設計（`workflows/` → `git/`、`task.mdc` → `cursor-tasks.mdc`）
3. コミット時のルールを明確化（新規 `git/commit.mdc` を作成）

## 背景

### 問題点
- `SETUP_SHARED_RULES.md` の「ステップ2: `.git/info/exclude` に追加」が誤り
- `.git/info/exclude` に追加すると、Git 管理外になるため worktree に引き継がれない
- `.gitignore` と同じ挙動になる

### 解決方針
- **チームで Cursor 管理を適用していないプロジェクト向け**の運用方法を明確化
- `.gitignore` には書かない → `.cursor/` を Git 管理下に置く
- **コミット時に必ず `.cursor/` を除外する**運用ルールを確立
- worktree でも引き継がれる仕組みを維持
- ルール構成を再設計し、Git/GitHub ルールと Cursor タスク管理ルールを明確に分離

## Completed Tasks

- [x] ルール構成の再設計
  - `workflows/` → `git/` に変更
  - `task.mdc` → `cursor-tasks.mdc` に変更してルート直下に移動
  - ファイル構成を Git/GitHub ルールと Cursor タスク管理ルールに明確に分離
- [x] `git/commit.mdc` を新規作成
  - `.cursor/` 除外の必須ルールを明記
  - Conventional Commits 規約を記載
  - コミット前のチェックリスト
  - トラブルシューティング（誤って add/commit/push した場合の対処法）
- [x] `cursor-tasks.mdc` の修正
  - コミットメッセージ規約部分を削除
  - `@git/commit.mdc` への参照に変更
  - コミットタイミングの判断ロジックを明確化
- [x] `git/worktree.mdc` の修正
  - `.cursor/` 引き継ぎの仕組みを説明
  - プッシュ前の詳細な注意事項を削除（commit.mdcへの参照に変更）
  - 参照パスを更新
- [x] `SETUP_SHARED_RULES.md` の修正
  - 「ローカルコミットOK」の記述を削除
  - 「コミット時に必ず除外」の正しい運用に修正
  - ステップ2「.git/info/exclude に追加」を削除
  - 新セクション「ステップ3: .cursor/ の運用ルール（個人利用時）」を追加
  - アーキテクチャ図を新しいルール構成に更新
  - コマンド早見表を更新
- [x] 全ファイルの参照パスを更新
  - `global.mdc` の参照を更新
  - `git/issue.mdc` の参照を更新
  - すべて新しいファイル構成に対応

## In Progress Tasks

なし

## Future Tasks

なし

## Implementation Plan

### 目標
- チームで Cursor を使っていないプロジェクトでも、個人が `.cursor/` を活用できるようにする
- `.cursor/` がリモートにプッシュされないよう、明確な運用ルールを提供する
- worktree 使用時も `.cursor/` が正しく引き継がれるようにする
- ルール構成を最適化し、AI と人間の両方にとって理解しやすい構造にする

### アーキテクチャ

#### 従来の方法（誤り）
```
プロジェクトA/
  .cursor/rules/         # ローカルで管理
  .git/info/exclude      # .cursor/ を除外 ← これが問題
```
→ worktree を作ると `.cursor/` が引き継がれない

#### 正しい方法
```
プロジェクトA/
  .cursor/
    rules/
      cursor-tasks.mdc   # Cursorタスク管理ルール
      git/               # Git/GitHubルール
        commit.mdc       # コミットルール（.cursor/除外含む）
        worktree.mdc
        issue.mdc
        pr.mdc
      global.mdc
    tasks/               # タスクファイル
  # .gitignore には書かない
  # .git/info/exclude にも書かない
  # コミット時に必ず除外
```
→ worktree でも引き継がれる ✅
→ コミット前に必ず `git restore --staged .cursor/` で除外

### 運用ルール

#### プッシュ前のチェックリスト
1. `git status` で `.cursor/` が含まれていないか確認
2. もし含まれていたら除外する

#### 誤って add した場合
```bash
git restore --staged .cursor/
```

#### 誤ってコミットした場合
```bash
# 直前のコミットから .cursor/ を除外
git reset HEAD~
git add .  # .cursor/ 以外を add（または個別に指定）
git commit -m "..."

# または rebase で修正
git rebase -i HEAD~N
```

### 新しいルール構成

```
.cursor/rules/
  cursor-tasks.mdc      # Cursorタスク管理（workflows/task.mdcから移動・リネーム）
  git/                  # Git/GitHubルール（workflows/から移動）
    commit.mdc          # 【新規】コミットルール（.cursor/除外含む）
    worktree.mdc
    issue.mdc
    pr.mdc
  global.mdc
```

**設計方針**:
- `cursor-tasks.mdc` は Cursor AI のタスク管理ルール
- `git/` は Git/GitHub の開発フロー
- 関心の分離により、AI と人間の両方が理解しやすい構造

## Relevant Files

- SETUP_SHARED_RULES.md - メインのセットアップ手順書 ✅
- .cursor/rules/cursor-tasks.mdc - Cursorタスク管理ルール（旧 task.mdc）✅
- .cursor/rules/git/commit.mdc - コミットルール（新規作成）✅
- .cursor/rules/git/worktree.mdc - worktree ワークフロー ✅
- .cursor/rules/git/issue.mdc - イシューワークフロー ✅
- .cursor/rules/global.mdc - グローバルルール ✅


