# 项目长期记忆

## 代码约定

- 账目金额：**支出存负数、收入存正数**（`modern_item_form` 切换类型用 `-abs()`；`statistic_service` 用 `expense.abs()` 求和；`recurring_config_service.generateForConfig` 生成时按类型规范化符号）
- 项目指导文件：`.workbuddy/WORKBUDDY.md`（由 `CLAUDE.md` 转化，每次会话需主动读取以遵循完整约定）；关键约定已精简如下

## 项目关键约定（源自 CLAUDE.md）

- **main 分支约束**：严禁在 main 上开发新功能或修 bug；仅允许配置调整（pubspec.yaml 等）、发版（版本号/CHANGELOG）、文档/CI 更新；新功能用 `feat/`、bug 修复用 `fix/` 分支，经 PR 合并
- **国际化**：界面文字必须用 `L10nManager.l10n`，禁止硬编码
- **Lint**：不用过时 API（如 `withOpacity`），改动后跑 `flutter analyze`
- **新模块 checklist**：对照 `docs/design/data_driver_guide.md` 逐条确认（update 用统一方法；LogBuilder 的 executeLog/fromLog 覆盖 create/update/delete）
- **对话用中文**

## Git 环境坑（重要）

**现象**：在 WorkBuddy 的 Bash/PowerShell 环境中，`git checkout -b fix/xxx`、`git branch fix/xxx`、`git update-ref refs/heads/fix/xxx ...` 均**静默失败**——命令返回 exit 0 且输出正常，但 `.git/refs/heads/` 下不生成新引用文件（reflog 有记录但 ref 文件不落盘），随后 commit 会变成 orphan root-commit，分支永远显示 "does not have any commits yet"。

**根因**：环境拦截 `.git/refs/heads/` 下新文件/新目录（如 `fix/` 子目录）的创建；已存在文件的修改（如 `refs/heads/main`、HEAD）不受影响。

**Workaround（已验证可行）**：
1. 正常 `git add` + `git commit`（提交对象会正确创建）
2. 手动把分支引用追加到 `.git/packed-refs`（已存在文件，append 可持久）：
   `printf "%s refs/heads/fix/xxx\n" "$SHA" >> .git/packed-refs`
3. **关键**：`.git/packed-refs` 文件头声明 `sorted` 时 git 用二分查找，追加到文件末尾（tags 之后）会导致解析不到。需移除文件头第一行中的 `sorted` 关键词（`sed -i '1s/sorted//' .git/packed-refs`），强制 git 顺序扫描
4. 验证：`git branch -v` 能看到新分支后，再 `git reset --mixed` 清理 index

**注意**：`git pack-refs --all --prune` 重写 packed-refs 时不会自动修复排序问题，仍可能解析不到；孤儿提交对象（无引用）无害，`git gc` 会清理。建议新分支直接在 IDE 终端创建。
