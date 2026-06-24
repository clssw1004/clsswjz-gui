# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Flutter 开发的私有化部署记账应用，支持多账本、记账、记事、债务管理、数据统计等功能。使用 Provider 进行状态管理，Drift (SQLite) 作为本地数据库。

## 开发命令

```bash
# 安装依赖
flutter pub get

# 运行项目
flutter run

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios

# 代码检查
flutter analyze
```

## 架构概览

```
lib/
├── pages/           # 页面（按功能模块组织）
│   ├── tabs/        # 底部Tab页面（账目、统计、记事、我的）
│   ├── book/        # 账本相关页面
│   ├── settings/    # 设置页面
│   └── gift_card/   # 礼物卡模块
├── providers/       # Provider状态管理
├── services/        # 业务服务层
├── models/          # 数据模型（VO、DTO）
├── widgets/         # 通用组件
├── database/        # Drift数据库定义
├── manager/         # 管理器（AppConfig、Database等）
├── routes/          # 路由配置
├── utils/           # 工具类
└── theme/           # 主题配置
```

## 关键约定

1. **UI规范**：遵循 Material Design 3，从主题获取颜色/间距
2. **国际化**：使用 `L10nManager.l10n` 获取国际化文本
3. **数据库**：使用 Drift，模型在 `lib/models/`，数据库定义在 `lib/database/`
4. **状态管理**：Provider，Provider定义在 `lib/providers/`
5. **Lint**：不得使用过时API（如 `withOpacity`），修改后检查 lint 问题
6. **新模块 checklist**：新增模块接口必须对照 `docs/design/data_driver_guide.md` 逐条确认——update 用统一方法而非单字段专用方法、LogBuilder 的 `executeLog`/`fromLog` 必须覆盖 create/update/delete 三个 OperateType
7. **技能流程**：遇到复杂任务或新需求时，必须先 invoke 相关 Skill tool 再动手——顺序：`superpowers:brainstorming`（梳理需求）→ `superpowers:writing-plans`（写计划）→ 执行 → `superpowers:verification-before-completion`（完成前验证）。简单修改变量名、改文案、查代码、小 bug 等无需走此流程

## 礼物卡模块

礼物卡功能有独立的设计文档：`docs/design/gift_card_design.md`，包含状态流转图和业务流程。

## 发版流程

更新版本时提供版本号即可，自动执行以下操作：

### 需要修改的文件

| 文件 | 修改内容 |
|------|----------|
| `pubspec.yaml` | `version` 字段改为新版本号 |
| `CHANGELOG_CN.md` | 新增版本条目，描述中文功能变更 |
| `CHANGELOG.md` | 新增版本条目，描述英文功能变更 |

### 注意事项

1. **分支**：所有功能开发在 `feat/` 分支进行，发版时切到 `main` 分支
2. **变更日志**：只写功能变动，不写实现细节；中英文版本内容对应
3. **版本号格式**：正式版用 `x.y.z`，预览版用 `x.y.z-alpha.n`
4. **提交**：修改后提交到 main 分支
5. **国际化**：所有界面显示的文字要支持国际化，不要使用硬编码（使用l10n）
6. 所有的对话回答使用中文