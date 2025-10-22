# Squash Merge 後の子ブランチ継続戦略

## 問題の整理

### 現状
- **マージ方法**: Squash merge（コミット履歴を綺麗に保つため）
- **課題**: 子ブランチを親にマージ後、同じ子ブランチで作業を続けたい
- **理由**: `.cursor/tasks/` に蓄積された背景知識・決定事項を引き継ぎたい

### なぜ問題になるのか

```
【マージ前】
main:     A - B
feat/42:  A - B - C1 - C2 - C3

【Squash merge後】
main:     A - B - D (DはC1+C2+C3の全変更を含む1つのコミット)
feat/42:  A - B - C1 - C2 - C3 (元の履歴を保持)

【親ブランチに他の変更が入った】
main:     A - B - D - E (他の人のコミット)
feat/42:  A - B - C1 - C2 - C3

【feat/42で作業を続けたい】
- feat/42をmainにrebaseしようとすると...
- C1, C2, C3はDと内容が同じだが、ハッシュが異なる
- Gitは「異なる変更」として認識
- 大量のコンフリクトが発生する可能性
```

**重要**: Squash merge を使う場合、子ブランチは「使い捨て」が一般的な運用。でも、タスクファイルの背景知識を引き継ぎたいという要件がある。

## 戦略の比較

### 戦略1: リセット戦略（現在のドキュメント）

**方法**:
```bash
# 子ブランチを親の最新に完全リセット
cd feat/42-worktree
git fetch origin main
git reset --hard origin/main
# 新しい変更を追加
git commit -m "fix: 追加修正"
git push origin feat/42 --force-with-lease
```

**メリット**:
- ✅ シンプルで確実
- ✅ コンフリクトが発生しない
- ✅ 子ブランチ = 親ブランチの状態から再スタート
- ✅ タスクファイル（`.cursor/tasks/`）は worktree に残る

**デメリット**:
- ❌ feat/42 の Git 履歴が消える（ただし、squash しているので main には残っている）
- ❌ リモートの feat/42 に未プッシュのコミットがあると失われる
- ❌ `--force-with-lease` が必要

**適用シーン**:
- 1つの子ブランチから2〜3回のPRを出す程度
- 子ブランチの Git 履歴を保持する必要がない
- タスクファイルの背景知識さえ引き継げればOK

### 戦略2: タスクファイルコピー戦略

**方法**:
```bash
# 1. 古いタスクファイルをコピー
cp .cursor/tasks/FEAT-42_feature.md .cursor/tasks/FEAT-42_feature-phase2.md

# 2. 新しい子ブランチを作成
cd main-worktree
git pull origin main
git worktree add ../feat/42-phase2 -b feat/42-phase2

# 3. タスクファイルを新しいworktreeに配置
cp ../feat-42-worktree/.cursor/tasks/FEAT-42_feature.md \
   ../feat-42-phase2-worktree/.cursor/tasks/FEAT-42_feature-phase2.md

# 4. タスクファイルを編集（ブランチ・イシュー番号を更新）
```

**メリット**:
- ✅ 履歴がクリーン（完全に新しいブランチ）
- ✅ 明確なフェーズ分け
- ✅ force push 不要

**デメリット**:
- ❌ タスクファイルの手動コピーが必要
- ❌ ブランチが増える
- ❌ 新しいイシュー番号が必要？（or 同じイシュー番号で複数ブランチ？）
- ❌ ファイル名の命名規則（`FEAT-42_feature.md` vs `FEAT-42_feature-phase2.md`）

**適用シーン**:
- 大きな機能を明確にフェーズ分けしたい
- 複数回（4回以上）のPRを出すことが予想される
- 何度もPRを出した後、区切りをつけたい

### 戦略3: Dev ブランチ導入

**方法**:
```
main (production - 本番環境)
  ↑ merge commit
dev (integration - 統合ブランチ)
  ↑ squash merge
feature branches (feat/42, feat/43, ...)
```

- feature → dev: squash merge
- dev → main: merge commit
- feature ブランチは dev に対して rebase 可能（squash していないので）

**メリット**:
- ✅ feature ブランチで継続的な開発が可能
- ✅ dev に対して rebase できる
- ✅ main の履歴は綺麗に保たれる
- ✅ 大規模プロジェクトに適している

**デメリット**:
- ❌ ブランチ戦略が複雑になる
- ❌ dev ブランチの管理コストが増える
- ❌ このプロジェクト（小規模・個人開発？）には過剰かも

**適用シーン**:
- 大規模プロジェクト
- チーム開発
- 継続的に同じfeature ブランチで開発を続ける必要がある

## 推奨戦略

### 短期的（今すぐ使える）: **戦略1（リセット戦略）**

**理由**:
- シンプルで確実
- タスクファイルの背景知識は worktree に残る
- Git 履歴は squash で main に残っているので、子ブランチの履歴が消えても問題ない
- 通常の使い方（2〜3回のPR）であれば十分

**運用方法**:
```bash
# squash merge後、追加修正が必要になった場合
cd feat/42-worktree
git fetch origin main
git reset --hard origin/main

# 必要に応じて stash を使う
# git stash
# git reset --hard origin/main
# git stash pop

# 新しい変更を追加
git add .
git commit -m "fix: 追加修正"
git push origin feat/42 --force-with-lease

# 再度 PR: feat/42 → main
```

**懸念点への対処**:
- 何度もPRを出す場合（5回、10回）は、戦略2に切り替える
- その判断基準は「3回目のマージ後」くらいが目安

### 中期的（必要になったら）: **戦略2（タスクファイルコピー）**

**タイミング**:
- 同じ子ブランチから3回以上PRを出している
- 履歴が追いにくくなってきた
- 明確なフェーズ分けをしたい

**AIによる支援**:
- タスクファイルのコピー・リネームを自動化
- 新しい worktree 作成時にタスクファイルを引き継ぐオプション
- タスクファイルのヘッダーに「前のフェーズ」へのリンクを追加

### 長期的（大規模になったら）: **戦略3（Dev ブランチ）**

**タイミング**:
- プロジェクトが大規模になった
- チーム開発になった
- 複数のfeature ブランチを並行開発している

## 次のステップ

1. **戦略1をベースにドキュメント更新**:
   - 現在の「リセット戦略」を改善
   - squash merge の前提を明記
   - stash の使い方を追加
   - 懸念点と切り替えタイミングを明記

2. **戦略2を補足として追加**:
   - タスクファイルコピー戦略の手順
   - いつ切り替えるべきか

3. **戦略3は参考情報として軽く触れる**:
   - 大規模プロジェクト向けの選択肢として

## 質問

1. **イシュー番号の扱い**: 同じイシュー（例: #42）で複数のブランチ（feat/42, feat/42-phase2）を作るのはOK？それとも新しいイシュー番号が必要？

2. **タスクファイルの命名**: phase2のタスクファイル名は？
   - `FEAT-42_feature-phase2.md`？
   - `FEAT-42-2_feature.md`？
   - それとも新しいイシュー番号で `FEAT-43_feature-continuation.md`？

3. **プロジェクトの規模**: 現在のプロジェクトは？
   - 個人開発？
   - 小規模チーム？
   - それによって推奨戦略が変わる

