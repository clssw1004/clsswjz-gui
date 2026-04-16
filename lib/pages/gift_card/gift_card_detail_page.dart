import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../enums/gift_card_status.dart';
import '../../manager/app_config_manager.dart';
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
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final provider = context.watch<GiftCardProvider>();
    final currentUserId = AppConfigManager.instance.userId;

    // 获取最新的卡片数据（可能已更新状态）
    final card = provider.getGiftCardById(giftCard.id) ?? giftCard;
    final effectiveStatus = card.effectiveStatus;

    // 判断当前用户角色
    final isSender = card.fromUserId == currentUserId;
    final isReceiver = card.toUserId == currentUserId;

    // 判断是否可编辑（草稿状态且是赠送人）
    final canEdit = card.status == GiftCardStatus.draft && isSender;
    // 判断是否可送出（草稿状态且是赠送人）
    final canSend = card.status == GiftCardStatus.draft && isSender;
    // 判断是否可接收（已送出状态且当前用户是接收人）
    final canReceive = card.status == GiftCardStatus.sent && isReceiver;
    // 判断是否可标记已使用（已接收状态且当前用户是接收人）
    final canMarkUsed = card.status == GiftCardStatus.received && isReceiver;
    // 判断是否可作废（非已使用、非已作废且是赠送人或接收人）
    final canVoid = card.status != GiftCardStatus.used &&
        card.status != GiftCardStatus.voided &&
        (isSender || isReceiver);
    // 判断是否可延期（已送出或已接收状态且是赠送人或接收人）
    final canExtend = (card.status == GiftCardStatus.sent || card.status == GiftCardStatus.received) &&
        (isSender || isReceiver);

    return Scaffold(
      appBar: CommonAppBar(
        title: Text('礼物卡详情'),
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
                            effectiveStatus.text,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // 有效期
                        Text(
                          card.isPermanent
                              ? '永久有效'
                              : '有效期至 ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(card.expiredTime))}',
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
                                    : '礼物卡',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSender ? '送给 ${card.toWho}' : '来自 ${card.fromWho}',
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
                            label: '送出时间',
                            time: dateFormat.format(DateTime.fromMillisecondsSinceEpoch(card.sentTime)),
                            theme: theme,
                          ),
                        if (card.receivedTime > 0)
                          _buildTimeRow(
                            icon: Icons.check_circle_outline,
                            label: '接收时间',
                            time: dateFormat.format(DateTime.fromMillisecondsSinceEpoch(card.receivedTime)),
                            theme: theme,
                          ),
                        _buildTimeRow(
                          icon: Icons.create,
                          label: '创建时间',
                          time: dateFormat.format(DateTime.fromMillisecondsSinceEpoch(card.createdAt)),
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
                  // 主要操作按钮
                  if (canSend)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FilledButton.icon(
                        onPressed: () => _sendGiftCard(context, card),
                        icon: const Icon(Icons.send),
                        label: const Text('送出礼物卡'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),

                  if (canReceive)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FilledButton.icon(
                        onPressed: () => _receiveGiftCard(context, card),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('接收礼物卡'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),

                  if (canMarkUsed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FilledButton.icon(
                        onPressed: () => _markAsUsed(context, card),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('标记为已使用'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),

                  // 次要操作按钮
                  Row(
                    children: [
                      if (canEdit)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToEdit(context, card),
                            icon: const Icon(Icons.edit),
                            label: const Text('编辑'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                            ),
                          ),
                        ),
                      if (canEdit) const SizedBox(width: 12),
                      if (canExtend)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _extendGiftCard(context, card),
                            icon: const Icon(Icons.access_time),
                            label: const Text('延期'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                            ),
                          ),
                        ),
                      if (canVoid)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _voidGiftCard(context, card),
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('作废'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              minimumSize: const Size.fromHeight(44),
                            ),
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
        title: const Text('确认送出'),
        content: const Text('确定要送出这个礼物卡吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().sendGiftCard(card.id);
    }
  }

  void _receiveGiftCard(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认接收'),
        content: const Text('确定要接收这个礼物卡吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().receiveGiftCard(card.id);
    }
  }

  void _markAsUsed(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认操作'),
        content: const Text('确定要将此礼物卡标记为已使用吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().markAsUsed(card.id);
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

      await context.read<GiftCardProvider>().extendGiftCard(card.id, expiredTime);
    }
  }

  void _voidGiftCard(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认作废'),
        content: const Text('确定要作废这个礼物卡吗？作废后不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('确认作废'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().voidGiftCard(card.id);
    }
  }
}