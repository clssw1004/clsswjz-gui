import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../enums/symbol_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../drivers/driver_factory.dart';
import '../../events/event_bus.dart';
import '../../events/special/event_book.dart';
import '../../events/special/event_sync.dart';
import '../../theme/theme_spacing.dart';

/// 笔记分组筛选组件
class NoteGroupFilter extends StatefulWidget {
  /// 当前选中的分组代码列表
  final List<String>? selectedGroupCodes;

  /// 分组选择变化回调
  final void Function(List<String>? groupCodes)? onGroupCodesChanged;

  /// 账本ID
  final String bookId;

  const NoteGroupFilter({
    super.key,
    this.selectedGroupCodes,
    this.onGroupCodesChanged,
    required this.bookId,
  });

  @override
  State<NoteGroupFilter> createState() => _NoteGroupFilterState();
}

class _NoteGroupFilterState extends State<NoteGroupFilter> {
  /// 分组列表
  List<AccountSymbol> _groups = [];

  /// 是否正在加载
  bool _loading = false;

  /// 事件订阅
  late final StreamSubscription _noteChangedSubscription;

  /// 同步事件订阅
  late final StreamSubscription _syncCompletedSubscription;

  @override
  void initState() {
    super.initState();
    _loadGroups();

    // 监听笔记变化事件，当有新笔记创建时刷新分组列表
    _noteChangedSubscription = EventBus.instance.on<NoteChangedEvent>((event) {
      _loadGroups();
    });

    // 监听同步完成事件，同步后重新加载分组
    _syncCompletedSubscription =
        EventBus.instance.on<SyncCompletedEvent>((event) {
      _loadGroups();
    });
  }

  @override
  void dispose() {
    _noteChangedSubscription.cancel();
    _syncCompletedSubscription.cancel();
    super.dispose();
  }

  /// 加载分组列表
  Future<void> _loadGroups() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final userId = AppConfigManager.instance.userId;
      final result = await DriverFactory.driver.listSymbolsByBook(
        userId,
        widget.bookId,
        symbolType: SymbolType.noteGroup,
      );

      if (mounted) {
        setState(() {
          _groups = result.data ?? [];
        });
      }
    } catch (e) {
      debugPrint('加载分组失败: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// 处理分组选择
  void _handleGroupSelection(String groupCode) {
    if (groupCode == 'all') {
      // 点击全部按钮，清空所有选择
      widget.onGroupCodesChanged?.call(null);
    } else {
      // 单选逻辑：直接选中该分组，取消其他分组
      widget.onGroupCodesChanged?.call([groupCode]);
    }
  }

  /// 检查是否选中全部
  bool get _isAllSelected =>
      widget.selectedGroupCodes == null || widget.selectedGroupCodes!.isEmpty;

  /// 检查指定分组是否选中
  bool _isGroupSelected(String groupCode) {
    if (_isAllSelected) return false;
    return widget.selectedGroupCodes!.contains(groupCode);
  }

  /// 打开全部分组选择面板
  void _showAllGroupsSheet(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            theme.spacing.contentPadding.left,
            20,
            theme.spacing.contentPadding.right,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '筛选分组',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: [
                  _buildSheetChip(
                    theme: theme,
                    label: '全部',
                    groupCode: 'all',
                    isSelected: _isAllSelected,
                  ),
                  _buildSheetChip(
                    theme: theme,
                    label: l10n.noGroup,
                    groupCode: 'none',
                    isSelected: _isGroupSelected('none'),
                  ),
                  ..._groups.map((group) => _buildSheetChip(
                        theme: theme,
                        label: group.name,
                        groupCode: group.code,
                        isSelected: _isGroupSelected(group.code),
                      )),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// 构建底部面板中的分组按钮
  Widget _buildSheetChip({
    required ThemeData theme,
    required String label,
    required String groupCode,
    required bool isSelected,
  }) {
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
          height: 1.2,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.25),
        width: 1,
      ),
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onSelected: (selected) {
        Navigator.of(context).pop();
        _handleGroupSelection(groupCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;
    final spacing = theme.spacing;
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: Stack(
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(
              left: spacing.contentPadding.left,
              right: spacing.contentPadding.right + 24,
            ),
            children: [
              _buildChip(
                theme: theme,
                label: '全部',
                groupCode: 'all',
                isSelected: _isAllSelected,
              ),
              const SizedBox(width: 8),
              _buildChip(
                theme: theme,
                label: l10n.noGroup,
                groupCode: 'none',
                isSelected: _isGroupSelected('none'),
              ),
              for (var i = 0; i < _groups.length; i++) ...[
                const SizedBox(width: 8),
                _buildChip(
                  theme: theme,
                  label: _groups[i].name,
                  groupCode: _groups[i].code,
                  isSelected: _isGroupSelected(_groups[i].code),
                ),
              ],
            ],
          ),
          // 右侧渐变 + 展开按钮
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () => _showAllGroupsSheet(context, theme),
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.surface.withValues(alpha: 0.0),
                      colorScheme.surface,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建行内分组按钮
  Widget _buildChip({
    required ThemeData theme,
    required String label,
    required String groupCode,
    required bool isSelected,
  }) {
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 13,
          height: 1.2,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      backgroundColor: Colors.transparent,
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.25),
        width: 1,
      ),
      elevation: 0,
      pressElevation: 0,
      shadowColor: Colors.transparent,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      onSelected: (selected) => _handleGroupSelection(groupCode),
    );
  }
}
