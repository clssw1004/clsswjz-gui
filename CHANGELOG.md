# Changelog / 更新日志

All notable changes to this project will be documented in this file.
本文件记录项目的所有重要更改。

## [1.0.0-alpha.16] - 2024-04-03

### Feature Enhancements
- Added attachment support for notes
  - Support uploading and managing multiple attachments in notes
  - Support viewing and deleting attachments
  - Support various file types including images and documents
  - Optimized attachment storage and retrieval mechanism

### Code Optimization
- Enhanced note attachment handling
  - Implemented efficient attachment state management
  - Added robust error handling for file operations
  - Improved attachment synchronization with backend
  - Optimized attachment upload and deletion process

### 功能增强
- 添加记事附件支持
  - 支持在记事中上传和管理多个附件
  - 支持查看和删除附件
  - 支持包括图片和文档在内的多种文件类型
  - 优化附件存储和检索机制

### 代码优化
- 增强记事附件处理
  - 实现高效的附件状态管理
  - 添加健壮的文件操作错误处理
  - 改进附件与后端的同步机制
  - 优化附件上传和删除流程

### Enhancements
- Enhanced note editor functionality
  - Migrated note form state management to Provider pattern
  - Improved attachment handling with better error management
  - Optimized UI responsiveness and state updates

### Code Optimization
- Refactored note form page structure
  - Separated state management into dedicated provider
  - Enhanced code maintainability and reusability
  - Improved error handling and user feedback

### 功能优化
- 增强笔记编辑器功能
  - 将笔记表单状态管理迁移到Provider模式
  - 改进附件处理，提供更好的错误管理
  - 优化UI响应性和状态更新

### 代码优化
- 重构笔记表单页面结构
  - 将状态管理分离到专用provider
  - 增强代码可维护性和复用性
  - 改进错误处理和用户反馈

## [1.0.0-alpha.15] - 2024-03-27

### Enhancements
- Enhanced data synchronization mechanism
  - Added automatic sync trigger for newly created transactions
  - Added automatic sync trigger for newly created notes
  - Added automatic sync trigger for newly created debts
  - Optimized sync state management to prevent duplicate syncs

### Bug Fixes
- Fixed sync service URL not taking effect immediately
  - Previously required app restart to apply changes
  - Now updates take effect as soon as the URL is modified

### 功能优化
- 增强数据同步机制
  - 添加新建账目时自动触发同步
  - 添加新建笔记时自动触发同步
  - 添加新建债务时自动触发同步
  - 优化同步状态管理，防止重复同步

### 问题修复
- 修复同步服务URL修改后不能立即生效的问题
  - 之前需要重启应用才能生效
  - 现在修改后立即生效

## [1.0.0-alpha.14] - 2024-03-20

### Enhancements
- Improved account type switching experience
  - Automatically convert amount to positive when switching from expense to income
  - Automatically convert amount to negative when switching from income to expense
  - Optimized amount conversion logic to maintain data consistency

### 功能优化
- 优化账目类型切换体验
  - 在账目类型从支出切换到收入时，自动将金额转换为正数
  - 在账目类型从收入切换到支出时，自动将金额转换为负数
  - 优化金额转换逻辑，保持数据一致性

## [1.0.0-alpha.13] - 2024-03-16

### Enhancements
- Optimized account display in transaction list
  - Display account name as a badge after category name
  - Limit account name to maximum 10 characters
  - Adjusted badge style with borders and lighter colors
  - Improved text alignment and spacing
- Enhanced attachment selection experience
  - Added image_picker for photo gallery selection
  - Optimized bottom menu style
  - Improved visual feedback following Material Design 3 guidelines

### Code Optimization
- Optimized ItemsContainer component layout structure
- Enhanced CommonAttachmentField component file selection functionality
- Improved code maintainability and reusability

### 功能优化
- 优化账目列表中的账户显示
  - 将账户名称以徽章形式显示在分类名称后
  - 限制账户名称最多显示10个字
  - 调整徽章样式，使用边框和更浅的颜色
  - 改进文字对齐和间距
- 增强附件选择体验
  - 添加使用 image_picker 的相册选择选项
  - 优化底部菜单样式
  - 改进视觉反馈，符合 Material Design 3 规范

### 代码优化
- 优化 ItemsContainer 组件的布局结构
- 优化 CommonAttachmentField 组件的文件选择功能
- 改进代码可维护性和复用性

## [1.0.0-alpha.12] - 2024-03-15

### Enhancements
- Improved attachment upload user experience
  - Fixed image selection issues on certain devices
  - Optimized file picker implementation
  - Enhanced file selection compatibility

### Code Optimization
- Enhanced CommonAttachmentField component implementation
  - Integrated image_picker for gallery selection
  - Utilized file_picker for file selection
  - Improved code maintainability

### 功能优化
- 优化附件上传功能的用户体验
  - 修复在某些设备上无法从相册选择图片的问题
  - 优化文件选择器的实现方式
  - 改进文件选择的兼容性

### 代码优化
- 优化 CommonAttachmentField 组件的实现
  - 使用 image_picker 处理相册选择
  - 使用 file_picker 处理文件选择
  - 改进代码的可维护性

## [1.0.0-alpha.11] - 2025-03-12

### Bug Fixes
- Fixed transaction time resetting to 00:00 bug
- Fixed synchronization issue caused by null account type check

### 问题修复
- 修改账目时间会变成00:00的bug
- 同步时因更新账户类型未判断空导致的同步问题

## [1.0.0-alpha.10] - 2025-03-11

### Code Refactoring
- Optimized data driver layer code structure
  - Reorganized LogDataDriver class methods by CRUD order (Create, Read, Update, Delete)
  - Grouped methods by business domain (User, Book, Transaction, Category, Merchant, Tag, Fund Account, Note, Debt)
  - Maintained consistent method order between LogDataDriver and BookDataDriver
  - Enhanced code readability and maintainability

### 代码重构
- 优化数据驱动层代码结构
  - 按照CRUD顺序（增、删、改、查）重新排列LogDataDriver类中的方法
  - 按业务域对方法进行分组（用户、账本、记账、分类、商家、标签、资金账户、笔记、债务）
  - 保持LogDataDriver和BookDataDriver之间的方法顺序一致
  - 提高代码可读性和可维护性

## [1.0.0-alpha.9] - 2025-03-10

### Feature Enhancements
- Added refund functionality
  - Support refund operation for expense transactions
  - Automatically link refund records as income to original transactions
  - Optimized refund form with auto-filled original transaction information
  - Support modification of refund amount, account, and date

### UI Improvements
- Enhanced transaction edit page
  - Show refund button only for expense transactions
  - Improved form layout and interaction experience
- Optimized form components
  - Removed unnecessary Provider dependencies
  - Simplified component structure for better maintainability

### Code Quality Improvements
- Refactored RefundFormPage component
  - Removed nested components for simpler code structure
  - Optimized state management for better performance
  - Added error handling and user feedback
- Added event notification mechanism
  - Send event notifications after refund operations
  - Optimized data update process

### Framework Updates
- Upgraded Flutter to 3.29.1

### 功能增强
- 添加退款功能
  - 支持退款操作
  - 自动将退款记录链接为收入到原始交易
  - 优化退款表单，自动填充原始交易信息
  - 支持退款金额、账户和日期的修改

### UI 改进
- 增强交易编辑页面
  - 仅对支出交易显示退款按钮
  - 改进表单布局和交互体验
- 优化表单组件
  - 移除不必要的Provider依赖
  - 简化组件结构，便于维护

### 代码质量改进
- 重构退款表单页面
  - 移除嵌套组件，简化代码结构
  - 优化状态管理，提高性能
  - 添加错误处理和用户反馈
- 添加事件通知机制
  - 在退款操作后发送事件通知
  - 优化数据更新过程

### 框架更新
- 升级Flutter到3.29.1

## [1.0.0-alpha.8] - 2025-03-05

### Feature Optimization
- Refactored event handling system
  - Merged transaction/debt/note events into unified file
  - Added debt and transaction change event bus subscriptions
  - Improved event dispatch mechanism using database entity updates
  - Optimized event response process for better app responsiveness

- Enhanced UI component interaction
  - Optimized list container header with navigation support
  - Updated statistics card to show monthly data
  - Improved selection box filtering to avoid duplicate options
  - Enhanced form component interaction experience

- Code Quality Improvements
  - Split note form page save method into create/update
  - Added type-safe handling
  - Optimized data deletion process with validation
  - Improved code maintainability and readability

### Internationalization Improvements
- Added multilingual support for new texts like "Current Month"
- Updated Chinese/Traditional Chinese/English translations

### Bug Fixes
- Fixed duplicate "Add New" option in filtered selection boxes
- Fixed fund account selection logic
- Fixed symbol matching mechanism

### 功能优化
- 重构事件处理系统
  - 将交易/债务/笔记事件合并到一个文件中
  - 添加债务和交易变化事件总线订阅
  - 使用数据库实体更新改进事件调度机制
  - 优化事件响应过程，提高应用程序响应速度

- 增强UI组件交互
  - 优化列表容器标题，添加导航支持
  - 更新统计卡片以显示月度数据
  - 改进选择框过滤，避免重复选项
  - 增强表单组件交互体验

- 代码质量改进
  - 将笔记表单页面保存方法拆分为创建/更新
  - 添加类型安全处理
  - 优化数据删除过程，添加验证
  - 改进代码可维护性和可读性

### 国际化改进
- 添加多语言支持，如"Current Month"
- 更新中文/传统中文/英文翻译

### 问题修复
- 修复过滤选择框中的重复"Add New"选项
- 修复资金账户选择逻辑
- 修复符号匹配机制

## [1.0.0-alpha.7] - 2025-03-04

### Technical Improvements
- Enhanced statistics data management
  - Improved statistics data loading with event-driven auto-updates
  - Optimized data synchronization during book switching
  - Enhanced statistics data loading performance and reliability
  - Improved state management, reduced redundant code
  - Optimized memory usage, prevented memory leaks

- Improved category statistics list
  - Limited default display count for faster page loading
  - Added "View More" functionality
  - Supported customizable default display count
  - Added internationalization for "Collapse" and "View More"
  
- Enhanced statistics page layout
  - Added book statistics card showing total income, expenses, and balance
  - Optimized data loading for better page responsiveness
  - Improved state management for better code maintainability
  - Added time range selection for "Last Day", "This Month", and "All"
  - Optimized statistics card layout, adjusted expense and income display order

### Bug Fixes
- Fixed statistics data not loading during app initialization
- Fixed statistics not updating immediately when switching books

### 技术改进
- 增强统计数据管理
  - 使用事件驱动的自动更新改进统计数据加载
  - 优化数据同步，在切换账本时
  - 增强统计数据加载性能和可靠性
  - 改进状态管理，减少冗余代码
  - 优化内存使用，防止内存泄漏

- 改进分类统计列表
  - 限制默认显示数量，加快页面加载速度
  - 添加"查看更多"功能
  - 支持可定制的默认显示数量
  - 添加国际化的"收起"和"查看更多"
  
- 增强统计页面布局
  - 添加账本统计卡片，显示总收入、支出和余额
  - 优化数据加载，提高页面响应速度
  - 改进状态管理，便于代码维护
  - 添加时间范围选择，包括"最近一天"、"本月"和"全部"
  - 优化统计卡片布局，调整支出和收入显示顺序

### 问题修复
- 修复统计数据在应用程序初始化时未加载
- 修复统计数据未在切换账本时立即更新

## [1.0.0-alpha.6] - 2025-03-03

### UI Improvements
- Comprehensive optimization of statistical charts
  - Replaced FL Chart with Syncfusion Flutter Charts
  - Implemented modern pie chart design
  - Added cool-toned tech-eco theme color scheme
  - Enhanced chart animations and interactions
  - Improved data label display

### Technical Improvements
- Enhanced version management
  - Used package_info_plus for dynamic version retrieval
  - Removed hardcoded version numbers
- Updated dependency versions
- Optimized code structure and performance

### UI 改进
- 统计图表的综合优化
  - 用Syncfusion Flutter Charts替换FL Chart
  - 实现现代饼图设计
  - 添加酷色调的科技生态主题颜色方案
  - 增强图表动画和交互
  - 改进数据标签显示

### 技术改进
- 增强版本管理
  - 使用package_info_plus进行动态版本检索
  - 移除硬编码版本号
- 更新依赖版本
- 优化代码结构和性能

## [1.0.0-alpha.5] - 2025-03-03

### New Features
- Added category pie chart in statistics page
- Enhanced data visualization capabilities
- Added income and expense category statistics

### Improvements
- Optimized statistics data loading performance
- Enhanced empty state display
- Improved UI responsiveness

### Bug Fixes
- Fixed statistics calculation errors
- Fixed theme switching display issues
- Fixed missing internationalization texts

### 新功能
- 在统计页面中添加分类饼图
- 增强数据可视化能力
- 添加收入和支出分类统计

### 改进
- 优化统计数据加载性能
- 增强空状态显示
- 改进UI响应速度

### 问题修复
- 修复统计计算错误
- 修复主题切换显示问题
- 修复缺少国际化文本

## [1.0.0-alpha.4] - 2025-03-02

### Changed
- Optimized BookStatisticCard component design and functionality
  - Added default display mode parameter
  - Updated date format
  - Removed toggle button for simpler design
  - Converted to StatelessWidget
  - Enhanced visual effects
  - Added internationalization support for total label

### 更改
- 优化BookStatisticCard组件设计和功能
  - 添加默认显示模式参数
  - 更新日期格式
  - 移除切换按钮，简化设计
  - 转换为StatelessWidget
  - 增强视觉效果
  - 添加国际化的总标签支持

## [1.0.0-alpha.3] - 2024-03-01

### UI Improvements
- Enhanced debt container layout, highlighting receivable/payable amounts
- De-emphasized total amount display as secondary information
- Added debt progress bar for intuitive completion status
- Improved debt type labels and icons

### Feature Improvements
- Added automatic sync on app startup
- Enhanced number formatting with thousand separators
- Improved debt management workflow

### Bug Fixes
- Fixed Android signing configuration
- Fixed debt amount calculation
- Fixed various layout issues

### UI 改进
- 增强债务容器布局，突出应收/应付金额
- 将总金额显示作为次要信息
- 添加债务进度条，便于直观完成状态
- 改进债务类型标签和图标

### 功能改进
- 添加应用程序启动时的自动同步
- 增强千分位格式化
- 改进债务管理流程

### 问题修复
- 修复Android签名配置
- 修复债务金额计算
- 修复各种布局问题

## [1.0.0-alpha.2] - 2024-03-01

### New Features
- Added debt management
- Added multilingual support
- Added data backup and restore

### Improvements
- Enhanced user interface
- Improved application performance
- Enhanced data synchronization

### Bug Fixes
- Fixed book switching issues
- Fixed data import errors
- Fixed UI display anomalies

### 新功能
- 添加债务管理
- 添加多语言支持
- 添加数据备份和恢复

### 改进
- 增强用户界面
- 改进应用程序性能
- 增强数据同步

### 问题修复
- 修复账本切换问题
- 修复数据导入错误
- 修复UI显示异常

## [1.0.0-alpha.1] - 2024-03-01

### Initial Release
- Basic accounting functionality
- Multi-book management
- Data statistics and analysis
- Basic settings functionality

### 初始发布
- 基本会计功能
- 多账本管理
- 数据统计和分析
- 基本设置功能 