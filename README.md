# Clsswjz

一个基于 Flutter 开发的现代化记账应用，支持多账本管理、记事、债务管理等功能。

<div align="center">
  <img src="assets/images/app_icon.png" alt="App Icon" width="120"/>
</div>

## 功能特点 ✨

- 📚 **多账本管理**
  - 支持创建多个账本
  - 账本间数据互相独立
  - 支持账本共享与协作

- 💰 **记账功能**
  - 支持收入、支出、转账记录
  - 自定义分类管理
  - 支持标签、商家、项目等多维度记录
  - 支持附件（票据、图片等）

- 📝 **记事功能**
  - 支持笔记和待办事项
  - 富文本编辑
  - 标签分类

- 💳 **债务管理**
  - 借入借出记录
  - 还款/收款跟踪
  - 债务状态管理

- 📊 **数据统计**
  - 收支趋势分析
  - 分类占比统计
  - 自定义时间范围

- 🌐 **多端同步**
  - 支持私有服务器部署
  - 数据实时同步
  - 离线使用

- 🎨 **个性化**
  - Material Design 3 设计
  - 自定义主题颜色
  - 深色模式支持
  - 多语言支持（简体中文、繁体中文、英文）

## 技术栈 🛠️

- **框架**: Flutter 3.x
- **状态管理**: Provider
- **数据持久化**: SQLite、Shared Preferences
- **网络**: Dio
- **国际化**: Intl
- **其他关键依赖**:
  - `custom_refresh_indicator`: 自定义下拉刷新
  - `flutter_slidable`: 滑动操作
  - `path_provider`: 文件管理
  - `sqflite`: 本地数据库
  - `provider`: 状态管理
  - `shared_preferences`: 配置存储
  - `dio`: 网络请求
  - `intl`: 国际化

## 开始使用 🚀

### 环境要求

- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code
- Android SDK / Xcode（取决于目标平台）

### 安装步骤

1. 克隆项目
```bash
git clone https://github.com/yourusername/clsswjz.git
```

2. 安装依赖
```bash
cd clsswjz
flutter pub get
```

3. 运行项目
```bash
flutter run
```

## 项目结构 📁

```
lib/
├── enums/          # 枚举定义
├── manager/        # 管理器类
├── models/         # 数据模型
├── pages/          # 页面
├── providers/      # 状态管理
├── routes/         # 路由管理
├── utils/          # 工具类
└── widgets/        # 可复用组件
```

## 版本发布 🚀

我们使用 [CHANGELOG.md](CHANGELOG.md) 文件记录所有版本的变更，并通过 GitHub Actions 自动构建和发布应用。

### 版本号规范

我们采用 [语义化版本](https://semver.org/lang/zh-CN/) 规范，格式为：`主版本号.次版本号.修订号[-标签]`

- **主版本号**：当做了不兼容的 API 修改
- **次版本号**：当做了向下兼容的功能性新增
- **修订号**：当做了向下兼容的问题修正
- **标签**：如 alpha、beta、rc 等，表示预发布版本

### 发布流程

详细的发布流程请参考 [发布指南](docs/release_guide.md)。

## 贡献指南 🤝

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 开源协议 📄

本项目采用 MIT 协议 - 查看 [LICENSE](LICENSE) 文件了解详情

## 联系我们 📧

- 项目主页：[GitHub](https://github.com/yourusername/clsswjz)
- 问题反馈：[GitHub Issues](https://github.com/yourusername/clsswjz/issues)

## 致谢 🙏

感谢所有为这个项目做出贡献的开发者！
