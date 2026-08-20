import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../routes/app_routes.dart';
import '../../utils/toast_util.dart';

/// 「工具」工作台的功能条目模型。
///
/// 每一条代表一个可点按的功能入口，图标 + 标签 + 跳转动作。
class HubFeatureItem {
  /// 图标（FontAwesome solid 风格）
  final IconData icon;

  /// 标签文案（在 build 内通过 L10nManager.l10n 读取，保持语言新鲜）
  final String label;

  /// 点击回调
  final VoidCallback onTap;

  /// 是否高亮（更强的前景层级，配合 [CommonGridFeatureItem]）
  final bool isHighlighted;

  /// 语义色：图标本体与渐变背景使用该颜色；为 null 时回退主题主色。
  final Color? color;

  const HubFeatureItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
    this.color,
  });
}

/// 「工具」工作台的一个分组（如：记账财务 / 生活扩展 / 数据工具）。
class HubFeatureGroup {
  /// 分组标题前的图标
  final IconData groupIcon;

  /// 分组标题
  final String title;

  /// 组内功能条目
  final List<HubFeatureItem> items;

  const HubFeatureGroup({
    required this.groupIcon,
    required this.title,
    required this.items,
  });
}

/// 在当前选中账本为空时提示用户，避免把可空 book 传进需要强转的路由。
void _pushBookRoute(
  BuildContext context,
  BookMetaVO? book,
  String routeName,
) {
  if (book == null) {
    ToastUtil.showInfo(L10nManager.l10n.noBookSelected);
    return;
  }
  // 除账目（需要 List 参数）外的书依赖路由均以单个 BookMetaVO 为参数
  Navigator.pushNamed(context, routeName, arguments: book);
}

/// 跳转账目列表（该路由需要 List 参数：[book, filter?, title?]）。
void _pushItemsRoute(BuildContext context, BookMetaVO? book) {
  if (book == null) {
    ToastUtil.showInfo(L10nManager.l10n.noBookSelected);
    return;
  }
  Navigator.pushNamed(
    context,
    AppRoutes.items,
    arguments: <dynamic>[book],
  );
}

/// 构建「工具」工作台的全部分组。
///
/// 必须在 build() 内实时调用：`L10nManager.l10n` 单例会随语言切换被替换，
/// 若在文件级缓存"标签字符串列表"会导致切换语言后词条陈旧。
List<HubFeatureGroup> buildHubGroups(BuildContext context, BookMetaVO? book) {
  final l10n = L10nManager.l10n;
  final showActivityCheckin =
      AppConfigManager.instance.uiConfig.mineTabShowActivityCheckin;

  // 账本数据（依赖当前选中账本，切换账本后数据不同）
  final bookDataItems = <HubFeatureItem>[
    HubFeatureItem(
      icon: FontAwesomeIcons.receipt.data,
      label: l10n.accountItem,
      onTap: () => _pushItemsRoute(context, book),
      isHighlighted: true,
      color: const Color(0xFF3D6BF5),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.shapes.data,
      label: l10n.category,
      onTap: () => _pushBookRoute(context, book, AppRoutes.categories),
      isHighlighted: true,
      color: const Color(0xFF00A878),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.store.data,
      label: l10n.merchant,
      onTap: () => _pushBookRoute(context, book, AppRoutes.merchants),
      isHighlighted: true,
      color: const Color(0xFFF97316),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.wallet.data,
      label: l10n.account,
      onTap: () => _pushBookRoute(context, book, AppRoutes.funds),
      isHighlighted: true,
      color: const Color(0xFF22A06B),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.tag.data,
      label: l10n.tag,
      onTap: () => _pushBookRoute(context, book, AppRoutes.tags),
      isHighlighted: true,
      color: const Color(0xFFE8528C),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.folder.data,
      label: l10n.project,
      onTap: () => _pushBookRoute(context, book, AppRoutes.projects),
      color: const Color(0xFF7C5CFC),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.handHoldingDollar.data,
      label: l10n.debt,
      onTap: () => _pushBookRoute(context, book, AppRoutes.debtList),
      isHighlighted: true,
      color: const Color(0xFFE0A11A),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.rotate.data,
      label: l10n.recurringConfig,
      onTap: () => Navigator.pushNamed(context, AppRoutes.recurringConfigList),
      isHighlighted: true,
      color: const Color(0xFF2E86DE),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.wandMagicSparkles.data,
      label: l10n.bookkeepingRule,
      onTap: () => Navigator.pushNamed(context, AppRoutes.bookkeepingRuleList),
      isHighlighted: true,
      color: const Color(0xFF9D5BE0),
    ),
  ];

  // 生活扩展
  final lifeItems = <HubFeatureItem>[
    HubFeatureItem(
      icon: FontAwesomeIcons.noteSticky.data,
      label: l10n.noteListTitle,
      onTap: () => Navigator.pushNamed(context, AppRoutes.noteList),
      isHighlighted: true,
      color: const Color(0xFF00A9C9),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.calendarDays.data,
      label: l10n.periodRecord,
      onTap: () => Navigator.pushNamed(context, AppRoutes.periodCalendar),
      isHighlighted: true,
      color: const Color(0xFFE0559A),
    ),
    if (showActivityCheckin)
      HubFeatureItem(
        icon: FontAwesomeIcons.trophy.data,
        label: l10n.tabActivity,
        onTap: () => Navigator.pushNamed(context, AppRoutes.activityCheckin),
        isHighlighted: true,
        color: const Color(0xFFF0A92E),
      ),
    HubFeatureItem(
      icon: FontAwesomeIcons.gift.data,
      label: l10n.giftCard,
      onTap: () => Navigator.pushNamed(context, AppRoutes.giftCardList),
      isHighlighted: true,
      color: const Color(0xFFE35D3D),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.gasPump.data,
      label: l10n.fuelRecord,
      onTap: () => Navigator.pushNamed(context, AppRoutes.fuelRecords),
      isHighlighted: true,
      color: const Color(0xFF3D7FEA),
    ),
  ];

  // 数据工具
  final dataToolItems = <HubFeatureItem>[
    HubFeatureItem(
      icon: FontAwesomeIcons.book.data,
      label: l10n.accountBook,
      onTap: () => Navigator.pushNamed(context, AppRoutes.accountBooks),
      color: const Color(0xFF5C6BC0),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.fileImport.data,
      label: l10n.import,
      onTap: () => Navigator.pushNamed(context, AppRoutes.import),
      color: const Color(0xFF3BA55D),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.paperclip.data,
      label: l10n.attachment,
      onTap: () => Navigator.pushNamed(context, AppRoutes.attachments),
      color: const Color(0xFF8A90A6),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.chartColumn.data,
      label: l10n.reportListTitle,
      onTap: () => Navigator.pushNamed(context, AppRoutes.reportList),
      color: const Color(0xFF2F80ED),
    ),
    HubFeatureItem(
      icon: FontAwesomeIcons.cloudArrowUp.data,
      label: l10n.syncSettings,
      onTap: () => Navigator.pushNamed(context, AppRoutes.syncSettings),
      color: const Color(0xFF00A8D6),
    ),
  ];

  // 账本数据分组标题：随默认账本切换，显示当前账本名称
  final bookDataTitle =
      (book != null && book.name.isNotEmpty) ? book.name : l10n.hubGroupBookData;

  return [
    HubFeatureGroup(
      groupIcon: FontAwesomeIcons.bookOpen.data,
      title: bookDataTitle,
      items: bookDataItems,
    ),
    HubFeatureGroup(
      groupIcon: FontAwesomeIcons.heart.data,
      title: l10n.hubGroupLife,
      items: lifeItems,
    ),
    HubFeatureGroup(
      groupIcon: FontAwesomeIcons.screwdriverWrench.data,
      title: l10n.hubGroupDataTools,
      items: dataToolItems,
    ),
  ];
}
