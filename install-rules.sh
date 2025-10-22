#!/usr/bin/env bash
set -euo pipefail

# Cursor Rules セットアップスクリプト
# production ブランチから .cursor/rules/ を正しく展開します

# 色付きメッセージ
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${BLUE}[SUCCESS]${NC} $1"
}

# 使い方
usage() {
    cat << EOF
使い方: $0 [OPTIONS]

OPTIONS:
    -v VERSION    特定のバージョン（タグ）を指定（例: v1.0.0）
    -y            確認をスキップ（自動実行）
    -h            このヘルプメッセージを表示

例:
    $0              # 最新版をインストール（確認あり）
    $0 -y           # 最新版をインストール（自動）
    $0 -v v1.0.0    # v1.0.0 をインストール
    $0 -v v1.0.0 -y # v1.0.0 をインストール（自動）
EOF
    exit 1
}

# リポジトリURL
REPO_URL="https://github.com/nobunosuke/cursor-rules.git"
VERSION=""
AUTO_YES=false

# オプション解析
while getopts "v:yh" opt; do
    case $opt in
        v)
            VERSION="$OPTARG"
            ;;
        y)
            AUTO_YES=true
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

# バナー表示
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Cursor Rules インストーラー        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

# プロジェクトルートにいるか確認
if [ ! -d ".git" ]; then
    error "Gitリポジトリのルートディレクトリで実行してください"
    exit 1
fi

info "インストール先: $(pwd)/.cursor/rules/"
if [ -n "$VERSION" ]; then
    info "バージョン: $VERSION"
else
    info "バージョン: 最新版（production ブランチ）"
fi
echo ""

# 既存の .cursor/rules がある場合は警告
if [ -d ".cursor/rules" ]; then
    warn "既存の .cursor/rules/ が見つかりました"
    
    if [ "$AUTO_YES" = false ]; then
        echo ""
        read -p "削除して続行しますか？ (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "キャンセルしました"
            exit 0
        fi
    else
        info "既存のディレクトリを自動削除します（-y オプション）"
    fi
    
    info "既存の .cursor/rules/ を削除しています..."
    rm -rf .cursor/rules
fi

# 一時ディレクトリが残っている場合は削除
if [ -d ".cursor/rules-temp" ]; then
    warn ".cursor/rules-temp が残っています。削除します"
    rm -rf .cursor/rules-temp
fi

# production ブランチをクローン
info "production ブランチをクローンしています..."
if [ -n "$VERSION" ]; then
    # 特定のバージョンをクローン
    git clone -b production --single-branch \
        "$REPO_URL" .cursor/rules-temp
    
    cd .cursor/rules-temp
    
    # タグが存在するか確認
    if ! git rev-parse "$VERSION" >/dev/null 2>&1; then
        error "バージョン $VERSION が見つかりません"
        cd ../..
        rm -rf .cursor/rules-temp
        exit 1
    fi
    
    info "バージョン $VERSION をチェックアウトしています..."
    git checkout "$VERSION" --quiet
    cd ../..
else
    # 最新版をクローン
    git clone -b production --single-branch --depth 1 \
        "$REPO_URL" .cursor/rules-temp
fi

# rules/ ディレクトリを確認
if [ ! -d ".cursor/rules-temp/rules" ]; then
    error ".cursor/rules-temp/rules が見つかりません"
    rm -rf .cursor/rules-temp
    exit 1
fi

# .cursor ディレクトリを作成（存在しない場合）
mkdir -p .cursor

# rules/ を .cursor/rules/ に移動
info ".cursor/rules/ を配置しています..."
mv .cursor/rules-temp/rules .cursor/rules

# 一時ディレクトリを削除
rm -rf .cursor/rules-temp

# 結果を確認
echo ""
success "インストールが完了しました！"
echo ""
info "展開されたファイル:"
ls -la .cursor/rules/ | tail -n +4
echo ""

# 検証：二重ネストがないか確認
if [ -d ".cursor/rules/rules" ]; then
    error "❌ 二重ネスト問題が発生しました！"
    error ".cursor/rules/rules/ が存在します"
    error "これはバグです。Issue を報告してください。"
    exit 1
fi

# 期待するファイルが存在するか確認
if [ -f ".cursor/rules/cursor-tasks.mdc" ] && \
   [ -f ".cursor/rules/global.mdc" ] && \
   [ -d ".cursor/rules/git" ]; then
    success "✅ 正しく展開されました"
else
    warn "⚠️  期待するファイルが見つかりません"
    warn "以下のファイルを確認してください:"
    warn "  - .cursor/rules/cursor-tasks.mdc"
    warn "  - .cursor/rules/global.mdc"
    warn "  - .cursor/rules/git/"
fi

# .cursor/tasks/ の作成を提案
echo ""
if [ ! -d ".cursor/tasks" ]; then
    info "タスク管理機能を使用する場合は .cursor/tasks/ が必要です"
    
    if [ "$AUTO_YES" = false ]; then
        read -p ".cursor/tasks/ を作成しますか？ (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p .cursor/tasks
            cat > .cursor/tasks/README.md << 'EOF'
# タスクファイル

このディレクトリには、GitHub イシューに対応するタスクファイルを配置します。

詳細は `.cursor/rules/cursor-tasks.mdc` を参照してください。

## 命名規則

`{TYPE}-{ID}_{description}.md`

例:
- `FEAT-42_user-authentication.md` → GitHub イシュー #42
- `DOCS-1_issue-driven.md` → GitHub イシュー #1
EOF
            success ".cursor/tasks/ を作成しました"
        fi
    else
        info "自動モードのため .cursor/tasks/ の作成をスキップします"
    fi
else
    info ".cursor/tasks/ は既に存在します"
fi

# 次のステップを案内
echo ""
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info "次のステップ:"
echo ""
echo "  1. 変更を確認:"
echo "     git status"
echo ""
echo "  2. コミット:"
echo "     git add .cursor/"
echo "     git commit -m 'feat: Cursor共有ルールを追加'"
echo ""
echo "  3. プッシュ:"
echo "     git push"
echo ""
info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
success "Cursor で開き直して、ルールが適用されているか確認してください 🚀"
echo ""
