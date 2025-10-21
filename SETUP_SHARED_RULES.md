# 共有ルールのセットアップ手順（Orphan ブランチ方式）

このドキュメントでは、`.cursor/rules/` を他のプロジェクトで使用するための手順を説明します。

## 概要

このリポジトリの `.cursor/rules/` は、**production ブランチ**（orphan ブランチ）で公開されており、複数のプロジェクトから利用できます。

### Orphan ブランチ方式のメリット

- 1つのリポジトリで開発用と公開用を管理（シンプル）
- タグでバージョン管理（`v1.0.0`, `v1.1.0` など）
- GitHub Actions で自動同期（main → production）
- 開発中のタスクファイルも Git 管理可能
- 公開用ブランチには最小限のファイルのみ含まれる

### アーキテクチャ

```
cursor-workspace リポジトリ

main ブランチ（開発用）:
  .cursor/
    rules/              # Cursor ルールファイル（通常のディレクトリ）
      cursor-tasks.mdc
      global.mdc
      git/
        commit.mdc
        ...
    tasks/              # タスクファイル（開発用）
  README.md
  SETUP_SHARED_RULES.md
  .github/workflows/
    sync-production.yml # 自動同期ワークフロー

production ブランチ（公開用、orphan）:
  rules/                # main の .cursor/rules/ と同期
    cursor-tasks.mdc
    global.mdc
    git/
      commit.mdc
      ...
  README.md             # cursor-rules 用の README
  LICENSE

      ↓ (プロジェクトで使用)

プロジェクトA/
  .cursor/
    rules/              # production ブランチから取得
    tasks/              # プロジェクトAのタスクファイル
```

---

## セットアップ手順

### ステップ1: production ブランチから .cursor/rules/ を取得

```bash
# プロジェクトのルートディレクトリで実行
cd /path/to/your-project

# production ブランチをクローン
git clone -b production --single-branch --depth 1 \
  https://github.com/nobunosuke/cursor-workspace.git .cursor/rules-temp

# rules/ ディレクトリを .cursor/rules/ に移動
mkdir -p .cursor
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# 結果を確認
ls -la .cursor/rules/
# → cursor-tasks.mdc, global.mdc, git/ などが表示される
```

### ステップ2: .cursor/tasks/ ディレクトリを作成（任意）

```bash
# タスク管理を使う場合は作成
mkdir -p .cursor/tasks

# タスクファイルのサンプルを作成
cat > .cursor/tasks/README.md << 'EOF'
# タスクファイル

このディレクトリには、GitHub イシューに対応するタスクファイルを配置します。

詳細は `.cursor/rules/cursor-tasks.mdc` を参照してください。
EOF
```

### ステップ3: コミット

```bash
# 変更をコミット
git add .cursor/
git commit -m "feat: Cursor共有ルールを追加"

# プッシュ
git push origin <branch-name>
```

### ステップ4: 動作確認

```bash
# Cursor で開き直す
cursor .

# AI に質問して、ルールが適用されているか確認
# 例: 「現在のブランチに対応するタスクファイルを確認して」
```

---

## ルールの更新方法

### ケース1: 最新版に更新したいとき

```bash
# プロジェクトAで最新版を取得
cd /path/to/project-a

# 現在の .cursor/rules/ を削除
rm -rf .cursor/rules

# production ブランチの最新版を取得
git clone -b production --single-branch --depth 1 \
  https://github.com/nobunosuke/cursor-workspace.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# 変更を確認
git status
# → .cursor/rules/ に変更があることが表示される

# 新しいバージョンをコミット
git add .cursor/rules
git commit -m "chore: Cursor共有ルールを最新版に更新"
git push
```

### ケース2: 特定のバージョンに固定したいとき

```bash
# プロジェクトAで特定バージョンを取得
cd /path/to/project-a

# 現在の .cursor/rules/ を削除
rm -rf .cursor/rules

# 特定のタグをチェックアウト
git clone -b production --single-branch --depth 1 \
  https://github.com/nobunosuke/cursor-workspace.git .cursor/rules-temp
cd .cursor/rules-temp
git checkout v1.0.0  # 特定のタグを指定
cd ..
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# 変更をコミット
git add .cursor/rules
git commit -m "chore: Cursor共有ルールをv1.0.0に固定"
git push
```

---

## 基本コマンド

```bash
# production ブランチから取得
git clone -b production --single-branch --depth 1 \
  https://github.com/nobunosuke/cursor-workspace.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp

# 特定のバージョンを指定
git clone -b production --single-branch \
  https://github.com/nobunosuke/cursor-workspace.git .cursor/rules-temp
cd .cursor/rules-temp
git checkout v1.0.0
cd ..
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp
```
