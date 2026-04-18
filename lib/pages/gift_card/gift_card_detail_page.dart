import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../enums/gift_card_status.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/gift_card_vo.dart';
import '../../providers/gift_card_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/common_app_bar.dart';

/// 礼物卡详情页面
class GiftCardDetailPage extends StatelessWidget {
  const GiftCardDetailPage({super.key, required this.giftCard});

  final GiftCardVO giftCard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final provider = context.watch<GiftCardProvider>();
    final currentUserId = AppConfigManager.instance.userId;

    // 获取最新的卡片数据（可能已更新状态）
    final card = provider.getGiftCardById(giftCard.id) ?? giftCard;
    final effectiveStatus = card.effectiveStatus;

    // 判断当前用户角色
    final isSender = card.fromUserId == currentUserId;
    final isReceiver = card.toUserId == currentUserId;

    // 状态显示文本（接收方将"已送出"视为"待接收"）
    final statusDisplayText = isReceiver && card.status == GiftCardStatus.sent
        ? L10nManager.l10n.pendingReceive
        : effectiveStatus.text;

    // 判断是否可编辑（草稿状态且是赠送人）
    final canEdit = card.status == GiftCardStatus.draft && isSender;
    // 判断是否可送出（草稿状态且是赠送人）
    final canSend = card.status == GiftCardStatus.draft && isSender;
    // 判断是否可接收（已送出状态且当前用户是接收人）
    final canReceive = card.status == GiftCardStatus.sent && isReceiver;
    // 判断是否可标记已使用（已接收状态且当前用户是赠送人）
    final canMarkUsed = card.status == GiftCardStatus.received && isSender;
    // 判断是否可作废（非已使用、非已作废且是赠送人）
    final canVoid = card.status != GiftCardStatus.used &&
        card.status != GiftCardStatus.voided &&
        isSender;
    // 判断是否可延期（已送出或已接收状态、是赠送人、且不是永久有效）
    final canExtend = (card.status == GiftCardStatus.sent ||
            card.status == GiftCardStatus.received) &&
        isSender &&
        card.expiredTime > 0;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.giftCardDetail),
        showBackButton: true,
      ),
      body: CustomScrollView(
        slivers: [
          // 顶部卡片
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(effectiveStatus),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getGradientColors(effectiveStatus)[0].withAlpha(76),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 状态和有效期
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 状态标签
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            statusDisplayText,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // 有效期
                        Text(
                          card.isPermanent
                              ? L10nManager.l10n.permanent
                              : L10nManager.l10n.expiresAt(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(card.expiredTime))),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(178),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 礼物卡图标和描述
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.description?.isNotEmpty == true
                                    ? card.description!
                                    : L10nManager.l10n.giftCard,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSender
                                    ? L10nManager.l10n.to(card.toWho)
                                    : L10nManager.l10n.from(card.fromWho),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withAlpha(204),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 时间信息
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (card.sentTime > 0)
                          _buildTimeRow(
                            icon: Icons.send,
                            label: L10nManager.l10n.sentTime,
                            time: dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    card.sentTime)),
                            theme: theme,
                          ),
                        if (card.receivedTime > 0)
                          _buildTimeRow(
                            icon: Icons.check_circle_outline,
                            label: L10nManager.l10n.receivedTime,
                            time: dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    card.receivedTime)),
                            theme: theme,
                          ),
                        _buildTimeRow(
                          icon: Icons.create,
                          label: L10nManager.l10n.createdAt,
                          time: dateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  card.createdAt)),
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 操作按钮区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // 主要操作按钮 - 渐变胶囊按钮
                  if (canSend)
                    _ActionButton(
                      onPressed: () => _sendGiftCard(context, card),
                      icon: Icons.card_giftcard,
                      label: L10nManager.l10n.sendGiftCardAction,
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade400, Colors.purple.shade700],
                      ),
                    ),

                  if (canReceive)
                    _ActionButton(
                      onPressed: () => _receiveGiftCard(context, card),
                      icon: Icons.celebration,
                      label: L10nManager.l10n.receiveGiftCardAction,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                      ),
                    ),

                  if (canMarkUsed)
                    _ActionButton(
                      onPressed: () => _markAsUsed(context, card),
                      icon: Icons.check_circle,
                      label: L10nManager.l10n.markAsUsed,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade700],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 次要操作按钮 - 柔和圆角按钮
                  Row(
                    children: [
                      if (canEdit)
                        Expanded(
                          child: _SecondaryButton(
                            onPressed: () => _navigateToEdit(context, card),
                            icon: Icons.edit_outlined,
                            label: L10nManager.l10n.edit,
                          ),
                        ),
                      if (canEdit && canExtend) const SizedBox(width: 12),
                      if (canExtend)
                        Expanded(
                          child: _SecondaryButton(
                            onPressed: () => _extendGiftCard(context, card),
                            icon: Icons.schedule,
                            label: L10nManager.l10n.extend,
                          ),
                        ),
                      if ((canEdit || canExtend) && canVoid) const SizedBox(width: 12),
                      if (canVoid)
                        Expanded(
                          child: _SecondaryButton(
                            onPressed: () => _voidGiftCard(context, card),
                            icon: Icons.disabled_by_default,
                            label: L10nManager.l10n.voidGiftCard,
                            isDanger: true,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow({
    required IconData icon,
    required String label,
    required String time,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white.withAlpha(153)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withAlpha(153),
            ),
          ),
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(GiftCardStatus status) {
    switch (status) {
      case GiftCardStatus.draft:
        return [Colors.grey, Colors.blueGrey];
      case GiftCardStatus.sent:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case GiftCardStatus.received:
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      case GiftCardStatus.used:
        return [const Color(0xFF4facfe), const Color(0xFF00f2fe)];
      case GiftCardStatus.expired:
        return [const Color(0xFF434343), const Color(0xFF000000)];
      case GiftCardStatus.voided:
        return [const Color(0xFF8B4513), const Color(0xFFA0522D)];
    }
  }

  void _navigateToEdit(BuildContext context, GiftCardVO card) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.giftCardForm,
      arguments: card,
    );
    if (result == true && context.mounted) {
      context.read<GiftCardProvider>().loadGiftCards();
    }
  }

  void _sendGiftCard(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.confirmSend),
        content: Text(L10nManager.l10n.confirmSendContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10nManager.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(L10nManager.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().sendGiftCard(card.id);
      if (context.mounted) {
        Navigator.pop(context, 1); // 返回"我送出的"tab
      }
    }
  }

  void _receiveGiftCard(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.confirmReceive),
        content: Text(L10nManager.l10n.confirmReceiveContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10nManager.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(L10nManager.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().receiveGiftCard(card.id);
      if (context.mounted) {
        Navigator.pop(context, 0); // 返回"我收到的"tab
      }
    }
  }

  void _markAsUsed(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.confirmAction),
        content: Text(L10nManager.l10n.confirmMarkUsedContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10nManager.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(L10nManager.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().markAsUsed(card.id);
      if (context.mounted) {
        Navigator.pop(context, 1); // 返回"我送出的"tab
      }
    }
  }

  void _extendGiftCard(BuildContext context, GiftCardVO card) async {
    final date = await showDatePicker(
      context: context,
      initialDate: card.expiredTime > 0
          ? DateTime.fromMillisecondsSinceEpoch(card.expiredTime)
          : DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null && context.mounted) {
      final expiredTime = DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
      ).millisecondsSinceEpoch;

      await context
          .read<GiftCardProvider>()
          .extendGiftCard(card.id, expiredTime);
    }
  }

  void _voidGiftCard(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.confirmVoid),
        content: Text(L10nManager.l10n.confirmVoidContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10nManager.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(L10nManager.l10n.confirmVoid),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().voidGiftCard(card.id);
      if (context.mounted) {
        Navigator.pop(context, 1); // 返回"我送出的"tab
      }
    }
  }
}

/// 主要操作按钮 - 渐变胶囊样式
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final LinearGradient gradient;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withAlpha(102),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 次要操作按钮 - 柔和圆角样式
class _SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isDanger;

  const _SecondaryButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isDanger
        ? colorScheme.errorContainer.withAlpha(128)
        : colorScheme.surfaceContainerHighest.withAlpha(179);
    final fgColor = isDanger
        ? colorScheme.error
        : colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: isDanger
                ? Border.all(color: colorScheme.error.withAlpha(77), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fgColor, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fgColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
