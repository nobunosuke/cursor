# Production ルール取得の手段比較

production ブランチから `.cursor/rules/` を取得する際の、各手段の比較検討。

## 前提条件

### Production ブランチの構造
```
production/
├── LICENSE
├── README.md
└── rules/
    ├── cursor-tasks.mdc
    ├── global.mdc
    └── git/
        ├── commit.mdc
        ├── issue.mdc
        ├── pr.mdc
        └── worktree.mdc
```

### 期待する最終構造（プロジェクトA）
```
プロジェクトA/
├── .cursor/
│   ├── rules/              ← ここに rules/ の中身が展開されてほしい
│   │   ├── cursor-tasks.mdc
│   │   ├── global.mdc
│   │   └── git/
│   └── tasks/
└── (その他のプロジェクトファイル)
```

### 避けたい構造
```
プロジェクトA/
└── .cursor/
    └── rules/
        └── rules/          ← 二重ネスト（NG）
            ├── cursor-tasks.mdc
            └── ...
```

---

## 手段1: Clone + mv（現在の方法）

### コマンド
```bash
rm -rf .cursor/rules
git clone -b production --single-branch --depth 1 \
  https://github.com/USER/REPO.git .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp
```

### フォルダ構造の遷移
```
1. Clone直後:
.cursor/
└── rules-temp/
    ├── LICENSE
    ├── README.md
    └── rules/
        ├── cursor-tasks.mdc
        └── git/

2. mv実行後:
.cursor/
├── rules/
│   ├── cursor-tasks.mdc
│   └── git/
└── rules-temp/        ← 削除対象
    ├── LICENSE
    └── README.md

3. 最終形:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

### メリット
- ✅ シンプルで理解しやすい
- ✅ どの環境でも動作する（Git 1.7+）
- ✅ タグによるバージョン指定が簡単
- ✅ ネットワークエラー時のリトライが容易

### デメリット
- ❌ 不要なファイル（LICENSE, README.md）も一時的にダウンロード
- ❌ 手順が複数ステップ（clone → mv → rm）
- ❌ ユーザーが手順を間違えると二重ネストの可能性
- ❌ `rm -rf .cursor/rules` が必要（既存削除）

### 失敗パターン
```bash
# NG: 既存の .cursor/rules が存在する状態で mv
mkdir -p .cursor/rules
git clone ... .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
# → .cursor/rules/rules/ になる

# OK: 既存を削除してから
rm -rf .cursor/rules
git clone ... .cursor/rules-temp
mv .cursor/rules-temp/rules .cursor/rules
# → .cursor/rules/ に正しく展開
```

---

## 手段2: Sparse Checkout（特定ディレクトリのみ取得）

### コマンド
```bash
rm -rf .cursor/rules
mkdir -p .cursor/rules
cd .cursor/rules
git init
git remote add origin https://github.com/USER/REPO.git
git config core.sparseCheckout true
echo "rules/*" > .git/info/sparse-checkout
git pull --depth=1 origin production
mv rules/* .
rm -rf rules .git
cd ../..
```

### フォルダ構造の遷移
```
1. git init後:
.cursor/
└── rules/
    └── .git/

2. git pull後:
.cursor/
└── rules/
    ├── .git/
    └── rules/
        ├── cursor-tasks.mdc
        └── git/

3. mv実行後:
.cursor/
└── rules/
    ├── .git/
    ├── cursor-tasks.mdc
    ├── git/
    └── rules/        ← 空ディレクトリ（削除対象）

4. 最終形:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

### メリット
- ✅ 必要なディレクトリ（rules/）のみダウンロード
- ✅ LICENSE, README.md は取得しない
- ✅ 大規模リポジトリでも高速

### デメリット
- ❌ コマンドが複雑で理解しづらい
- ❌ 結局 `mv` が必要（二重ネスト問題は同じ）
- ❌ 一時的に `.git` ディレクトリが残る
- ❌ エラーハンドリングが難しい
- ❌ Git 2.25+ 推奨（古いバージョンでは動作が不安定）

---

## 手段3: Git Archive（スナップショット取得）

### コマンド
```bash
rm -rf .cursor/rules
mkdir -p .cursor/rules-temp
curl -L "https://github.com/USER/REPO/archive/refs/heads/production.tar.gz" \
  | tar xz -C .cursor/rules-temp --strip-components=2 "REPO-production/rules"
mv .cursor/rules-temp .cursor/rules
```

または

```bash
rm -rf .cursor/rules
git archive --remote=https://github.com/USER/REPO.git production rules/ \
  | tar x --strip-components=1 -C .cursor/rules
```

### フォルダ構造の遷移
```
パターンA (tar + strip-components):
1. 展開直後:
.cursor/
└── rules-temp/
    ├── cursor-tasks.mdc
    └── git/

2. 最終形:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

### メリット
- ✅ `.git` ディレクトリが不要
- ✅ `--strip-components` で直接的な展開が可能
- ✅ GitHub の tar.gz を直接利用（curl のみでOK）
- ✅ 軽量（履歴を持たない）

### デメリット
- ❌ `git archive --remote` は多くのサーバーで無効化されている（GitHub含む）
- ❌ curl + tar のパターンは GitHub 依存（GitLab等では別URL）
- ❌ タグ指定が `refs/tags/v1.0.0.tar.gz` と長い
- ❌ `--strip-components` の数え方が直感的でない

### 実際のコマンド例
```bash
# 最新版
rm -rf .cursor/rules
mkdir -p .cursor
curl -sL "https://github.com/nobunosuke/cursor-rules/archive/refs/heads/production.tar.gz" \
  | tar xz --strip-components=2 -C .cursor --transform='s/^rules/rules/' \
  "cursor-rules-production/rules"

# 特定バージョン
curl -sL "https://github.com/nobunosuke/cursor-rules/archive/refs/tags/v1.0.0.tar.gz" \
  | tar xz --strip-components=2 -C .cursor \
  "cursor-rules-v1.0.0/rules"
```

**訂正が必要：**
`--strip-components` だけでは `rules/` の展開位置を制御できない。結局 `mv` が必要。

---

## 手段4: Git Submodule（参照として管理）

### コマンド
```bash
# production ブランチを submodule として追加
git submodule add -b production https://github.com/USER/REPO.git .cursor/rules-submodule
# シンボリックリンクまたはコピー
ln -s rules-submodule/rules .cursor/rules
```

または

```bash
git submodule add -b production https://github.com/USER/REPO.git .cursor/rules-submodule
git config -f .gitmodules submodule..cursor/rules-submodule.path .cursor/rules-submodule
```

### フォルダ構造
```
.cursor/
├── rules-submodule/      ← Git submodule
│   ├── LICENSE
│   ├── README.md
│   └── rules/
└── rules -> rules-submodule/rules/  ← シンボリックリンク
```

### メリット
- ✅ Git で管理される（バージョンが .gitmodules に記録される）
- ✅ 更新が `git submodule update --remote` で簡単
- ✅ チーム全体で同じバージョンを保証

### デメリット
- ❌ `.gitmodules` が必要（プロジェクトに追加ファイル）
- ❌ Submodule の理解が必要（学習コスト）
- ❌ 初回クローン時に `git submodule init && git submodule update` が必要
- ❌ 結局 `rules/` を参照するためのシンボリックリンクが必要
- ❌ シンボリックリンクは Windows で問題になる可能性
- ❌ 不要なファイル（LICENSE, README.md）も含まれる

---

## 手段5: Git Subtree（履歴ごと取り込む）

### コマンド
```bash
git subtree add --prefix=.cursor/rules \
  https://github.com/USER/REPO.git production --squash
```

### フォルダ構造
```
.cursor/
└── rules/
    ├── LICENSE
    ├── README.md
    └── rules/
        ├── cursor-tasks.mdc
        └── git/
```

### メリット
- ✅ Git の履歴に統合される
- ✅ 更新が `git subtree pull` で可能

### デメリット
- ❌ **production ブランチのルートが `.cursor/rules` になる**
- ❌ 結果として `.cursor/rules/rules/` が必要（二重ネスト）
- ❌ `--prefix` では production の `rules/` サブディレクトリを指定できない
- ❌ コミット履歴が混在する
- ❌ Subtree の理解が必要（学習コスト）

**この手段は要件に合わない。**

---

## 手段6: Clone + rsync/cp（ファイル操作）

### コマンド
```bash
rm -rf .cursor/rules
git clone -b production --single-branch --depth 1 \
  https://github.com/USER/REPO.git .cursor/rules-temp

# rsync で rules/ の中身を展開
mkdir -p .cursor/rules
rsync -av .cursor/rules-temp/rules/ .cursor/rules/
rm -rf .cursor/rules-temp

# または cp
mkdir -p .cursor/rules
cp -r .cursor/rules-temp/rules/. .cursor/rules/
rm -rf .cursor/rules-temp
```

### フォルダ構造の遷移
```
1. Clone直後:
.cursor/
└── rules-temp/
    ├── LICENSE
    ├── README.md
    └── rules/
        ├── cursor-tasks.mdc
        └── git/

2. rsync/cp後:
.cursor/
├── rules/
│   ├── cursor-tasks.mdc
│   └── git/
└── rules-temp/

3. 最終形:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

### メリット
- ✅ `rsync -av` でパーミッション・タイムスタンプ保持
- ✅ `cp -r` は標準コマンドで動作確実
- ✅ トレイリングスラッシュ（`rules/.`）で中身のみコピー

### デメリット
- ❌ `mv` との違いが小さい（rsync は冗長）
- ❌ 手順が増える（mkdir + rsync/cp + rm）
- ❌ 不要なファイルもダウンロードする
- ❌ `rsync` は macOS/Linux にはあるが、Windows では追加インストール必要

---

## 手段7: 単一コマンド化（シェルスクリプト）

### コマンド
```bash
# install-rules.sh を用意
curl -sSL https://raw.githubusercontent.com/USER/REPO/production/install-rules.sh | bash
```

または

```bash
bash <(curl -sSL https://raw.githubusercontent.com/USER/REPO/production/install-rules.sh)
```

### メリット
- ✅ ユーザー視点で最もシンプル（1コマンド）
- ✅ エラーハンドリングを組み込める
- ✅ 検証ロジックを含められる
- ✅ 対話的な確認が可能

### デメリット
- ❌ ユーザーがスクリプト内容を確認せずに実行するリスク
- ❌ curl 経由での実行はセキュリティ懸念
- ❌ スクリプト自体を production ブランチに含める必要がある
- ❌ デバッグが難しい（ネットワーク越し）

---

## 提案：Production ブランチの構造を変更する（根本的解決）

### 現在の構造
```
production/
├── LICENSE
├── README.md
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

### 提案する構造
```
production/
├── LICENSE
├── README.md
├── cursor-tasks.mdc    ← ルート直下に展開
├── global.mdc
└── git/
    ├── commit.mdc
    └── ...
```

### この場合のコマンド
```bash
rm -rf .cursor/rules
git clone -b production --single-branch --depth 1 \
  https://github.com/USER/REPO.git .cursor/rules
rm -rf .cursor/rules/.git .cursor/rules/LICENSE .cursor/rules/README.md
```

### フォルダ構造の遷移
```
1. Clone直後:
.cursor/
└── rules/
    ├── .git/
    ├── LICENSE
    ├── README.md
    ├── cursor-tasks.mdc
    └── git/

2. 不要ファイル削除後:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

### メリット
- ✅ **最もシンプル（1 clone + 1 削除）**
- ✅ 二重ネスト問題が完全に解消
- ✅ ユーザーが間違えにくい
- ✅ タグによるバージョン指定も簡単
- ✅ `.git` ディレクトリの削除も明示的

### デメリット
- ❌ production ブランチの構造変更が必要
- ❌ 既存ユーザーに影響（ドキュメント更新必須）
- ❌ LICENSE, README.md を削除する手間
- ⚠️ main ブランチの `.cursor/rules/` と production ブランチのルート構造が異なる（混乱の可能性）

---

## 比較まとめ

| 手段 | シンプルさ | 安全性 | 速度 | 推奨度 |
|------|-----------|--------|------|--------|
| **1. Clone + mv（現在）** | ⭐⭐⭐ | ⭐⭐（二重ネストリスク） | ⭐⭐⭐ | ⭐⭐⭐ |
| 2. Sparse Checkout | ⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| 3. Git Archive | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐（GitHub依存） |
| 4. Submodule | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐（オーバースペック） |
| 5. Subtree | ⭐ | ⭐⭐ | ⭐⭐ | ❌（二重ネスト） |
| 6. Clone + rsync/cp | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| 7. インストールスクリプト | ⭐⭐⭐⭐⭐ | ⭐⭐（要検証） | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **8. Production構造変更** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 推奨アプローチ

### 短期的解決（既存構造を維持）

**手段1（Clone + mv）+ 手段7（スクリプト）の組み合わせ**

1. ドキュメントで `rm -rf .cursor/rules` を明示
2. インストールスクリプト（`install-rules.sh`）を提供
3. 二重ネスト問題のトラブルシューティングを追加

**ユーザー体験：**
- 慎重なユーザー: ドキュメントを読んで手動実行
- 簡単派: スクリプトで1コマンド実行

### 長期的解決（破壊的変更）

**手段8（Production ブランチ構造変更）**

1. production ブランチの構造を変更（`rules/` を廃止）
2. メジャーバージョンアップ（v1.x → v2.0）
3. 移行ガイドを提供

**ユーザー体験：**
```bash
# v2.0 以降
git clone -b production --single-branch --depth 1 \
  https://github.com/USER/REPO.git .cursor/rules
rm -rf .cursor/rules/.git
```

---

## 議論ポイント

1. **production ブランチの構造変更は許容できるか？**
   - メリット: ユーザー体験が大幅に向上
   - デメリット: 既存ユーザーへの影響

2. **インストールスクリプトは必要か？**
   - メリット: 初心者に優しい
   - デメリット: セキュリティ懸念、メンテナンスコスト

3. **Git Submodule を使うべきか？**
   - チームでバージョン管理する場合は有効
   - 個人プロジェクトには過剰

4. **不要なファイル（LICENSE, README.md）の扱いは？**
   - production ブランチに必要か？
   - ダウンロード後に削除するか？

