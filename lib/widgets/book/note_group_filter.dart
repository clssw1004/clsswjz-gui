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

/// 报表筛选标记（用于分组筛选器中标识报表模式）
const String kReportFilterCode = '__report__';

/// 笔记分组筛选组件
class NoteGroupFilter extends StatefulWidget {
  /// 当前选中的分组代码列表
  final List<String>? selectedGroupCodes;

  /// 分组选择变化回调
  final void Function(List<String>? groupCodes)? onGroupCodesChanged;

  /// 账本ID
  final String bookId;

  /// 是否启用报表筛选模式
  final bool isReportActive;

  const NoteGroupFilter({
    super.key,
    this.selectedGroupCodes,
    this.onGroupCodesChanged,
    required this.bookId,
    this.isReportActive = false,
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

  /// 处理分组选择（多选）
  void _handleGroupSelection(List<String> selectedCodes) {
    if (selectedCodes.isEmpty || selectedCodes.contains('all')) {
      widget.onGroupCodesChanged?.call(null);
    } else {
      widget.onGroupCodesChanged?.call(selectedCodes);
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

  /// 获取当前选中分组的名称
  String _getSelectedLabel() {
    final l10n = L10nManager.l10n;
    if (widget.isReportActive) return '报表';
    if (_isAllSelected) return l10n.all;
    if (_isGroupSelected('none')) return l10n.noGroup;
    final selected = _groups.where(
      (g) => _isGroupSelected(g.code),
    );
    if (selected.length == 1) return selected.first.name;
    return l10n.groupFilterMultiple(selected.first.name, selected.length);
  }

  /// 打开分组选择抽屉（多选列表）
  void _showGroupDrawer(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    // 本地选中副本
    final selected = <String>{};
    if (!_isAllSelected) {
      selected.addAll(widget.selectedGroupCodes!);
    }

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isAll = selected.isEmpty || selected.contains('all');

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.68,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 拖拽手柄 ──
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withAlpha(50),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── 标题 ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        Icon(Icons.folder_outlined,
                            size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          l10n.groupFilterTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 分割线 ──
                  Divider(height: 1, color: colorScheme.outline.withAlpha(20)),

                  // ── 列表 ──
                  Flexible(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      children: [
                        // 全部选项
                        _buildSheetItem(
                          theme: theme,
                          label: l10n.all,
                          groupCode: 'all',
                          isSelected: isAll && !selected.contains(kReportFilterCode),
                          onTap: () {
                            setSheetState(() => selected.clear());
                          },
                        ),
                        // 报表选项
                        _buildReportItem(theme: theme, isSelected: selected.contains(kReportFilterCode), onTap: () {
                          setSheetState(() {
                            selected.clear();
                            selected.add(kReportFilterCode);
                          });
                        }),
                        // 分割线：全部/报表 与 具体分组 之间
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Divider(height: 1, color: colorScheme.outline.withAlpha(30)),
                        ),
                        _buildSheetItem(
                          theme: theme,
                          label: l10n.noGroup,
                          groupCode: 'none',
                          isSelected: !isAll && selected.contains('none'),
                          onTap: () {
                            setSheetState(() {
                              selected.remove('all');
                              if (selected.contains('none')) {
                                selected.remove('none');
                              } else {
                                selected.add('none');
                              }
                            });
                          },
                        ),
                        ..._groups.map((group) {
                          final isGroupSelected =
                              !isAll && selected.contains(group.code);
                          return _buildSheetItem(
                            theme: theme,
                            label: group.name,
                            groupCode: group.code,
                            isSelected: isGroupSelected,
                            onTap: () {
                              setSheetState(() {
                                selected.remove('all');
                                if (selected.contains(group.code)) {
                                  selected.remove(group.code);
                                } else {
                                  selected.add(group.code);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),

                  // ── 底部操作栏 ──
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.of(context).padding.bottom + 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _handleGroupSelection(selected.toList());
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(l10n.confirm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 构建报表筛选项
  Widget _buildReportItem({
    required ThemeData theme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withAlpha(10) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Icon(
            Icons.assessment_rounded,
            size: 20,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          title: Text(
            L10nManager.l10n.reportFilterLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : null,
              color: isSelected ? colorScheme.primary : null,
            ),
          ),
          subtitle: Text(L10nManager.l10n.reportSectionComparison, style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          )),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 22)
              : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onTap: onTap,
        ),
      ),
    );
  }

  /// 构建抽屉列表项（匹配 _SheetItemTile 样式）
  Widget _buildSheetItem({
    required ThemeData theme,
    required String label,
    required String groupCode,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withAlpha(10) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isSelected ? colorScheme.primary : colorScheme.outline.withAlpha(40),
            ),
          ),
          title: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : null,
              color: isSelected ? colorScheme.primary : null,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: 22,
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      height: 42,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGroupDrawer(context, theme),
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getSelectedLabel(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
