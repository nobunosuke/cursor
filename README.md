# タスク管理

## フォルダ構成

```
.cursor/
  tasks/
    {your-issue}.md
    {your-issue}.md
```

## 命名規則

`[TYPE]-[ISSUE_ID]_[description].md`

- TYPE: タスクの種類 (ex: FEAT, BUG, DOCS, etc.)
- ISSUE_ID: タスクのID (ex: 123)
- description: タスクの説明

## 例

```
.cursor/
  tasks/
    FEAT-123_add-feature.md
    BUG-456_fix-changelog.md
```

## 参考

- [Cursor でのタスク管理方法・命名規則（Claude）](https://claude.ai/chat/e4659ca0-7a25-4bf7-a3d0-d06d18f0e84b)