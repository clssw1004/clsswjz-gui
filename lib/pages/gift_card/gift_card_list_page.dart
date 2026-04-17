import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../enums/gift_card_status.dart';
import '../../models/vo/gift_card_vo.dart';
import '../../providers/gift_card_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/common_app_bar.dart';

/// 礼物卡列表页面
class GiftCardListPage extends StatefulWidget {
  final int? initialTabIndex;

  const GiftCardListPage({super.key, this.initialTabIndex});

  @override
  State<GiftCardListPage> createState() => _GiftCardListPageState();
}

class _GiftCardListPageState extends State<GiftCardListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<GiftCardProvider>()
            .setSelectedTabIndex(_tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GiftCardProvider>().loadGiftCards();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final provider = context.watch<GiftCardProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        title: Text('礼物卡'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '我收到的'),
            Tab(text: '我送出的'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 我收到的
          _buildGiftCardList(
            context,
            provider.receivedGiftCards,
            provider.loading,
            isReceived: true,
          ),
          // 我送出的
          _buildGiftCardList(
            context,
            provider.sentGiftCards,
            provider.loading,
            isReceived: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('创建礼物卡'),
      ),
    );
  }

  Widget _buildGiftCardList(
    BuildContext context,
    List<GiftCardVO> giftCards,
    bool loading, {
    required bool isReceived,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (giftCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isReceived ? '暂无收到的礼物卡' : '暂无送出的礼物卡',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            if (!isReceived)
              TextButton(
                onPressed: () => _navigateToForm(context),
                child: const Text('点击创建'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<GiftCardProvider>().loadGiftCards(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: giftCards.length,
        itemBuilder: (context, index) {
          final card = giftCards[index];
          return _GiftCardWidget(
            card: card,
            isReceived: isReceived,
            onTap: () => _navigateToDetail(context, card),
            onDelete: !isReceived && (card.status == GiftCardStatus.draft || card.status == GiftCardStatus.voided)
                ? () => _deleteCard(context, card)
                : null,
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, [GiftCardVO? card]) {
    Navigator.pushNamed(context, AppRoutes.giftCardForm, arguments: card);
  }

  void _navigateToDetail(BuildContext context, GiftCardVO card) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.giftCardDetail,
      arguments: card,
    );
    if (result is int && mounted) {
      _tabController.animateTo(result);
    }
  }

  void _deleteCard(BuildContext context, GiftCardVO card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个礼物卡吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GiftCardProvider>().deleteGiftCard(card.id);
    }
  }
}

/// 礼物卡卡片组件 - 模拟实际礼物卡片布局
class _GiftCardWidget extends StatelessWidget {
  final GiftCardVO card;
  final bool isReceived;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _GiftCardWidget({
    required this.card,
    required this.isReceived,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveStatus = card.effectiveStatus;
    final dateFormat = DateFormat('yyyy-MM-dd');

    // 状态显示文本（接收方将"已送出"视为"待接收"）
    final statusDisplayText = isReceived && card.status == GiftCardStatus.sent
        ? '待接收'
        : effectiveStatus.text;

    return Dismissible(
      key: Key(card.id),
      direction: onDelete != null
          ? DismissDirection.endToStart
          : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: colorScheme.onError,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          onDelete!();
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getGradientColors(effectiveStatus)[0],
                _getGradientColors(effectiveStatus)[1],
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getGradientColors(effectiveStatus)[0].withAlpha(76),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：状态标签和有效期
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 状态标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusDisplayText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // 有效期
                    Text(
                      card.isPermanent
                          ? '永久有效'
                          : '有效期至 ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(card.expiredTime))}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha(178),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 中间：礼物卡图标和描述
                Row(
                  children: [
                    // 礼物图标
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 描述
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.description?.isNotEmpty == true
                                ? card.description!
                                : '礼物卡',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isReceived
                                ? '来自 ${card.fromWho}'
                                : '送给 ${card.toWho}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withAlpha(178),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 底部：时间信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 送出时间
                    if (card.sentTime > 0)
                      Text(
                        '送出于 ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(card.sentTime))}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(128),
                          fontSize: 11,
                        ),
                      )
                    else
                      Text(
                        '尚未送出',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(128),
                          fontSize: 11,
                        ),
                      ),
                    // 接收时间
                    if (card.receivedTime > 0)
                      Text(
                        '接收于 ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(card.receivedTime))}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(128),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 根据状态获取渐变色
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
}
