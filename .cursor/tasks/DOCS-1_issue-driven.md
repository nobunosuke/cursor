# Cursorでのタスク管理システム実装

Cursor環境でブランチベースのタスク管理フローを確立し、AIと協力して効率的に開発を進められる仕組みを構築する。

## Completed Tasks

- [x] タスクファイルの構造をplaybooks.com形式に整備
- [x] 開発フローのルールファイル（02-workflow.mdc）を作成
- [x] タスク管理ルール（01-task.mdc）にplaybooks.com方式を統合
- [x] グローバルルール（00-global.mdc）を更新して新しいワークフローを参照
- [x] 実際の動作を検証（このタスク自体で検証）
- [x] README.mdに開発フローのドキュメントを追加
- [x] 01-task.mdcと02-workflow.mdcを統合（開発フローを一元化）

## In Progress Tasks

## Future Tasks

## Implementation Plan

### 目標
1. ブランチ名（例: `docs/1-issue-driven`）から自動でタスクファイル名（例: `DOCS-1_issue-driven.md`）を推測
2. AIがタスクファイルの有無をチェックし、なければ作成を提案
3. マークダウンチェックリスト（`[ ]` / `[x]`）でタスク進捗を管理
4. すべてのチェックが完了したら、AIがコミット・プッシュを提案

### ブランチとタスクファイルの対応規則
- ブランチ名: `{type}/{id}-{description}` （例: `docs/1-issue-driven`）
- タスクファイル名: `{TYPE}-{ID}_{description}.md` （例: `DOCS-1_issue-driven.md`）
- 配置場所: `.cursor/tasks/`

### タスクファイルの構造（playbooks.com方式）
- **Completed Tasks**: 完了したタスク
- **In Progress Tasks**: 現在進行中のタスク
- **Future Tasks**: 今後実装予定のタスク
- **Implementation Plan**: 実装の詳細計画
- **Relevant Files**: 関連ファイルとその説明

### AIの動作
1. ユーザーがAIを呼び出した際、現在のブランチ名を確認
2. 対応するタスクファイルが存在しない場合、作成を提案
3. タスク実装後、該当タスクを自動的に完了（`[x]`）にマーク
4. Relevant Filesセクションを自動更新
5. すべてのタスクが完了したら、コミット・プッシュを提案

## Relevant Files

- `.cursor/rules/00-global.mdc` - グローバルルール ✅
- `.cursor/rules/01-task.mdc` - タスク管理と開発フローの統合ルール ✅
- `.cursor/rules/02-workflow.mdc` - 削除（01-task.mdcに統合） ✅
- `.cursor/tasks/DOCS-1_issue-driven.md` - このタスクファイル ✅
- `README.md` - プロジェクトのドキュメント ✅

