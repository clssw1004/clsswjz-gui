# 发布指南

本文档提供了如何维护版本变更记录并将发版说明添加到GitHub Release页面的详细说明。

## 维护CHANGELOG.md文件

CHANGELOG.md文件用于记录项目的所有版本变更。每次发布新版本前，都需要更新此文件。

### 格式规范

CHANGELOG.md文件应遵循以下格式：

```markdown
# 更新日志 (CHANGELOG)

所有版本的重要更改都将记录在此文件中。

## [版本号] - 发布日期

### 分类1（如：新功能、界面优化、功能改进、问题修复等）
- 变更项1
- 变更项2
- ...

### 分类2
- 变更项1
- 变更项2
- ...

## [旧版本号] - 发布日期
...
```

### 更新步骤

1. 在CHANGELOG.md文件顶部添加新版本的信息
2. 版本号格式应为 `[x.y.z-标签]`，如 `[1.0.0-alpha.3]`
3. 发布日期格式应为 `YYYY-MM-DD`
4. 按分类列出所有变更项
5. 每个变更项应简洁明了，使用动词开头

## 发布到GitHub

项目使用GitHub Actions自动构建和发布。发布流程如下：

### 准备工作

1. 更新代码中的版本号：
   - `pubspec.yaml` 中的 `version` 字段
   - `windows/runner/Runner.rc` 中的 `VERSION_AS_STRING`
   - `lib/pages/settings/about_page.dart` 中显示的版本号

2. 更新CHANGELOG.md文件，添加新版本的变更记录

### 发布步骤

1. 提交所有更改：
   ```bash
   git add .
   git commit -m "chore: bump version to x.y.z-标签"
   ```

2. 创建新的标签：
   ```bash
   git tag vx.y.z-标签
   ```
   注意：标签名必须以 `v` 开头，后跟版本号

3. 推送更改和标签：
   ```bash
   git push origin main
   git push origin vx.y.z-标签
   ```

4. GitHub Actions将自动触发构建流程，并创建一个新的Release
   - Release标题将是标签名
   - Release说明将自动从CHANGELOG.md文件中提取
   - 构建的应用程序将作为附件添加到Release中

## 自动化说明

GitHub Actions工作流程（`.github/workflows/flutter_build.yml`）会执行以下操作：

1. 检出代码
2. 从CHANGELOG.md文件中提取当前版本的发布说明
3. 为不同平台（Windows、Linux、Android）构建应用
4. 创建GitHub Release，并将构建的应用作为附件添加
5. 将提取的发布说明设置为Release说明

这样，只需维护好CHANGELOG.md文件，发布说明就会自动添加到GitHub Release页面。 