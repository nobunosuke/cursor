# [Cursor] rules を整える

このタスクでは、タスク管理ルールを改善し、タスクファイルの更新頻度を向上させ、参照情報を体系的に管理できるようにします。

## Completed Tasks

- [x] タスクファイル更新ルールを明確化・強化（playbooks.com ベストプラクティス反映）
  - 「チャット中の決定事項は即座にタスクファイルに反映」を明記
  - タスクベースの開発ワークフローを追加
- [x] 参照ファイルのセクションを簡潔に再構成
- [x] ref/ フォルダ名を維持（context/ 案は却下、使い捨て参照情報のため）
- [x] ref ファイルの命名規則を決定：`ref-{TYPE}-{ID}_{description}.md`
- [x] cursor-tasks.mdc に ref/ の命名規則を反映
- [x] 既存のルールドキュメントを確認・整理
  - 結果: 適切に構造化されており整理不要
- [x] Cursor公式ドキュメントを確認し、現在の構造がベストプラクティスに則っているか検証
  - 結果: YAML frontmatter、alwaysApply、ファイル構造、命名規則すべて適合

## In Progress Tasks

## Future Tasks

- [ ] AIの動作確認とテスト

## Implementation Plan

### 目標

0. https://cursor.com/docs/context/rules#rules を参考に、タスク管理ルールを整える

1. **タスクファイル更新の改善**
   - AIがタスクファイルをより頻繁に更新するためのルールを明確化
   - どのタイミングで更新すべきかを具体的に定義
   - 更新忘れを防ぐための仕組み

2. **参照情報の体系的管理**
   - タスクファイルが参照すべき情報を `tasks/ref/` ディレクトリに格納
   - 命名規則を統一し、タスクとの関連を明確化
   - 長期的に参照可能な情報のアーカイブ

### アーキテクチャ

#### ディレクトリ構造

```
.cursor/
  tasks/
    CHORE-6_improve-rules.md       # タスクファイル
    FEAT-42_user-authentication.md # タスクファイル
    ref/                            # 参照情報ディレクトリ ✅
      ref-CHORE-6_task-update-timing.md    # イシュー #6 に関連する参照情報
      ref-FEAT-42_jwt-specification.md     # イシュー #42 に関連する参照情報
      ref-DOCS-1_playbooks-format.md       # イシュー #1 に関連する参照情報
```

#### 命名規則

**タスクファイル**: `{TYPE}-{ID}_{description}.md`
- 例: `CHORE-6_improve-rules.md`

**参照ファイル**: `ref-{TYPE}-{ID}_{description}.md` ✅
- `ref-` プレフィックスで参照ファイルであることを明示
- `{TYPE}-{ID}` はタスクファイルと同じ（イシュー番号に紐づく）
- 例: `ref-CHORE-6_task-update-timing.md`

**参照ファイルの用途**:
- API仕様、型定義などの技術仕様
- 外部ドキュメントの要約・引用
- 設計の議論メモ
- 一時的な技術情報（使い捨て想定）

### データフロー

1. **タスクファイルの作成**
   - イシュー作成時にタスクファイルを生成
   - 必要に応じて参照ファイルも作成

2. **開発中の更新**
   - コード変更 → Relevant Files セクションを更新
   - タスク完了 → Completed Tasks に移動
   - 新しい知見 → 参照ファイルに記録

3. **タスク完了後**
   - タスクファイルはアーカイブとして保持
   - 参照ファイルは長期的な知識ベースとして活用

### その他

#### タスクファイル更新ルールの強化

以下のタイミングでタスクファイルを更新することを明記：

1. **ファイル作成・変更時**: 必ず Relevant Files セクションを更新
2. **重要なコンポーネント実装後**: In Progress → Completed に移動
3. **新しいタスク発見時**: Future Tasks に追加
4. **実装方針変更時**: Implementation Plan を更新

#### AIへの指示

cursor-tasks.mdc に以下を追記：
- タスクファイルの更新頻度を上げるための具体的な指示
- 参照ファイルの作成・更新タイミング
- ref/ ディレクトリの使い方

## Relevant Files

- `.cursor/rules/cursor-tasks.mdc` - タスク管理の基本ルール ✅
- `.cursor/tasks/CHORE-6_improve-rules.md` - このタスクファイル ✅
- `.cursor/tasks/ref/` - 参照情報ディレクトリ ✅ (命名: `ref-{TYPE}-{ID}_{description}.md`)

