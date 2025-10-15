# Rulesのワークフロー管理のためのディレクトリ構造改善

開発フローに関するrulesを、workflowなどの専用ディレクトリで管理することで、効率性と可読性を向上させる。

## Completed Tasks

- [x] Cursorの公式ドキュメントでrulesのベストプラクティスを調査
- [x] 現在のrulesの構造と内容を分析
- [x] rulesのディレクトリ構造に関するベストプラクティスを確認
- [x] ユーザーとの対話で要件とバックグラウンドを確認
- [x] 最終的なディレクトリ構造案の決定
- [x] workflows/ディレクトリの作成
- [x] ファイルの移動とリネーム
- [x] ファイル内の相互参照の更新
- [x] READMEの更新
- [x] 動作確認

## In Progress Tasks

なし

## Future Tasks

なし

## Implementation Plan

### 目標
- 開発フローに関するrulesを論理的に整理
- 関連するrulesをディレクトリでグルーピング
- rulesの発見性と保守性を向上

### アーキテクチャ

最終的な構造：
```
.cursor/rules/
  global.mdc                      # プロジェクト全体の基本方針（alwaysApply）
  workflows/                      # 開発フロー関連
    task.mdc                      # タスク管理の詳細ルール（alwaysApply）
    issue.mdc                     # イシュー→ブランチ→タスク作成フロー
    pr.mdc                        # PR作成フロー
```

設計の特徴：
- **番号プレフィックスを削除**: ディレクトリで分類するため不要に
- **workflows/ にタスク関連を集約**: task・issue・prは一連の開発フローとして関連
- **global.mdc はトップレベル**: alwaysApplyの重要なルールを目立たせる
- **拡張性**: 将来的に `coding/`, `testing/`, `architecture/` などのディレクトリ追加が容易

### データフロー
- Cursorは `.cursor/rules/` 配下のすべての `.mdc` ファイルを読み込む
- サブディレクトリに配置してもルールは正常に機能する

### その他
- 後方互換性の確保
- 既存のルール参照の維持

### 参考
- [Cursor Rules Documentation](https://cursor.com/docs/context/rules#rules) - Cursorの公式rulesドキュメント

## Relevant Files

- `.cursor/rules/global.mdc` - グローバルルール ✅
- `.cursor/rules/workflows/task.mdc` - タスク管理ルール ✅
- `.cursor/rules/workflows/issue.mdc` - イシューワークフロールール ✅
- `.cursor/rules/workflows/pr.mdc` - プルリクエストメッセージルール ✅

