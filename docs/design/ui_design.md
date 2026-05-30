# 全局 UI 设计规范

## 一、背景

本规范定义 Clsswjz 应用的全局 UI 设计体系，统一主题、间距、组件等视觉规范。所有新功能开发应遵循此规范，确保 UI 一致性。

## 二、主题系统

### 2.1 主题架构

```
MaterialApp
  ├── theme: getLightTheme()      ← 亮色主题
  ├── darkTheme: getDarkTheme()   ← 暗色主题
  └── themeMode: system/light/dark
```

主题通过 `ThemeProvider`（`lib/providers/theme_provider.dart`）管理，支持：
- 主题模式（亮色/暗色/跟随系统）
- 主题色（ColorScheme.fromSeed 基于选择色生成）
- 字体大小（4 档：较小 0.85 / 默认 1.0 / 较大 1.15 / 最大 1.3）
- 圆角大小（4 档：无 0 / 小 4 / 中 8 / 大 12）
- Material 3 开关

### 2.2 主题扩展

```dart
// 注册在 ThemeData.extensions 中
extensions: [
  ThemeSpacing.fromScreenSize(context),  // 自适应间距
  ThemeRadius(radius: radius),           // 全局圆角
],
```

**⚠️ 新功能注意事项：**
- `ThemeSpacing` 通过 `Theme.of(context).spacing` 获取
- `ThemeRadius` 通过 `Theme.of(context).extension<ThemeRadius>()?.radius ?? 8` 获取
- 不应使用 `Theme.of(context).extension<ThemeRadius>()` 直接取值（可能为 null）

### 2.3 颜色使用规范

| 用途 | Token | 示例 |
|------|-------|------|
| 主色/品牌色 | `colorScheme.primary` | 按钮、选中态、链接 |
| 主色容器 | `colorScheme.primaryContainer` | 选中背景、徽章 |
| 次要色 | `colorScheme.secondary` | FAB 次要操作 |
| 背景色 | `colorScheme.surface` | 页面背景、卡片背景 |
| 表面色变体 | `colorScheme.surfaceContainerHighest` | 卡片背景替代、输入框填充 |
| 文本主色 | `colorScheme.onSurface` | 主要文字 |
| 文本次色 | `colorScheme.onSurfaceVariant` | 辅助文字、说明 |
| 边框色 | `colorScheme.outlineVariant` | 卡片边框、分隔线 |
| 遮罩层 | `colorScheme.scrim.withAlpha(31)` | 弹窗背景遮罩 |
| 错误色 | `colorScheme.error` | 验证错误 |

**禁止：**
- ❌ 使用 `Colors.xxx` 直接硬编码颜色
- ❌ 使用 `withOpacity()` — 改用 `withAlpha()` 或 `withValues(alpha:)`
- ❌ 使用 `Color(0xFF....)` 直接创建颜色

**允许：**
- ✅ 使用 `colorScheme.xxx` 系列
- ✅ 使用 `theme.spacing` 系列
- ✅ `Colors.transparent`（特殊场景，如 Material 容器背景）

### 2.4 暗色主题

**暗色主题与亮色主题必须配对配置**。目前暗色主题已补全以下配置：

```dart
// getDarkTheme() 必须包含与 getLightTheme() 对应的组件配置
scaffoldBackgroundColor: colorScheme.surface,
canvasColor: colorScheme.surface,
cardColor: colorScheme.surface,
appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, ...),
navigationBarTheme: NavigationBarThemeData(backgroundColor: ..., ...),
bottomSheetTheme: BottomSheetThemeData(backgroundColor: ..., ...),
popupMenuTheme: PopupMenuThemeData(color: ..., ...),
snackBarTheme: SnackBarThemeData(backgroundColor: ..., ...),
dialogTheme: DialogThemeData(backgroundColor: ..., ...),
```

## 三、间距体系

### 3.1 间距 Token

定义在 `ThemeSpacing`（`lib/theme/theme_spacing.dart`），自适应屏幕尺寸计算。

| Token | 默认值 | 适用场景 |
|-------|--------|----------|
| `formItemSpacing` | 8~16 | 表单相邻项间距 |
| `formGroupSpacing` | 16~32 | 表单组间距 |
| `formPadding` | 16~32 | 表单整体外间距 |
| `formItemPadding` | h:12~24, v:8~16 | 表单项内间距 |
| `formGroupPadding` | h:8~16, v:8~16 | 表单组内间距 |
| `contentPadding` | h:16~32, v:16~24 | 内容区域外间距 |
| `listPadding` | 12~24 | 列表整体外间距 |
| `listItemMargin` | 12~24 | 列表项间距 |
| `listItemPadding` | 12~16 | 列表项内间距 |
| `listItemSpacing` | 8~12 | 列表项内容间距 |
| `pagePadding` | 16~32 | 页面整体外间距 |

### 3.2 间距替换原则

```dart
// ❌ 禁止：硬编码固定值
EdgeInsets.all(16)
EdgeInsets.fromLTRB(16, 8, 16, 16)
const SizedBox(height: 16)

// ✅ 正确：使用主题间距
theme = Theme.of(context);
spacing = theme.spacing;
SizedBox(height: spacing.formItemSpacing)
Padding(padding: spacing.contentPadding)
```

### 3.3 元素间距规范

| 元素关系 | 间距值 |
|----------|--------|
| 相邻表单字段 | `formItemSpacing` |
| 表单分区 | `formGroupSpacing` |
| 卡片边缘到内容 | `contentPadding` |
| 列表项之间 | `listItemMargin` |
| 列表项标题与详情 | `listItemSpacing` |
| 图标与文字 | `SizedBox(width: 8)`（固定） |

## 四、组件库

### 4.1 通用组件清单

| 组件 | 文件路径 | 说明 |
|------|----------|------|
| CommonAppBar | `lib/widgets/common/common_app_bar.dart` | 通用导航栏，自动处理返回按钮和平台适配 |
| CommonCardContainer | `lib/widgets/common/common_card_container.dart` | 通用卡片容器，圆角+主题色边框，可点击 |
| CommonGridFeatureItem | `lib/widgets/common/common_grid_feature_item.dart` | 功能网格项（图标+文字），用于 MineTab 等 |
| CommonSettingTile | `lib/widgets/common/common_setting_tile.dart` | 设置列表项（图标+文字+箭头+分隔线） |
| CommonEmptyView | `lib/widgets/common/common_empty_view.dart` | 空状态视图，可配置图标和操作按钮 |
| CommonLoadingView | `lib/widgets/common/common_loading_view.dart` | 加载中视图，可选文字提示 |
| CommonSearchField | `lib/widgets/common/common_search_field.dart` | 搜索输入框 |
| CommonDialog | `lib/widgets/common/common_dialog.dart` | 通用弹窗 |
| CommonBottomSheet | `lib/widgets/common/common_bottom_sheet.dart` | 通用底部弹窗 |

### 4.2 卡片组件规范

**CommonCardContainer 配置：**

```dart
CommonCardContainer(
  padding: spacing.contentPadding,  // 内间距
  margin: EdgeInsets.only(bottom: spacing.formItemSpacing),  // 下间距
  onTap: () {},  // 可选，提供则支持 InkWell 水波纹
  child: ...,  // 内容
)
```

样式：
- elevation: 0（无阴影）
- color: `colorScheme.surface`
- borderRadius: 12
- border: `colorScheme.outline.withAlpha(46)` 宽度 1

### 4.3 功能网格项规范

**CommonGridFeatureItem 配置：**

```dart
CommonGridFeatureItem(
  icon: Icons.xxx,
  label: '名称',
  onTap: () {},
  isHighlighted: false,  // 高亮模式使用更强的透明度
)
```

样式：
- icon container: 40x40, borderRadius 8
- normal background: `primary.withAlpha(10)`
- highlighted background: `primary.withAlpha(15)`
- label: 12px, medium weight
- 整体边框 0.5px outlineVariant

### 4.4 设置列表项规范

**CommonSettingTile 配置：**

```dart
CommonSettingTile(
  icon: Icons.xxx,
  label: '设置名称',
  onTap: () {},
  isLast: false,  // 控制分隔线显示
)
```

样式：
- icon container: 40x40, borderRadius 20（圆形）
- background: `primary.withAlpha(20)`
- trailing: chevron_right icon
- 分隔线：缩进 68px，`outlineVariant.withAlpha(128)` 高度 1

## 五、页面规范

### 5.1 页面过渡动画

所有页面使用统一的 SlideTransition：

```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(0.15, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
  )),
  child: child,
)
```

- 过渡时长：250ms
- 曲线：easeOutCubic（缓出）

### 5.2 NavigationBar 规范

底部导航栏使用 M3 NavigationBar：

```dart
NavigationBar(
  elevation: 0,
  height: 72,
  backgroundColor: colorScheme.surface,
  indicatorColor: colorScheme.secondaryContainer,
  destinations: [
    NavigationDestination(icon: Icons.xxx_outlined, selectedIcon: Icons.xxx, label: ''),
  ],
)
```

- 中间添加按钮（FAB）使用 AnimatedContainer + AnimatedRotation 实现展开/收起动效
- 遮罩层使用 `colorScheme.scrim.withAlpha(31)`

### 5.3 列表页规范

| 元素 | 规范 |
|------|------|
| 列表外层间距 | `spacing.listPadding` 或 `spacing.contentPadding` |
| 列表项间距 | `spacing.listItemMargin` |
| 列表项内间距 | `spacing.listItemPadding` |
| 列表项圆角 | `ThemeRadius` 值 |
| 加载状态 | `CommonLoadingView` 居中显示 |
| 空状态 | `CommonEmptyView` 居中显示，message 参数配置文案 |
| 刷新 | `CustomRefreshIndicator`（NotesTab 场景）或自动刷新 |

### 5.4 表单页规范

| 元素 | 规范 |
|------|------|
| 表单外间距 | `spacing.formPadding` |
| 表单项间距 | `spacing.formItemSpacing` |
| 表单组间距 | `spacing.formGroupSpacing` |
| 表单项内间距 | `spacing.formItemPadding` |
| 按钮高度 | 48（主要操作），44（次要操作） |
| 输入框 | `OutlineInputBorder`，圆角适配 `ThemeRadius` |

## 六、开发原则

### 6.1 新页面开发 Checklist

- [ ] 使用 `CommonAppBar` 构建导航栏
- [ ] 从 `Theme.of(context).spacing` 获取间距，无硬编码 EdgeInsets
- [ ] 颜色全部使用 `colorScheme` 系列
- [ ] 暗色/亮色主题均测试通过
- [ ] 字体使用 `theme.textTheme.xxx`（可缩放）
- [ ] 卡片使用 `CommonCardContainer` 或基于其扩展
- [ ] 加载/空状态使用 `CommonLoadingView` / `CommonEmptyView`
- [ ] 路由过渡使用统一动画
- [ ] `flutter analyze` 无错误

### 6.2 禁止事项

1. **禁止硬编码间距** —— 始终使用 `theme.spacing`
2. **禁止硬编码颜色** —— 始终使用 `theme.colorScheme`
3. **禁止使用 `withOpacity()`** —— 使用 `withAlpha()` 或 `withValues(alpha:)`
4. **禁止新建冗余组件** —— 先检查组件库是否存在
5. **禁止在页面内构建重复 UI 模式** —— 提取为组件

### 6.3 组件贡献规范

新增通用组件需满足：
1. 放在 `lib/widgets/common/` 目录
2. 使用 Material 3 主题系统，不硬编码颜色/间距
3. 支持亮色/暗色主题
4. 必须 export 或在该目录下新增文件
5. 单文件原则（组件+样式，不超过 200 行）

## 七、文件结构

```
lib/
├── theme/
│   ├── theme_spacing.dart          # 间距 Token 定义
│   └── theme_radius.dart           # 圆角 Token 定义
├── widgets/
│   └── common/
│       ├── common_app_bar.dart       # 通用导航栏
│       ├── common_card_container.dart # 通用卡片容器
│       ├── common_grid_feature_item.dart # 功能网格项
│       ├── common_setting_tile.dart  # 设置列表项
│       ├── common_empty_view.dart    # 空状态
│       ├── common_loading_view.dart  # 加载状态
│       └── ...                       # 其他通用组件
├── providers/
│   └── theme_provider.dart          # 主题状态管理
└── pages/                           # 各页面引用 theme.spacing
```

## 八、参考

- Material Design 3 规范：https://m3.material.io/
- Flutter ThemeData 文档：https://api.flutter.dev/flutter/material/ThemeData-class.html
- ColorScheme 色板生成：https://api.flutter.dev/flutter/material/ColorScheme/fromSeed.html
