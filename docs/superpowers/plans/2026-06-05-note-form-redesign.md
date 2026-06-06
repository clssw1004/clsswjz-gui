# 记事表单重设计 + 关联账目集成

> **For agentic workers:** Use inline execution (single file change).

**Goal:** 将 note_form_page.dart 重写为 Apple Notes 极简风格并添加 ItemRelationPanel

**Architecture:** 单文件修改，保留原有 NoteFormProvider 逻辑，重写 UI 布局层。工具栏从展开式改为固定精简式，分组从 SelectFormField 改为内联 Chip，附件从完整表单改为紧凑行，底部添加 ItemRelationPanel。

**Tech Stack:** Flutter, flutter_quill, Provider

**参考文档:** `docs/superpowers/specs/2026-06-05-note-form-redesign.md`

---

### Task 1: 重写 note_form_page.dart

**Files:**
- Modify: `lib/pages/book/note_form_page.dart`

改动项：
1. AppBar — 保持现有，无改动
2. 标题 — 替换 `CommonTextFormField` 为原生 `TextField`，无装饰
3. 编辑器 — `QuillEditor` 去除所有容器/边框/背景
4. 工具栏 — 精简为 B/I/U/☐/☰，去掉展开/收起逻辑
5. 分组 — 替换为 `Wrap` + `Chip` 内联展示
6. 附件 — 替换 `CommonAttachmentField` 为紧凑行
7. 关联账目 — 底部添加 `ItemRelationPanel`
8. 移除 `_showFullToolbar` 状态

