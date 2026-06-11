import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_definition_vo.dart';
import '../../providers/activity_checkin_provider.dart';
import '../../widgets/activity/activity_checkin_grid.dart';
import 'activity_def_edit_page.dart';
import 'activity_detail_page.dart';

class ActivityCheckinPage extends StatefulWidget {
  const ActivityCheckinPage({super.key});

  @override
  State<ActivityCheckinPage> createState() => _ActivityCheckinPageState();
}

class _ActivityCheckinPageState extends State<ActivityCheckinPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityCheckinProvider>().loadAll();
    });
  }

  void _onTapDetail(ActivityDefinitionVO def) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityDetailPage(definition: def),
      ),
    );
  }

  void _onLongPress(ActivityDefinitionVO def) {
    final bgColor = Color(def.color);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CheckInSheet(
        definition: def,
        bgColor: bgColor,
        provider: context.read<ActivityCheckinProvider>(),
      ),
    );
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<(String, String, int, int?)>(
      context,
      MaterialPageRoute(
        builder: (_) => const ActivityDefEditPage(),
      ),
    );
    if (result == null || !mounted) return;
    final (name, emoji, color, maxDailyCount) = result;
    await context
        .read<ActivityCheckinProvider>()
        .createDefinition(name: name, emoji: emoji, color: color, maxDailyCount: maxDailyCount);
  }

  Widget _buildStatsCard(
    ActivityCheckinProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(100),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(10),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: Row(
          children: [
            _buildStatItem(
              icon: Icons.today_outlined,
              value: '${provider.todayTotal}',
              label: L10nManager.l10n.currentDay,
              color: colorScheme.primary,
              theme: theme,
            ),
            _buildDivider(colorScheme),
            _buildStatItem(
              icon: Icons.date_range_outlined,
              value: '${provider.weekTotal}',
              label: L10nManager.l10n.thisWeek,
              color: colorScheme.tertiary,
              theme: theme,
            ),
            _buildDivider(colorScheme),
            _buildStatItem(
              icon: Icons.auto_awesome_outlined,
              value: '${provider.totalAll}',
              label: '累计',
              color: colorScheme.secondary,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: color.withAlpha(180))),
        ],
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(
      width: 1,
      height: 36,
      color: colorScheme.outlineVariant.withAlpha(80),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nManager.l10n.activityCheckin),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: L10nManager.l10n.activityCreate,
            onPressed: _navigateToCreate,
          ),
        ],
      ),
      body: Consumer<ActivityCheckinProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.definitions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.definitions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 64, color: colorScheme.outline.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text(L10nManager.l10n.noActivityDefinitions,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _navigateToCreate,
                    icon: const Icon(Icons.add),
                    label: Text(L10nManager.l10n.createFirstActivity),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAll(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildStatsCard(provider, theme, colorScheme),
                ),
                SliverToBoxAdapter(
                  child: ActivityCheckinGrid(
                    definitions: provider.definitions,
                    totalCounts: provider.totalCounts,
                    myTodayCounts: provider.myTodayCounts,
                    onTap: _onTapDetail,
                    onLongPress: _onLongPress,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '累计打卡 ${provider.totalAll} 次',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 炫酷打卡弹窗 — 弹动Emoji + 飞出的+1

/// 炫酷打卡弹窗 — 弹动Emoji + 飞出的+1
class _CheckInSheet extends StatefulWidget {
  final ActivityDefinitionVO definition;
  final Color bgColor;
  final ActivityCheckinProvider provider;

  const _CheckInSheet({
    required this.definition,
    required this.bgColor,
    required this.provider,
  });

  @override
  State<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<_CheckInSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnim;
  double _floatY = 0;
  double _floatOpacity = 0;
  bool _checkedIn = false;
  final _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  bool get _isLimitReached {
    final limit = widget.definition.maxDailyCount;
    return limit != null && widget.provider.myTodayCountOf(widget.definition.id) >= limit;
  }

  Future<void> _doCheckIn() async {
    if (_checkedIn) return;
    if (_isLimitReached) {
      HapticFeedback.heavyImpact();
      return;
    }
    _checkedIn = true;

    setState(() {
      _bounceAnim = Tween<double>(begin: 0.8, end: 1.3)
          .animate(_controller);
    });
    _controller.value = 0.0;
    await _controller.forward();
    HapticFeedback.heavyImpact();

    setState(() {
      _floatY = 0;
      _floatOpacity = 1;
    });
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (mounted) {
        setState(() {
          _floatY = -20 - (i * 8);
          _floatOpacity = 1 - (i * 0.1);
        });
      }
    }

    if (mounted) {
      final remark = _remarkController.text.trim();
      Navigator.pop(context);
      widget.provider.checkIn(widget.definition.id, remark: remark.isNotEmpty ? remark : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = widget.definition;
    final bgColor = widget.bgColor;
    final myToday = widget.provider.myTodayCountOf(def.id);
    final totalCount = widget.provider.totalCountOf(def.id);
    final limitReached = _isLimitReached;
    final l10n = L10nManager.l10n;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: screenH * 0.65),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Emoji
          GestureDetector(
            onTap: _doCheckIn,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final scale = 1 + (1 - _controller.value) * 0.2;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: screenW * 0.28,
                        height: screenW * 0.28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor.withAlpha(25),
                          boxShadow: [
                            BoxShadow(
                              color: bgColor.withAlpha(25),
                              offset: const Offset(0, 4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _bounceAnim,
                  builder: (context, child) => Transform.scale(
                    scale: _bounceAnim.value,
                    child: Text(def.emoji,
                        style: TextStyle(fontSize: screenW * 0.15)),
                  ),
                ),
                if (limitReached)
                  Positioned(
                    bottom: 2, right: -screenW * 0.02,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('已满',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                if (_floatOpacity > 0)
                  Positioned(
                    top: 0,
                    child: Transform.translate(
                      offset: Offset(0, _floatY),
                      child: Opacity(
                        opacity: _floatOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('+1',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 名称
          Text(def.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // 次数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '今日 $myToday${def.maxDailyCount != null ? ' / ${def.maxDailyCount}' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: bgColor, fontWeight: FontWeight.w600),
                    ),
                    if (limitReached)
                      const SizedBox(width: 4),
                    if (limitReached)
                      Icon(Icons.check_circle,
                          size: 14, color: const Color(0xFFFF6B35)),
                  ],
                ),
                Text(
                  '累计 $totalCount 次',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: bgColor.withAlpha(150)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 备注输入
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: TextField(
              controller: _remarkController,
              decoration: InputDecoration(
                hintText: '添加备注...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: bgColor.withAlpha(50)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: bgColor.withAlpha(120)),
                ),
              ),
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              textInputAction: TextInputAction.done,
            ),
          ),
          const SizedBox(height: 12),

          // 提示
          Text(
              limitReached
                  ? '已达每日上限，明日再来'
                  : l10n.tapToCheckIn,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: limitReached
                      ? Colors.orange.shade400
                      : theme.colorScheme.onSurfaceVariant.withAlpha(120))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
