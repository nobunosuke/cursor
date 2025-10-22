# production ブランチ同期戦略のレビュー

## 現状の評価

### 🔴 問題点

#### 1. **orphan ブランチの複雑さ**
- orphan ブランチは履歴が完全に独立しているため、通常の Git 操作が使いにくい
- `git checkout ${TAG_COMMIT} -- .cursor/rules/` のような手動操作が必要
- マージや履歴の追跡ができない（orphan の時点で履歴が分断）

#### 2. **ハードコーディングが多すぎる**
```yaml
git rm -rf rules/ README.md LICENSE || true
git checkout ${TAG_COMMIT} -- .cursor/rules/ production-README.md LICENSE
mv .cursor/rules rules
mv production-README.md README.md
rm -rf .cursor
```
- ファイルパスが直接記述されている
- ファイル追加・削除のたびに workflow を修正が必要
- メンテナンスコストが高い

#### 3. **タグの二重管理**
```yaml
git tag -d ${GITHUB_REF_NAME} 2>/dev/null || true
git tag ${GITHUB_REF_NAME}
git push origin ${GITHUB_REF_NAME} --force
```
- main と production で同じタグを force push で上書き
- タグの整合性が保証されない
- Git の思想に反している（タグは不変であるべき）

#### 4. **エラーハンドリングが弱い**
- `|| true` で無視しているエラーがある
- 失敗時のロールバック処理がない

### 🟡 中程度の懸念

- **テストがない**: 同期が成功したか確認する処理がない
- **手動操作が必要**: タグを作成する操作が手動（自動化されていない）
- **ドキュメントとの乖離**: `branch-strategy.md` は説明的だが、なぜこの方法を選んだのかの根拠が弱い

---

## 🌍 業界標準のベストプラクティス

### 1. **GitHub Flow（最もシンプル）**

```
main ブランチのみ
  ↓
タグでリリース（v1.0.0, v1.1.0）
  ↓
GitHub Release
```

**特徴:**
- シンプル
- main が常にデプロイ可能な状態
- タグでリリース管理

**適用可能性:**
- ❌ `.cursor/rules/` だけを配布したいニーズに合わない

---

### 2. **git subtree（配布用ディレクトリの分離）**

```bash
# production ブランチに .cursor/rules/ のみを同期
git subtree push --prefix=.cursor/rules origin production
```

**特徴:**
- **ハードコーディング不要**: `--prefix` でディレクトリを指定するだけ
- **履歴が保たれる**: orphan ブランチではなく、main の履歴を引き継ぐ
- **シンプルな workflow**: GitHub Actions の処理が1行で完結
- **標準的**: Git 標準機能（git subtree は Git 組み込みコマンド）

**GitHub Actions の例:**
```yaml
- name: Sync to production
  run: |
    git subtree push --prefix=.cursor/rules origin production
```

**適用可能性:**
- ✅ `.cursor/rules/` を `production` ブランチの root に配置できる
- ✅ 履歴が保たれる
- ✅ メンテナンスコストが低い

**課題:**
- README.md と LICENSE の配置が工夫が必要
  - オプション1: `.cursor/rules/` 配下に含める
  - オプション2: 別途 GitHub Actions で配置（小規模なハードコーディングは残る）

---

### 3. **GitLab Flow（環境ブランチ）**

```
main（開発用）
  ↓ マージ
production（公開用）
```

**特徴:**
- main から production にマージで同期
- orphan ではなく通常のブランチ
- 履歴が保たれる

**適用可能性:**
- ❌ `.cursor/rules/` だけを配布したいニーズに合わない（全ファイルがコピーされる）
- ❌ `.cursor/tasks/` も含まれてしまう

---

### 4. **gh-pages パターン（ビルド成果物の分離）**

```
main（ソース）
  ↓ ビルド
gh-pages（成果物）
```

**特徴:**
- orphan ブランチを使う（現在の方法に近い）
- ビルド成果物（HTML/CSS/JS）を配置
- GitHub Pages での公開用

**適用可能性:**
- 🟡 現在の方法と似ているが、「ビルド」という概念が存在しない
- 🟡 orphan ブランチを使う正当性が薄い

---

## 💡 推奨戦略

### 🥇 **推奨1: git subtree + 軽微な調整**

#### 構成

```
.cursor/
  rules/
    README.md          # production 用 README を rules/ 内に配置
    LICENSE            # LICENSE も rules/ 内に配置
    cursor-tasks.mdc
    global.mdc
    git/
      ...
```

#### GitHub Actions

```yaml
name: Sync to production

on:
  push:
    tags:
      - 'v*'

jobs:
  sync:
    runs-on: ubuntu-latest
    
    permissions:
      contents: write
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Configure Git
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
      
      - name: Sync to production using git subtree
        run: |
          git subtree push --prefix=.cursor/rules origin production
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: ${{ github.ref_name }}
          name: cursor-rules ${{ github.ref_name }}
          body: |
            ## cursor-rules ${{ github.ref_name }}
            
            このリリースには、Cursor 共有ルールファイルが含まれています。
            
            ### 使用方法
            
            ```bash
            # プロジェクトのルートディレクトリで実行
            git clone -b production --single-branch https://github.com/${{ github.repository }}.git .cursor/rules
            ```
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### メリット

- ✅ **シンプル**: ハードコーディングがほぼゼロ
- ✅ **標準的**: git subtree は Git 標準機能
- ✅ **履歴が保たれる**: main の履歴を引き継ぐ
- ✅ **メンテナンスコスト低**: ファイル追加・削除時に workflow を変更不要

#### デメリット

- 🟡 README と LICENSE を `.cursor/rules/` 内に配置する必要がある（ディレクトリ構造変更）

---

### 🥈 **推奨2: 現状維持 + リファクタリング**

orphan ブランチを維持しつつ、GitHub Actions を改善する案。

#### 改善点

1. **変数化**:
```yaml
env:
  SOURCE_FILES: ".cursor/rules/ production-README.md LICENSE"
  TARGET_MAPPINGS: "rules/::.cursor/rules/ README.md::production-README.md LICENSE::LICENSE"
```

2. **スクリプト化**:
```yaml
- name: Sync to production
  run: |
    bash .github/scripts/sync-production.sh ${GITHUB_REF_NAME}
```

3. **エラーハンドリング強化**:
```bash
set -euo pipefail  # エラー時に即座に停止
```

4. **テスト追加**:
```yaml
- name: Verify sync
  run: |
    # 必須ファイルが存在するか確認
    test -d rules || exit 1
    test -f README.md || exit 1
    test -f LICENSE || exit 1
```

#### メリット

- ✅ **現状の構造を維持**: ディレクトリ変更不要
- ✅ **メンテナンス性向上**: 変数化・スクリプト化で見通しが良くなる

#### デメリット

- 🔴 **根本的な複雑さは残る**: orphan ブランチの制約は変わらない
- 🟡 **追加のファイル管理**: スクリプトファイルが必要

---

## 📋 比較表

| 項目 | 現状 | 推奨1（subtree） | 推奨2（改善版） |
|------|------|------------------|------------------|
| **シンプルさ** | 🔴 複雑 | 🟢 シンプル | 🟡 中程度 |
| **標準性** | 🟡 特殊（orphan） | 🟢 Git標準 | 🟡 特殊（orphan） |
| **履歴管理** | 🔴 分断 | 🟢 保持 | 🔴 分断 |
| **メンテナンス** | 🔴 高コスト | 🟢 低コスト | 🟡 中コスト |
| **ディレクトリ変更** | 不要 | 必要 | 不要 |
| **エラー処理** | 🔴 弱い | 🟢 強い | 🟡 改善可 |

---

## 🎯 結論と提案

### 私の率直な評価

現在の方法は **「gh-pages パターンを参考にしたが、適用場面が異なる」** という印象です。

- gh-pages パターン: ビルド成果物（変換されたファイル）を配置 → orphan が正当化される
- cursor-rules: 同じファイルを別の場所にコピーするだけ → orphan の必要性が薄い

**「シンプルに設定できると思ってた」** という直感は正しいです。本来、もっとシンプルにできます。

### 提案

#### **短期的（今すぐ改善）**
→ **推奨2（現状維持 + リファクタリング）**
- ディレクトリ構造を変えずに、メンテナンス性を向上

#### **中長期的（根本的改善）**
→ **推奨1（git subtree）**
- `.cursor/rules/` 内に README.md と LICENSE を配置
- orphan ブランチを廃止し、通常のブランチ + git subtree に移行
- GitHub Actions をシンプル化

---

## 参考リンク

- [Git subtree の使い方](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%81%95%E3%81%BE%E3%81%96%E3%81%BE%E3%81%AA%E3%83%84%E3%83%BC%E3%83%AB-%E3%82%B5%E3%83%96%E3%83%84%E3%83%AA%E3%83%BC)
- [GitHub Flow](https://docs.github.com/ja/get-started/quickstart/github-flow)
- [GitLab Flow](https://about.gitlab.com/topics/version-control/what-are-gitlab-flow-best-practices/)
- [GitHub Actions のベストプラクティス](https://docs.github.com/ja/actions/learn-github-actions/security-hardening-for-github-actions)

