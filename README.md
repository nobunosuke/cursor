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
2. **ブランチを作成**（AIまたは手動）
3. **イシューのdescriptionを作成**（AIまたは手動）
4. **タスクファイルで開発を進める**（AI支援）

> **注**: どこからAIに任せるかは自由です。すべて手動でも、すべてAIに任せても構いません。

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
   - ブランチ作成コマンドを実行
   - イシューのdescription（詳細説明）を生成
   - タスクファイル（`.cursor/tasks/FEAT-42_user-authentication.md`）を作成

4. **GitHub UIでdescriptionをコピペ**
   - AIが生成したdescriptionをGitHubのイシューページに貼り付け

5. **開発を進める**
   - AIと一緒にタスクを実装
   - タスクファイルが自動更新される

### パターン2: ブランチ・descriptionまで手動でやる

#### 手順

1. **GitHubでイシューを作成**（手動）
2. **ブランチを作成**（手動）
   ```bash
   git checkout -b feat/42-user-authentication
   ```
3. **イシューのdescriptionを記述**（手動）
4. **AIを呼び出す**
   - 現在のブランチ名を検出
   - 対応するタスクファイルが存在しない場合、作成を提案
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

## 参考資料

- [playbooks.com - Task Lists](https://playbooks.com/rules/task-lists)
