# GitHubイシュー駆動開発フローの整理

GitHubでイシューを作成した後の開発フローをAIが自動化できるよう、新しいルールファイルを作成し、READMEに使い方を追記する。現在のフローは「既存ブランチありき」だが、新規イシューの場合はブランチが存在しないため、AIがイシュー情報からブランチ作成を提案する仕組みを整備する。

## Completed Tasks

- [x] `.cursor/tasks/DOCS-7_organize-flow-about-issue-to-task.md` を作成（このファイル）
- [x] `.cursor/rules/03-issue-workflow.mdc` を作成（イシュー駆動開発のAIルール）
- [x] `README.md` にイシュー駆動開発フローのセクションを追加
- [x] `.cursor/rules/00-global.mdc` のクイックリファレンスを更新
- [x] `03-issue-workflow.mdc` をDRY原則に従って簡潔化（309行 → 86行）
- [x] descriptionフォーマットを改善（ゴール・関連リンク追加）
- [x] 全ファイルで認識の齟齬を修正（イシュー駆動開発が基本であることを明確化）
- [x] `README.md` を修正（「2つの開発フロー」→「どこからAIに任せるか」）
- [x] `00-global.mdc` を修正（イシュー・ブランチ・タスクファイルの紐付けを明確化）
- [x] `01-task.mdc` を修正（すべてGitHubイシューに紐づくことを明記）
- [x] `03-issue-workflow.mdc` を修正（初期セットアップ支援としての位置づけを明確化）

## In Progress Tasks

## Future Tasks

## Implementation Plan

### 目標

1. GitHubでイシューを作成した後、AIがブランチ作成から開発まで支援できるようにする
2. ユーザーが自由形式でイシュー情報を伝えるだけで、AIが適切なブランチとタスクファイルを作成
3. イシューのdescription（詳細説明）をAIが生成し、GitHub UIにコピペできるようにする

### ワークフロー

**新規イシュー対応フロー**:
1. GitHub UI でイシューを作成（手動）
2. Cursorで「イシュー #42: ユーザー認証機能を実装」などと伝える
3. AIが現在のブランチをチェック（main/master/develop なら新規イシュー対応モード）
4. AIがイシュー内容からtypeを自動判定（feat/bug/docs/refactorなど）
5. AIがブランチ作成を提案: `git checkout -b {type}/{id}-{description}`
6. AIがイシューのdescription（詳細説明）を生成
7. ユーザーがdescriptionをGitHub UIにコピペ
8. AIが対応するタスクファイルを作成して開発開始

**既存ブランチからのフロー**（従来通り）:
1. ブランチを作成（手動またはAI支援）
2. AIを呼び出すと、タスクファイルの有無をチェック
3. なければ作成を提案
4. タスクを進めながら更新

### 技術的な詳細

#### Type自動判定ロジック
キーワードベースで判定:
- `feat`: 新機能、実装、追加
- `bug`/`fix`: バグ、修正、エラー
- `docs`: ドキュメント、README
- `refactor`: リファクタリング、改善、整理
- `test`: テスト
- デフォルト: `feat`

#### AIの判断フロー
```
ユーザー入力を受け取る
  ↓
「イシュー」「issue」「#」などのキーワードを検出
  ↓
現在のブランチをチェック
  ↓
main/master/develop → 新規イシュー対応モード
その他 → 既存フロー（01-task.mdc）
  ↓
イシュー情報を解析（番号、タイトル、type判定）
  ↓
ブランチ作成を提案
  ↓
description生成
  ↓
タスクファイル作成
```

## Relevant Files

- `.cursor/tasks/DOCS-7_organize-flow-about-issue-to-task.md` - このタスクファイル ✅
- `.cursor/rules/03-issue-workflow.mdc` - 新規作成したイシュー駆動開発AIルール ✅
- `.cursor/rules/00-global.mdc` - グローバルルール（クイックリファレンス更新） ✅
- `.cursor/rules/01-task.mdc` - 既存のタスク管理ルール（参照）
- `README.md` - プロジェクトドキュメント（イシュー駆動フローセクション追加） ✅

