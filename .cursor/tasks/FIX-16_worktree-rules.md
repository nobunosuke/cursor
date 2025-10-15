# worktree が Cursor に読み込まれなかったので修正

`global.mdc` の記述が原因で、AIが worktree ではなく `git checkout -b` を使用してしまうバグを修正します。

## Completed Tasks

- [x] issue #16 用の worktree を作成
- [x] タスクファイルを作成
- [x] global.mdc を修正して worktree を明示的に推奨
- [x] 修正内容を確認
- [x] コミット・プッシュ

## In Progress Tasks

## Future Tasks

## Implementation Plan

### 問題点

`global.mdc` は `alwaysApply: true` で常に適用されるルールファイルですが、以下の記述が混乱を招いていました：

```markdown
2. **ブランチを作成**（AI or 手動）
   - AI: Cursorで「イシュー #42: ○○」と伝える → AIがブランチ作成
   - 手動: `git checkout -b feat/42-user-auth`
```

この例では、AIによるブランチ作成は言及されているものの、worktreeを使うべきかが不明確で、手動の例として `git checkout -b` が示されていたため、AIがこちらを参照してしまいました。

### 修正方針

1. **worktree を明示的に推奨する記述に変更**
   - 「基本的に worktree を使用する」ことを明記
   - 手動の例も `git worktree add` を使用
   - `git checkout -b` は例外的な場合のみと明記

2. **詳細は @workflows/worktree.mdc を参照するよう誘導**
   - `global.mdc` はクイックリファレンスとして簡潔に
   - 詳細なコマンドは専用のワークフローファイルに記載

### 修正内容

`global.mdc` の「開発フロー」セクション（29-40行目付近）を以下のように修正：

**修正前:**
```markdown
2. **ブランチを作成**（AI or 手動）
   - AI: Cursorで「イシュー #42: ○○」と伝える → AIがブランチ作成
   - 手動: `git checkout -b feat/42-user-auth`
```

**修正後:**
```markdown
2. **worktree でブランチを作成**（AI or 手動）
   - AI: Cursorで「イシュー #42: ○○」と伝える → AIが worktree として作成
   - 手動: `git worktree add ../worktrees/feat-42-user-auth -b feat/42-user-auth main`
   - 詳細は @workflows/worktree.mdc を参照
```

## Relevant Files

- `.cursor/rules/global.mdc` - 修正対象（開発フローの記述を修正）
- `.cursor/rules/workflows/worktree.mdc` - 参照用（worktree の詳細説明）
- `.cursor/rules/workflows/issue.mdc` - 参照用（ブランチ作成の詳細ロジック）

