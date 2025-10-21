# Mermaid 図: ブランチ戦略とワークフロー

このファイルは、CHORE-37 のブランチ戦略を視覚化するための Mermaid 図を含みます。

## ブランチ構成図（Git Graph）

```mermaid
gitGraph
    commit id: "initial commit"
    branch production
    checkout production
    commit id: "public: rules only" tag: "v1.0.0"
    
    checkout main
    commit id: "dev: rules + tasks + README"
    
    branch feat/42-new-rule
    checkout feat/42-new-rule
    commit id: "implement new rule"
    commit id: "task completed"
    
    checkout main
    merge feat/42-new-rule
    commit id: "update rules" tag: "v1.1.0"
    
    checkout production
    commit id: "sync rules from main v1.1.0" tag: "v1.1.0"
    
    checkout main
    branch feat/43-workflow
    commit id: "improve workflow"
    
    checkout main
    merge feat/43-workflow
```

### 説明

- `main`: 開発用ブランチ（すべてのファイルを含む）
- `production`: 公開用ブランチ（`.cursor/rules/` のみ、orphan ブランチ）
- `feat/*`: 機能開発ブランチ（`main` から分岐）
- タグ: `production` ブランチでバージョン管理（`v1.0.0`, `v1.1.0` など）

---

## ワークフロー図（Sequence Diagram）

```mermaid
sequenceDiagram
    participant Issue as GitHub Issue
    participant Feature as feat/42-new-rule
    participant Main as main branch
    participant Actions as GitHub Actions
    participant Prod as production branch
    participant Tag as Git Tag

    Issue->>Feature: Create issue #42 → Create branch
    Feature->>Feature: Develop with task file<br/>(.cursor/tasks/)
    Feature->>Feature: Update rules<br/>(.cursor/rules/)
    Feature->>Main: Merge PR #42
    Main->>Main: Create tag (v1.1.0)
    Main->>Actions: Push tag triggers workflow
    Actions->>Prod: Auto-sync .cursor/rules/
    Prod->>Tag: Create tag v1.1.0
    Tag->>Issue: Create GitHub Release
```

### 説明

1. GitHub でイシュー作成
2. feature ブランチで開発（タスクファイルで進捗管理）
3. main にマージ
4. タグ作成（`v1.1.0`）
5. GitHub Actions が自動実行
6. production ブランチに同期
7. リリース作成

---

## 通常の開発フロー図（Flowchart）

```mermaid
flowchart TD
    Start([GitHub Issue 作成]) --> Branch[feat/XX-* ブランチ作成]
    Branch --> Dev[開発<br/>- タスクファイル更新<br/>- ルール編集]
    Dev --> Commit[コミット & プッシュ]
    Commit --> PR[Pull Request 作成]
    PR --> Review{コードレビュー}
    Review -->|修正必要| Dev
    Review -->|承認| Merge[main にマージ]
    Merge --> Ready{リリース準備完了?}
    Ready -->|No| End1([開発継続])
    Ready -->|Yes| CreateTag[タグ作成<br/>git tag v1.x.x]
    CreateTag --> PushTag[タグをプッシュ<br/>git push origin v1.x.x]
    PushTag --> Trigger[GitHub Actions トリガー]
    Trigger --> Sync[.cursor/rules/ を<br/>production に同期]
    Sync --> TagProd[production に<br/>タグ作成]
    TagProd --> Release[GitHub Release 作成]
    Release --> End2([完了])
```

---

## ディレクトリ構成図（Graph）

```mermaid
graph TB
    subgraph "main ブランチ"
        main_root["/"]
        main_cursor[".cursor/"]
        main_rules[".cursor/rules/<br/>(通常のディレクトリ)"]
        main_tasks[".cursor/tasks/<br/>(開発用)"]
        main_github[".github/workflows/"]
        main_readme["README.md"]
        
        main_root --> main_cursor
        main_root --> main_github
        main_root --> main_readme
        main_cursor --> main_rules
        main_cursor --> main_tasks
    end
    
    subgraph "production ブランチ (orphan)"
        prod_root["/"]
        prod_rules["rules/<br/>(配布用)"]
        prod_readme["README.md<br/>(cursor-rules 用)"]
        prod_license["LICENSE"]
        
        prod_root --> prod_rules
        prod_root --> prod_readme
        prod_root --> prod_license
    end
    
    main_rules -.->|GitHub Actions<br/>タグ作成時に同期| prod_rules
```

### 説明

- **main ブランチ**: 開発用、すべてのファイルを含む
- **production ブランチ**: 公開用、`.cursor/rules/` の内容のみ（orphan ブランチ）
- GitHub Actions でタグ作成時に自動同期

---

## Mermaid シンタックスエラーの調査

### 可能性のある原因

1. **日本語コメント**: Mermaid は日本語をサポートしているが、レンダラーによっては問題が起こる
2. **特殊文字**: `#`, `*`, `-` などがコンフリクトする可能性
3. **改行と空白**: インデントや改行の扱いが厳密
4. **Mermaid バージョン**: GitHub と Cursor で使用しているバージョンが異なる可能性
5. **テーマ設定**: `%%{init:...}%%` の構文が正しくない可能性

### エラー修正: cherry-pick の問題

**エラー内容:**
```
"Incorrect usage of "cherryPick" Source commit id should exist and provided"
```

**原因:**
Mermaid の gitGraph では `cherry-pick` の構文が制限されており、存在するコミット ID を参照する必要があります。しかし、ブランチ間で独立した履歴（orphan ブランチ）の場合、cherry-pick を直接表現できません。

**修正:**
cherry-pick を使わず、通常の commit で「同期」を表現します。実際の運用では GitHub Actions が自動的にファイルをコピーするため、Git 的には新しいコミットとして扱われます。

### GitHub での確認方法

このファイルを GitHub にプッシュして、正しくレンダリングされるか確認してください：

```bash
git add .cursor/tasks/ref/ref-CHORE-37_mermaid-diagrams.md
git commit -m "docs: Mermaid diagrams for branch strategy"
git push
```

GitHub の Web UI で `.cursor/tasks/ref/ref-CHORE-37_mermaid-diagrams.md` を開き、図が表示されるか確認してください。

