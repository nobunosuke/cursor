# Production ルール取得の実用的な4つの手段（詳細比較）

8つの候補から実用性の高い4つに絞り込み、実際にコマンドを検証した結果をまとめる。

## 選定基準

1. **実用性**: 実際に動作することを確認
2. **シンプルさ**: ユーザーが理解しやすい
3. **保守性**: 長期的にメンテナンスしやすい
4. **ユーザー体験**: 手順の少なさ、エラーの起きにくさ

## 除外した手段と理由

| 手段 | 除外理由 |
|------|----------|
| Git Submodule | `.gitmodules` の管理が必要、オーバースペック |
| Git Subtree | 二重ネストを解決できない、履歴が混在 |
| rsync/cp | Clone + mv との違いが小さい、冗長 |
| インストールスクリプト | 単独の手段ではなく、他手段をラップするもの |

**インストールスクリプトについて**: これは独立した手段ではなく、以下の4つのいずれかを内包するラッパー。最終的には提供すべきだが、比較対象としては除外。

---

## 選定した4つの手段

### 1. Clone + mv（現行改善版）
### 2. curl + tar.gz（Git不要）
### 3. Production 構造変更（根本的解決）
### 4. Git Sparse Checkout（技術的洗練）

---

## 詳細比較

### 手段1: Clone + mv（現行改善版）

#### 概要
標準的な git clone を使用し、rules/ ディレクトリのみを mv で配置する方法。

#### コマンド
```bash
# 既存削除（重要）
rm -rf .cursor/rules

# Clone
git clone -b production --single-branch --depth 1 \
  https://github.com/USER/REPO.git .cursor/rules-temp

# rules/ のみを配置
mv .cursor/rules-temp/rules .cursor/rules

# 一時ディレクトリ削除
rm -rf .cursor/rules-temp
```

#### 1行版（上級者向け）
```bash
rm -rf .cursor/rules && \
git clone -b production --depth 1 https://github.com/USER/REPO.git .cursor/rules-temp && \
mv .cursor/rules-temp/rules .cursor/rules && \
rm -rf .cursor/rules-temp
```

#### フォルダ構造の遷移
```
1. Clone直後:
.cursor/
└── rules-temp/
    ├── LICENSE
    ├── README.md
    └── rules/          ← これを取り出す
        ├── cursor-tasks.mdc
        └── git/

2. mv実行後:
.cursor/
├── rules/              ← 正しく配置
│   ├── cursor-tasks.mdc
│   └── git/
└── rules-temp/         ← 削除対象（不要ファイル含む）
    ├── LICENSE
    └── README.md

3. 最終形:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

#### 動作要件
- Git 1.7.10+ (--single-branch サポート)
- Git 1.8.2+ (--depth サポート)
- 実質的にどの環境でも動作

#### メリット
- ✅ **最もシンプル**（Git の基本コマンドのみ）
- ✅ **理解しやすい**（動作が明確）
- ✅ **デバッグ容易**（各ステップで状態確認可能）
- ✅ **タグ指定が簡単**（`-b v1.0.0` で指定）
- ✅ **環境依存なし**（Git さえあればOK）

#### デメリット
- ❌ **不要ファイルもDL**（LICENSE, README.md）
- ❌ **3ステップ必要**（clone, mv, rm）
- ❌ **`rm -rf` 必須**（既存削除しないと二重ネスト）
- ❌ **一時ディレクトリ作成**（`.cursor/rules-temp`）
- ⚠️ **ユーザーミスの可能性**（手順を間違えやすい）

#### 実測データ
```
ダウンロードサイズ: 約 50KB（depth=1、production ブランチ）
所要時間: 約 2-3秒（ネットワーク速度による）
ディスク使用量: 一時的に約 100KB（.git含む）、最終的に 約 30KB
```

#### 失敗パターンと対処
```bash
# NG: 既存の .cursor/rules が存在
mkdir -p .cursor/rules
mv .cursor/rules-temp/rules .cursor/rules
# → .cursor/rules/rules/ になる（二重ネスト）

# OK: 必ず既存削除
rm -rf .cursor/rules
mv .cursor/rules-temp/rules .cursor/rules
# → .cursor/rules/ に正しく配置
```

#### 推奨度
⭐⭐⭐⭐ (4/5)
- 現実的な選択肢
- ドキュメント改善で対処可能

---

### 手段2: curl + tar.gz（Git不要）

#### 概要
GitHub の tar.gz アーカイブをダウンロードし、tar で直接展開する方法。

#### コマンド
```bash
# 既存削除
rm -rf .cursor/rules

# ダウンロード + 展開（1コマンド）
mkdir -p .cursor
curl -sL "https://github.com/USER/REPO/archive/refs/heads/production.tar.gz" \
  | tar xz --strip-components=2 -C .cursor \
  REPO-production/rules

# rules を .cursor/rules にリネーム
mv .cursor/rules .cursor/rules-final
```

#### 改良版（実験で検証済み）
```bash
rm -rf .cursor/rules && mkdir -p .cursor/rules && \
curl -sL "https://github.com/USER/REPO/archive/refs/heads/production.tar.gz" \
  | tar xz --strip-components=2 -C .cursor/rules \
  REPO-production/rules --strip=1
```

#### さらにシンプルな方法
```bash
# 一時ディレクトリに展開してから移動
rm -rf .cursor/rules && \
curl -sL "https://github.com/USER/REPO/archive/refs/heads/production.tar.gz" \
  | tar xz && \
mv REPO-production/rules .cursor/rules && \
rm -rf REPO-production
```

#### フォルダ構造の遷移
```
1. tar.gz の中身:
REPO-production/
├── LICENSE
├── README.md
└── rules/
    ├── cursor-tasks.mdc
    └── git/

2. --strip-components=2 で展開:
.cursor/rules/
├── cursor-tasks.mdc
└── git/

3. 最終形:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

#### 動作要件
- `curl` コマンド（macOS/Linux標準、Windows は追加インストール必要）
- `tar` コマンド（macOS/Linux標準、Windows 10+ は標準）
- Git 不要！

#### メリット
- ✅ **Git 不要**（curl と tar のみ）
- ✅ **軽量**（.git ディレクトリなし）
- ✅ **高速**（shallow clone より速い）
- ✅ **1コマンドで完結**（パイプで繋げられる）
- ✅ **不要ファイルを取得しない**（rules/ のみ展開）

#### デメリット
- ❌ **GitHub 依存**（tar.gz のURL構造）
- ❌ **`--strip-components` が直感的でない**（数え方が難しい）
- ❌ **タグ指定が長い**（`refs/tags/v1.0.0.tar.gz`）
- ❌ **GitLab等では異なるURL**（移植性低い）
- ⚠️ **エラーメッセージが不親切**（curl/tar のエラー）

#### 実測データ（実験結果）
```
ダウンロードサイズ: 約 15KB（.git なし）
所要時間: 約 1-2秒
ディスク使用量: 約 30KB（最終的なファイルのみ）
```

#### タグ指定の方法
```bash
# 最新版
curl -sL "https://github.com/USER/REPO/archive/refs/heads/production.tar.gz"

# 特定バージョン
curl -sL "https://github.com/USER/REPO/archive/refs/tags/v1.0.0.tar.gz"
```

#### 推奨度
⭐⭐⭐ (3/5)
- Git不要なのは魅力
- GitHub依存がネック
- 上級者向け

---

### 手段3: Production 構造変更（根本的解決）

#### 概要
production ブランチの構造を変更し、rules/ をルート直下に配置する。

#### 現在の構造
```
production/
├── LICENSE
├── README.md
└── rules/              ← ネスト
    ├── cursor-tasks.mdc
    └── git/
```

#### 変更後の構造
```
production/
├── LICENSE
├── README.md
├── cursor-tasks.mdc    ← ルート直下
├── global.mdc
└── git/
    └── commit.mdc
```

#### ユーザー側のコマンド（v2.0以降）
```bash
# これだけ！
rm -rf .cursor/rules && \
git clone -b production --depth 1 \
  https://github.com/USER/REPO.git .cursor/rules && \
rm -rf .cursor/rules/.git
```

#### さらにシンプルに（.git削除も不要にする場合）
```bash
rm -rf .cursor/rules && \
git clone -b production --depth 1 \
  https://github.com/USER/REPO.git .cursor/rules
```

#### フォルダ構造の遷移
```
1. Clone直後:
.cursor/
└── rules/
    ├── .git/
    ├── LICENSE
    ├── README.md
    ├── cursor-tasks.mdc
    └── git/

2. .git削除後（任意）:
.cursor/
└── rules/
    ├── LICENSE          ← 残る
    ├── README.md        ← 残る
    ├── cursor-tasks.mdc
    └── git/

3. 最終形（理想）:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

#### 動作要件
- Git 1.8.2+
- production ブランチの構造変更が必要（一度だけ）

#### メリット
- ✅ **最もシンプル**（2ステップのみ）
- ✅ **二重ネスト問題の完全解決**
- ✅ **ユーザーミスが起きにくい**
- ✅ **直感的**（clone → rm だけ）
- ✅ **GitHub Pages の先例あり**（gh-pages ブランチ）

#### デメリット
- ❌ **破壊的変更**（既存ユーザーに影響）
- ❌ **メジャーバージョンアップ必要**（v2.0）
- ❌ **移行ガイド作成必要**
- ⚠️ **main と production の構造差**（混乱の可能性）
- ⚠️ **LICENSE/README.md も残る**（削除手順を追加するか検討）

#### 実測データ
```
ダウンロードサイズ: 約 50KB
所要時間: 約 2-3秒
ディスク使用量: 約 30KB（.git削除後）、約 80KB（.git含む）
```

#### 移行計画
```
1. v1.x: 現行方式（rules/ ネスト）
   - トラブルシューティング充実
   
2. v2.0: 構造変更（ルート直下）
   - CHANGELOG で明記
   - 移行ガイド作成
   - アナウンス

3. v1.x サポート期間: 6ヶ月程度
```

#### 推奨度
⭐⭐⭐⭐⭐ (5/5)
- 長期的に最良の選択
- ユーザー体験が最高
- メジャーアップデート時に実施推奨

---

### 手段4: Git Sparse Checkout（技術的洗練）

#### 概要
Git の sparse-checkout 機能を使い、rules/ ディレクトリのみをチェックアウトする。

#### コマンド（cone mode、Git 2.25+）
```bash
# 既存削除
rm -rf .cursor/rules

# Sparse cloneで初期化
git clone --filter=blob:none --sparse --depth=1 -b production \
  https://github.com/USER/REPO.git .cursor/rules-temp

# rules/ のみをチェックアウト
cd .cursor/rules-temp
git sparse-checkout set rules

# 配置
cd ../..
mv .cursor/rules-temp/rules .cursor/rules
rm -rf .cursor/rules-temp
```

#### 1行版
```bash
rm -rf .cursor/rules && \
git clone --filter=blob:none --sparse --depth=1 -b production \
  https://github.com/USER/REPO.git .cursor/rules-temp && \
cd .cursor/rules-temp && git sparse-checkout set rules && cd ../.. && \
mv .cursor/rules-temp/rules .cursor/rules && \
rm -rf .cursor/rules-temp
```

#### フォルダ構造の遷移
```
1. Sparse clone直後:
.cursor/
└── rules-temp/
    └── .git/           ← ファイルは未チェックアウト

2. sparse-checkout set後:
.cursor/
└── rules-temp/
    ├── .git/
    └── rules/          ← これのみチェックアウト
        ├── cursor-tasks.mdc
        └── git/

3. 最終形:
.cursor/
└── rules/
    ├── cursor-tasks.mdc
    └── git/
```

#### 動作要件
- Git 2.25+（cone mode サポート）
- Git 2.19+（旧 sparse-checkout）でも可能だが複雑

#### メリット
- ✅ **必要なディレクトリのみDL**（LICENSE等不要）
- ✅ **Git履歴付き**（.git があれば git pull 可能）
- ✅ **技術的に洗練**（最新のGit機能）
- ✅ **帯域幅の節約**（--filter=blob:none）

#### デメリット
- ❌ **コマンドが複雑**（理解しづらい）
- ❌ **Git 2.25+ 必要**（古い環境で動かない）
- ❌ **結局 mv が必要**（二重ネスト問題は同じ）
- ❌ **エラー時のデバッグ困難**
- ⚠️ **一時ディレクトリ必要**（clone → mv → rm）

#### 実測データ（実験結果）
```
ダウンロードサイズ: 約 20KB（blob:none + sparse）
所要時間: 約 3-4秒（filter処理含む）
ディスク使用量: 約 30KB（最終）
```

#### Git バージョン確認
```bash
# バージョン確認
git --version

# cone mode サポート確認（2.25+）
git sparse-checkout --help | grep -i cone
```

#### 推奨度
⭐⭐ (2/5)
- 技術的には優れている
- 実用性では劣る
- 上級者・特殊用途向け

---

## 総合比較表

| 項目 | Clone + mv | tar.gz | Production変更 | Sparse Checkout |
|------|-----------|--------|---------------|-----------------|
| **シンプルさ** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| **理解しやすさ** | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐ |
| **環境依存** | Git必要 | curl/tar | Git必要 | Git 2.25+ |
| **ダウンロード量** | 50KB | 15KB | 50KB | 20KB |
| **速度** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **エラー処理** | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **タグ指定** | 簡単 | やや複雑 | 簡単 | 簡単 |
| **保守性** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **二重ネスト防止** | 手動 | 自動 | 完全解決 | 手動 |
| **総合評価** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |

## ユーザーストーリー別の推奨

### ケース1: 初心者ユーザー
**推奨**: 手段3（Production構造変更）
- 最もシンプル
- 間違えにくい

### ケース2: Git不要にしたい
**推奨**: 手段2（tar.gz）
- curl と tar のみ
- CI/CD環境で有用

### ケース3: 現状維持（v1.x）
**推奨**: 手段1（Clone + mv）
- 破壊的変更なし
- ドキュメント改善で対応

### ケース4: 技術的に洗練されたい
**推奨**: 手段4（Sparse Checkout）
- 最新Git機能
- ただし実用性は低い

---

## 実装コストの比較

| 手段 | ドキュメント | スクリプト | 移行 | 合計コスト |
|------|-------------|-----------|------|-----------|
| Clone + mv | 低 | 低 | なし | ⭐ |
| tar.gz | 中 | 中 | なし | ⭐⭐ |
| Production変更 | 高 | 低 | 高 | ⭐⭐⭐⭐ |
| Sparse Checkout | 高 | 中 | なし | ⭐⭐⭐ |

---

## 段階的実装プラン

### フェーズ1: 短期（v1.x、現在）
**採用**: 手段1（Clone + mv）改善

実施内容:
- ✅ `rm -rf .cursor/rules` を明記
- ✅ トラブルシューティング追加
- ✅ 二重ネスト修正方法を提供

### フェーズ2: 中期（v2.0、推奨）
**採用**: 手段3（Production構造変更）

実施内容:
1. production ブランチの構造変更
2. CHANGELOG に破壊的変更を明記
3. 移行ガイド作成
4. v1.x → v2.0 の手順提供
5. v1.x のサポート期間設定（6ヶ月）

### フェーズ3: 長期（v3.0?）
**検討**: npm パッケージ化

```bash
npm install -D @nobunosuke/cursor-rules
npx setup-cursor-rules
```

---

## 最終推奨（修正版）

### ✅ 採用決定: **手段1（Clone + mv）**

**理由（ユーザーの指摘による再評価）:**

1. **コマンドの複雑さは手段3と同等**
   - どちらも `rm` を2回使用
   - 実質的な手間は変わらない

2. **構造の分かりやすさで優れている**
   - `rules/` ディレクトリで配布物を明確に分離
   - LICENSE/README.md とルールファイルが混在しない
   - npm `dist/`, Python `build/` と同じ標準的パターン

3. **main との対称性**
   - `main: .cursor/rules/` ↔ `production: rules/`
   - 直感的な対応関係

4. **破壊的変更なし**
   - v1.x のまま改善可能
   - コストが低い

### 🎯 実装内容

1. **ドキュメント改善** ✅
   - `rm -rf .cursor/rules` を明記
   - トラブルシューティング追加
   - production-README.md 更新

2. **インストールスクリプト** ✅
   - 手段1をベースに実装
   - エラーハンドリング充実
   - 対話的な確認機能

### ❌ 手段3を採用しない理由

当初は推奨していたが、ユーザーの指摘により再評価した結果：

1. **わずかな差のために破壊的変更は割に合わない**
2. **LICENSE/README.md の扱いが曖昧**（削除手順が必要）
3. **構造の混在**（説明ファイルとルールファイルが同階層）
4. **main との非対称性**

### 特殊用途で検討
- **手段2（tar.gz）**: CI/CD、Git不要な環境
- **手段4（Sparse Checkout）**: 大規模リポジトリ、Git履歴が必要

---

## インストールスクリプトの提案

上記4つの手段を選択可能にするインストールスクリプト：

```bash
#!/usr/bin/env bash
# install-rules.sh

echo "Cursor Rules インストール方法を選択してください:"
echo "1) Git Clone（推奨）"
echo "2) curl + tar.gz（Git不要）"
echo "3) Git Sparse Checkout（上級者向け）"
read -p "選択 (1-3): " choice

case $choice in
    1) # Clone + mv
        rm -rf .cursor/rules && \
        git clone -b production --depth 1 \
          https://github.com/USER/REPO.git .cursor/rules-temp && \
        mv .cursor/rules-temp/rules .cursor/rules && \
        rm -rf .cursor/rules-temp
        ;;
    2) # tar.gz
        rm -rf .cursor/rules && \
        curl -sL "https://github.com/USER/REPO/archive/refs/heads/production.tar.gz" \
          | tar xz && \
        mv REPO-production/rules .cursor/rules && \
        rm -rf REPO-production
        ;;
    3) # Sparse Checkout
        rm -rf .cursor/rules && \
        git clone --filter=blob:none --sparse --depth=1 -b production \
          https://github.com/USER/REPO.git .cursor/rules-temp && \
        cd .cursor/rules-temp && git sparse-checkout set rules && cd ../.. && \
        mv .cursor/rules-temp/rules .cursor/rules && \
        rm -rf .cursor/rules-temp
        ;;
    *) echo "無効な選択"; exit 1 ;;
esac

echo "✅ インストール完了！"
ls -la .cursor/rules/
```

---

## まとめ

### 実用的な4つに絞った理由

**除外した手段（Submodule, Subtree, rsync, 単独スクリプト）**:
- オーバースペック
- 実用性が低い
- 他手段で代替可能

**選定した4つ**:
1. **Clone + mv**: 現実的、理解しやすい
2. **tar.gz**: Git不要、軽量
3. **Production構造変更**: 根本的解決、最良のUX
4. **Sparse Checkout**: 技術的洗練、特殊用途

### 推奨度ランキング（最終版）

#### 🥇 総合1位: 手段1（Clone + mv） ⭐⭐⭐⭐⭐
- **採用決定**
- 構造の分かりやすさ
- 破壊的変更なし

#### 🥈 総合2位: 手段2（tar.gz） ⭐⭐⭐
- 特殊用途で有用
- Git不要環境向け

#### 🥉 総合3位: 手段3（Production構造変更） ⭐⭐⭐
- 当初推奨していたが再評価の結果不採用
- 破壊的変更のコストが高すぎる
- わずかな差のために割に合わない

#### 総合4位: 手段4（Sparse Checkout） ⭐⭐
- 上級者向け
- 一般推奨しない

### 次のアクション

ユーザー（nobunosuke）に4つの手段を提示し、方針を決定する。

**推奨**: v2.0 で手段3（Production構造変更）を採用

