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

## 礼物卡模块

礼物卡功能有独立的设计文档：`docs/design/gift_card_design.md`，包含状态流转图和业务流程。