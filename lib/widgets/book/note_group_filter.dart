import 'dart:async';
import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../enums/symbol_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../drivers/driver_factory.dart';
import '../../events/event_bus.dart';
import '../../events/special/event_book.dart';
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

  @override
  void initState() {
    super.initState();
    _loadGroups();

    // 监听笔记变化事件，当有新笔记创建时刷新分组列表
    _noteChangedSubscription = EventBus.instance.on<NoteChangedEvent>((event) {
      _loadGroups();
    });
  }

  @override
  void dispose() {
    _noteChangedSubscription.cancel();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;
    final spacing = theme.spacing;

    if (_loading) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: spacing.contentPadding.copyWith(top: 8, bottom: 8),
        child: Wrap(
          spacing: spacing.listItemSpacing,
          runSpacing: spacing.listItemSpacing,
          children: [
            _buildGroupChip(
              theme: theme,
              label: '全部',
              groupCode: 'all',
              isSelected: _isAllSelected,
            ),
            _buildGroupChip(
              theme: theme,
              label: l10n.noGroup,
              groupCode: 'none',
              isSelected: _isGroupSelected('none'),
            ),
            ..._groups.map((group) => _buildGroupChip(
                  theme: theme,
                  label: group.name,
                  groupCode: group.code,
                  isSelected: _isGroupSelected(group.code),
                )),
          ],
        ),
      ),
    );
  }

  /// 构建分组按钮
  Widget _buildGroupChip({
    required ThemeData theme,
    required String label,
    required String groupCode,
    required bool isSelected,
  }) {
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return FilterChip(
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isSelected
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surfaceContainerLow,
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withAlpha(60),
        width: isSelected ? 1.5 : 1,
      ),
      elevation: isSelected ? 1 : 0,
      shadowColor:
          isSelected ? colorScheme.primary.withAlpha(40) : Colors.transparent,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfigManager.instance.radius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.listItemSpacing / 2,
        vertical: spacing.listItemSpacing / 2,
      ),
      onSelected: (selected) => _handleGroupSelection(groupCode),
    );
  }
}
