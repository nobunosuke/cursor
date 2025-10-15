# Cursor タスク管理システム

このプロジェクトでは、Cursor環境でブランチベースのタスク管理フローを採用しています。AIと協力しながら効率的に開発を進めることができます。

## 概要

- **ブランチベース**: 各ブランチに対応するタスクファイルで進捗を管理
- **マークダウンチェックリスト**: `[ ]` / `[x]` で視覚的にタスクを管理
- **AI連携**: AIがタスクファイルを自動検出・提案・更新

## クイックスタート

### 1. ブランチを作成

```bash
git checkout -b feat/42-user-authentication
```

### 2. AIを呼び出す

Cursorで AI Chat を開き、作業内容について質問すると、AIが自動的に：
- 現在のブランチ名（`feat/42-user-authentication`）を検出
- 対応するタスクファイル（`.cursor/tasks/FEAT-42_user-authentication.md`）の有無を確認
- 存在しない場合、作成を提案

### 3. タスクを進める

AIと一緒にタスクを実装しながら、タスクファイルのチェックリストが自動更新されます：

```markdown
## In Progress Tasks
- [x] ユーザー認証用のJWTミドルウェアを実装
- [ ] ログイン画面のUIを作成
```

### 4. 完了時のコミット

すべてのタスクが完了すると、AIがコミット・プッシュを提案します。

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

- [`.cursor/rules/00-global.mdc`](.cursor/rules/00-global.mdc) - グローバルルールとクイックリファレンス
- [`.cursor/rules/01-task.mdc`](.cursor/rules/01-task.mdc) - タスク管理と開発フローの統合ルール（命名規則、ファイル構造、AIの動作）

## 参考資料

- [playbooks.com - Task Lists](https://playbooks.com/rules/task-lists)
