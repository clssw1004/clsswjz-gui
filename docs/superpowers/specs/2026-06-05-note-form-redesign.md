# 记事表单页面重设计 + 关联账目集成

## 整体布局

Apple Notes 极简风格，无边框、无容器背景、大量留白。

```
Scaffold
└── Column
    ├── AppBar (返回 + 保存)
    ├── Title (无边框, fontSize 22, fontWeight 600)
    ├── Divider (超细)
    ├── Expanded: QuillEditor (无边框无背景)
    ├── QuillSimpleToolbar (B/I/U/☐/☰ 固定底部单行)
    ├── Divider
    ├── Group Chips (Wrap + Chip 内联)
    ├── Divider
    ├── Attachments (紧凑行 + 缩略图)
    ├── Divider
    └── ItemRelationPanel
```

## 改动清单

### 1. AppBar
保持不变，现有 `CommonAppBar` + 保存按钮。

### 2. 标题
- 移除 `CommonTextFormField` 替换为原生 `TextField`
- 无边框、无装饰
- `style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)`
- `decoration: null`

### 3. 富文本编辑器
- `QuillEditor` 移除所有容器装饰、背景色、边距
- 配置：`padding: EdgeInsets.zero`, `autoFocus: false`
- `Expanded` 包裹，撑满中间区域

### 4. 工具栏（极简）
- `QuillSimpleToolbar` 只保留：
  - `showBoldButton: true`
  - `showItalicButton: true`
  - `showUnderLineButton: true`
  - `showListCheck: true`
  - `showListBullets: true`
- 全部其他设为 `false`
- 去掉展开/收起逻辑
- 固定在编辑器底部，单行

### 5. 分组（Chip 样式）
- 替换 `CommonSelectFormField` 为 `Wrap` + `Chip`
- 选中 Chip 高亮，点击取消选中
- 末尾 [+] Chip 新建分组
- 数据源：`provider.groups` / `provider.groupCode`

### 6. 附件（紧凑模式）
- 替换 `CommonAttachmentField` 完整表单为行内紧凑布局
- 图片显示小缩略图 + 文件名
- [+] 按钮添加
- 点击删除

### 7. 关联账目
- 底部嵌入 `ItemRelationPanel`
- `relationCode: 'note'`
- `relationId: provider.note.id`
- `accountBookId: provider.bookMeta.id`
- 搜索当前账本已有账目，关联后自动保存
- 可滑动删除

### 8. 移出内容
- 移除 `_showFullToolbar` 状态逻辑
- 移除展开/收起的 `InkWell`

## 文件修改

| 文件 | 操作 |
|------|------|
| `lib/pages/book/note_form_page.dart` | 修改 — 完全重写 UI 布局 |
