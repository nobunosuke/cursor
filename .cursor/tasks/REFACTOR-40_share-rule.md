# Production ルールの配布方法リファクタリング

別のプロジェクトで production ブランチのルールを使用する際、ディレクトリ構造が二重にネストする問題を解決する。

## Completed Tasks

- [x] 現在の状況とセットアップ手順を確認
- [x] 問題の原因を特定
- [x] 各手段の比較検討（参照ファイル作成）
- [x] 手段8（構造変更）の一般性を調査
- [x] 8つから実用的な4つに絞り込み
- [x] 実際にコマンドを検証
- [x] ユーザーに4つの手段を提示
- [x] 手段1採用決定（ユーザー判断）
- [x] ドキュメント・スクリプト修正
- [x] production-README.md を簡潔に修正
- [x] SETUP_SHARED_RULES.md を削除
- [x] your-project/main/worktrees/ の構成を明記
- [x] install-rules.sh のレビュー完了

## In Progress Tasks

## Future Tasks

- [ ] production ブランチへの反映（main からマージ）
- [ ] 実際のプロジェクトでテスト

## Implementation Plan

### 目標
- プロジェクトAの `.cursor/rules/` 直下に production のルールが**展開された**状態で配置されるようにする
- 二重ネスト問題（`.cursor/rules/rules/`）を防ぐ

### 要件・制約事項
- ユーザーの期待する構造：
  ```
  プロジェクトA/
    .cursor/rules/
      git/
      global.mdc
      cursor-tasks.mdc
  ```
- 望ましくない構造（現在発生している問題）：
  ```
  プロジェクトA/
    .cursor/rules/
      rules/
        git/
        global.mdc
        cursor-tasks.mdc
  ```

### 検討事項・議論ログ
- 現在の SETUP_SHARED_RULES.md には `mv .cursor/rules-temp/rules .cursor/rules` という手順がある
- production-README.md にも同じ手順が記載されている
- **問題の原因を特定**：
  - production ブランチは `rules/` ディレクトリをトップレベルに持つ
  - 既に `.cursor/rules` が存在する状態で `mv .cursor/rules-temp/rules .cursor/rules` を実行すると、`mv` が「ディレクトリ内への移動」と解釈
  - 結果として `.cursor/rules/rules/` になる
  - 解決策：`rm -rf .cursor/rules` を手順に明記（実施済み）

- **各手段の比較検討**（ref-REFACTOR-40_import-strategies.md に詳細）：
  1. Clone + mv（現在）：シンプルだが二重ネストリスク
  2. Sparse Checkout：複雑で結局 mv が必要
  3. Git Archive：GitHub 依存だが軽量
  4. Submodule：オーバースペック
  5. Subtree：二重ネストを解消できない
  6. Clone + rsync/cp：mv との差が小さい
  7. インストールスクリプト：ユーザー体験◎、セキュリティ懸念
  8. **Production 構造変更**：根本的解決、最もシンプル

- **Web調査結果**（ref-REFACTOR-40_research-results.md）：
  - 「よくあること」ではあるが、**条件付き**
  - GitHub Pages（gh-pages ブランチ）が最も一般的な事例
  - 前提条件：自動化・ドキュメント化・ユーザーが直接触らない
  - 手動での構造維持は推奨されない
  - **結論**：手段8は「許容される範囲」、メジャーバージョンアップで採用は合理的

- **8つから4つへの絞り込み**（ref-REFACTOR-40_final-4-methods.md）：
  - 除外：Submodule, Subtree, rsync/cp, インストールスクリプト単体
  - 選定：Clone + mv、tar.gz、Production構造変更、Sparse Checkout
  - 実際にコマンドを検証（/tmp/cursor-rules-test で実験）
  - 各手段のメリット・デメリット、実測データを記録

### 決定事項
- **最終決定**: 手段1（Clone + mv）を採用
- 理由：
  - コマンドの複雑さは手段3と同等（どちらも rm 2回）
  - 構造の分かりやすさで優れている（`rules/` で配布物を分離）
  - main との対称性が明確
  - 破壊的変更なし
- 手段3（Production構造変更）は不採用
  - わずかな差のために破壊的変更は割に合わない
  - 当初の評価を訂正

### その他
- production ブランチは orphan ブランチとして管理されている
- GitHub Actions で main → production に自動同期

## Relevant Files

- ~~SETUP_SHARED_RULES.md~~ - 削除 ✅
- production-README.md - production ブランチで公開される README（簡潔版に修正） ✅
- install-rules.sh - セットアップ自動化スクリプト（手段1ベース） ✅
- .cursor/tasks/ref/ref-REFACTOR-40_import-strategies.md - 各手段の比較検討（8つ） ✅
- .cursor/tasks/ref/ref-REFACTOR-40_research-results.md - 構造差異のWeb調査結果 ✅
- .cursor/tasks/ref/ref-REFACTOR-40_final-4-methods.md - 実用的な4つの手段（最終判断を反映） ✅

