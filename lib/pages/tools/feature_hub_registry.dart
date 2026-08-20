import 'package:flutter/material.dart';

import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../routes/app_routes.dart';
import '../../utils/toast_util.dart';

/// 「全部功能」Hub 的功能条目模型。
///
/// 每一条代表一个可点按的功能入口，图标 + 标签 + 跳转动作。
class HubFeatureItem {
  /// 图标
  final IconData icon;

  /// 标签文案（在 build 内通过 L10nManager.l10n 读取，保持语言新鲜）
  final String label;

  /// 点击回调
  final VoidCallback onTap;

  /// 是否高亮（更强的前景层级，配合 [CommonGridFeatureItem]）
  final bool isHighlighted;

  const HubFeatureItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });
}

/// 「全部功能」Hub 的一个分组（如：记账财务 / 生活扩展 / 数据工具）。
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
  Navigator.pushNamed(context, routeName, arguments: book);
}

/// 构建「全部功能」Hub 的全部分组。
///
/// 必须在 build() 内实时调用：`L10nManager.l10n` 单例会随语言切换被替换，
/// 若在文件级缓存"标签字符串列表"会导致切换语言后词条陈旧。
List<HubFeatureGroup> buildHubGroups(BuildContext context, BookMetaVO? book) {
  final l10n = L10nManager.l10n;
  final showActivityCheckin =
      AppConfigManager.instance.uiConfig.mineTabShowActivityCheckin;

  // 记账财务
  final financeItems = <HubFeatureItem>[
    HubFeatureItem(
      icon: Icons.receipt_long_outlined,
      label: l10n.accountItem,
      onTap: () => _pushBookRoute(context, book, AppRoutes.items),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.book_outlined,
      label: l10n.accountBook,
      onTap: () => Navigator.pushNamed(context, AppRoutes.accountBooks),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.category_outlined,
      label: l10n.category,
      onTap: () => _pushBookRoute(context, book, AppRoutes.categories),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.store_outlined,
      label: l10n.merchant,
      onTap: () => _pushBookRoute(context, book, AppRoutes.merchants),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.account_balance_wallet_outlined,
      label: l10n.account,
      onTap: () => _pushBookRoute(context, book, AppRoutes.funds),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.local_offer_outlined,
      label: l10n.tag,
      onTap: () => _pushBookRoute(context, book, AppRoutes.tags),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.folder_outlined,
      label: l10n.project,
      onTap: () => _pushBookRoute(context, book, AppRoutes.projects),
    ),
    HubFeatureItem(
      icon: Icons.repeat,
      label: l10n.recurringConfig,
      onTap: () => Navigator.pushNamed(context, AppRoutes.recurringConfigList),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.auto_fix_high,
      label: l10n.bookkeepingRule,
      onTap: () => Navigator.pushNamed(context, AppRoutes.bookkeepingRuleList),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.money_outlined,
      label: l10n.debt,
      onTap: () => _pushBookRoute(context, book, AppRoutes.debtList),
      isHighlighted: true,
    ),
  ];

  // 生活扩展
  final lifeItems = <HubFeatureItem>[
    HubFeatureItem(
      icon: Icons.note_alt_outlined,
      label: l10n.noteListTitle,
      onTap: () => Navigator.pushNamed(context, AppRoutes.noteList),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.calendar_month_outlined,
      label: l10n.periodRecord,
      onTap: () => Navigator.pushNamed(context, AppRoutes.periodCalendar),
      isHighlighted: true,
    ),
    if (showActivityCheckin)
      HubFeatureItem(
        icon: Icons.emoji_events_outlined,
        label: l10n.tabActivity,
        onTap: () => Navigator.pushNamed(context, AppRoutes.activityCheckin),
        isHighlighted: true,
      ),
    HubFeatureItem(
      icon: Icons.card_giftcard,
      label: l10n.giftCard,
      onTap: () => Navigator.pushNamed(context, AppRoutes.giftCardList),
      isHighlighted: true,
    ),
    HubFeatureItem(
      icon: Icons.local_gas_station_outlined,
      label: l10n.fuelRecord,
      onTap: () => Navigator.pushNamed(context, AppRoutes.fuelRecords),
      isHighlighted: true,
    ),
  ];

  // 数据工具
  final dataToolItems = <HubFeatureItem>[
    HubFeatureItem(
      icon: Icons.file_upload_outlined,
      label: l10n.import,
      onTap: () => Navigator.pushNamed(context, AppRoutes.import),
    ),
    HubFeatureItem(
      icon: Icons.attachment_outlined,
      label: l10n.attachment,
      onTap: () => Navigator.pushNamed(context, AppRoutes.attachments),
    ),
    HubFeatureItem(
      icon: Icons.assessment_outlined,
      label: l10n.reportListTitle,
      onTap: () => Navigator.pushNamed(context, AppRoutes.reportList),
    ),
    HubFeatureItem(
      icon: Icons.cloud_sync_outlined,
      label: l10n.syncSettings,
      onTap: () => Navigator.pushNamed(context, AppRoutes.syncSettings),
    ),
  ];

  return [
    HubFeatureGroup(
      groupIcon: Icons.account_balance_wallet_outlined,
      title: l10n.hubGroupFinance,
      items: financeItems,
    ),
    HubFeatureGroup(
      groupIcon: Icons.favorite_outline,
      title: l10n.hubGroupLife,
      items: lifeItems,
    ),
    HubFeatureGroup(
      groupIcon: Icons.build_outlined,
      title: l10n.hubGroupDataTools,
      items: dataToolItems,
    ),
  ];
}
