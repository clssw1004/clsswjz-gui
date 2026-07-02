import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../theme/theme_radius.dart';
import 'common_badge.dart';
import 'multi_select_sheet.dart';
import 'multi_select_dialog.dart';
import 'selection_trigger.dart';
import 'selection_sheet_shell.dart';
import 'tree_select/tree_select_sheet.dart';
import 'tree_select/tree_select_connector.dart';

/// 展示模式
enum DisplayMode {
  /// 图标+文本
  iconText,

  /// 徽章显示
  badge,

  /// 展开显示
  expand,
}

/// 通用选择表单组件（支持单选/多选）
class CommonSelectFormField<T> extends FormField<dynamic> {
  /// 是否多选模式
  final bool multiSelect;

  /// 树形数据源（传入后在"更多"面板中展示层级缩进列表）
  final List<TreeNode<T>>? treeRoots;

  /// 智能评分数据
  final Map<String, double>? scores;

  CommonSelectFormField({
    super.key,
    required List<T> items,
    dynamic value,
    DisplayMode displayMode = DisplayMode.iconText,
    required String Function(T item) displayField,
    required dynamic Function(T item) keyField,
    T Function(T item)? onchangeArgs,
    IconData? icon,
    String? label,
    String? hint,
    int expandCount = 8,
    int expandRows = 3,
    bool searchable = true,
    bool allowCreate = true,
    ValueChanged<dynamic>? onChanged,
    Future<T?> Function(String value)? onCreateItem,
    bool? required,
    super.validator,
    Color? badgeColor,
    this.multiSelect = false,
    this.treeRoots,
    this.scores,
  }) : super(
          initialValue: multiSelect
              ? (value is List ? List<String>.from(value) : <String>[])
              : value,
          builder: (state) {
            if (multiSelect) {
              return _MultiSelectFieldWidget<T>(
                items: items,
                value: (state.value is List
                    ? List<String>.from(state.value)
                    : <String>[]),
                displayField: displayField,
                keyField: keyField,
                icon: icon,
                label: label,
                hint: hint,
                searchable: searchable,
                allowCreate: allowCreate,
                errorText: state.errorText,
                onChanged: (selected) {
                  state.didChange(selected);
                  if (onChanged != null) onChanged(selected);
                },
                onCreateItem: onCreateItem,
              );
            }
            return _CommonSelectFormFieldWidget<T>(
              items: items,
              value: value,
              displayMode: displayMode,
              displayField: displayField,
              keyField: keyField,
              icon: icon,
              label: label,
              hint: hint,
              expandCount: expandCount,
              expandRows: expandRows,
              searchable: searchable,
              allowCreate: allowCreate,
              required: required ?? false,
              errorText: state.errorText,
              onChanged: (value) {
                state.didChange(value is T ? keyField(value) : value);
                if (onChanged != null) {
                  onChanged(value);
                }
              },
              onCreateItem: onCreateItem,
              onchangeArgs: onchangeArgs ?? (item) => item,
              badgeColor: badgeColor,
              treeRoots: treeRoots,
              scores: scores,
            );
          },
        );
}

class _CommonSelectFormFieldWidget<T> extends StatefulWidget {
  final List<T> items;
  final dynamic value;
  final DisplayMode displayMode;
  final String Function(T item) displayField;
  final dynamic Function(T item) keyField;
  final IconData? icon;
  final String? label;
  final String? hint;
  final int expandCount;
  final int expandRows;
  final bool searchable;
  final bool allowCreate;
  final bool required;
  final String? errorText;
  final ValueChanged<dynamic>? onChanged;
  final Future<T?> Function(String value)? onCreateItem;
  final dynamic Function(T item) onchangeArgs;
  final Color? badgeColor;
  final List<TreeNode<T>>? treeRoots;
  final Map<String, double>? scores;

  const _CommonSelectFormFieldWidget({
    required this.items,
    this.value,
    required this.displayMode,
    required this.displayField,
    required this.keyField,
    required this.onchangeArgs,
    this.icon,
    this.label,
    this.hint,
    required this.expandCount,
    required this.expandRows,
    required this.searchable,
    required this.allowCreate,
    required this.required,
    this.errorText,
    this.onChanged,
    this.onCreateItem,
    this.badgeColor,
    this.treeRoots,
    this.scores,
  });

  @override
  State<_CommonSelectFormFieldWidget<T>> createState() =>
      _CommonSelectFormFieldWidgetState<T>();
}

class _CommonSelectFormFieldWidgetState<T>
    extends State<_CommonSelectFormFieldWidget<T>> {
  T? get _selectedItem {
    if (widget.value == null) return null;
    try {
      return widget.items.firstWhere(
        (item) => widget.keyField(item) == widget.value,
      );
    } catch (e) {
      return null;
    }
  }

  void _handleItemChanged(T? item) {
    if (widget.onChanged != null) {
      widget.onChanged!(item != null ? widget.onchangeArgs(item) : null);
    }
  }

  Future<void> _showSelectionSheet({bool isAddMode = false}) async {
    // 树形数据 → 直接使用 TreeSelectSheet
    if (widget.treeRoots != null) {
      HapticFeedback.mediumImpact();
      final radius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;
      final result = await showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius * 1.5),
          ),
        ),
        builder: (ctx) => TreeSelectSheet<T>(
          filtered: widget.treeRoots!,
          displayField: widget.displayField,
          idField: (item) => widget.keyField(item).toString(),
          multiSelect: false,
          label: widget.label,
          initialValue: widget.value,
          allowCreate: widget.allowCreate,
          onCreateItem: widget.onCreateItem,
          isSelectableCheck: (data) {
            try {
              return (data as dynamic).isBookkeepingSelectable ?? true;
            } catch (_) {
              return true;
            }
          },
          scores: widget.scores,
        ),
      );
      if (result != null && mounted) _handleItemChanged(result);
      return;
    }

    // 扁平数据 → 原有流程
    HapticFeedback.mediumImpact();
    final result = await _buildSelectionSheet(isAddMode: isAddMode);
    if (result != null && mounted) {
      _handleItemChanged(result);
    }
  }

  Future<T?> _buildSelectionSheet({bool isAddMode = false}) async {
    final localController = TextEditingController();
    String localSearch = '';
    bool loading = false;

    final theme = Theme.of(context);
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            final localTheme = Theme.of(ctx);
            final localColor = localTheme.colorScheme;
            final localRadius = localTheme.extension<ThemeRadius>()?.radius ?? 12;

            final showSearch =
                widget.items.isEmpty || widget.searchable || isAddMode;
            final filtered = localSearch.isEmpty
                ? widget.items
                : widget.items.where((item) {
                    return widget
                        .displayField(item)
                        .toLowerCase()
                        .contains(localSearch.toLowerCase());
                  }).toList();
            final hasExactMatch = localSearch.isNotEmpty && widget.items.any(
                  (item) =>
                      widget.displayField(item).toLowerCase() ==
                      localSearch.toLowerCase(),
                );
            final showCreate = localSearch.isNotEmpty &&
                widget.allowCreate &&
                !hasExactMatch &&
                !loading;

            final itemCount =
                filtered.length + (showCreate ? 1 : 0) + (widget.items.isEmpty && localSearch.isEmpty ? 1 : 0);

            return SelectionSheetShell(
              headerIcon: showSearch ? null : widget.icon,
              headerTitle: showSearch ? null : (widget.label ?? ''),
              maxHeightRatio: 0.68,
              minHeight: 200,
              children: [
                if (showSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      controller: localController,
                      autofocus: widget.items.isEmpty || isAddMode,
                      style: localTheme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: widget.items.isEmpty || isAddMode
                            ? L10nManager.l10n.addNew(widget.label ?? '')
                            : L10nManager.l10n.search,
                        prefixIcon: Icon(
                          widget.items.isEmpty || isAddMode
                              ? Icons.add_circle_outline
                              : Icons.search,
                          color: localColor.primary,
                          size: 22,
                        ),
                        suffixIcon: localSearch.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () {
                                  localController.clear();
                                  setLocalState(() => localSearch = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: localColor.surfaceContainerHighest
                            .withAlpha(40),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(localRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (v) =>
                          setLocalState(() => localSearch = v),
                    ),
                  ),
                if (itemCount > 0)
                  Divider(height: 1, color: localColor.outline.withAlpha(20)),
                  Expanded(
                    child: itemCount == 0
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inbox_outlined,
                                      size: 40,
                                      color: localColor.onSurfaceVariant
                                          .withAlpha(60)),
                                  const SizedBox(height: 8),
                                  Text(
                                    L10nManager.l10n.noData,
                                    style:
                                        localTheme.textTheme.bodyMedium?.copyWith(
                                      color: localColor.onSurfaceVariant
                                          .withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(top: 4, bottom: 16),
                            controller: PrimaryScrollController.maybeOf(ctx),
                            children: [
                              ...filtered.map((item) {
                                final isSelected = widget.value != null &&
                                    widget.keyField(item) == widget.value;
                                return _SheetItemTile<T>(
                                  item: item,
                                  isSelected: isSelected,
                                  displayField: widget.displayField,
                                  onTap: () {
                                    localController.dispose();
                                    Navigator.of(ctx).pop(item);
                                  },
                                );
                              }),
                              if (showCreate)
                                _SheetCreateTile<T>(
                                  searchText: localSearch,
                                  label: widget.label ?? '',
                                  loading: loading,
                                  onCreate: () async {
                                    if (widget.onCreateItem == null) return;
                                    setLocalState(() => loading = true);
                                    final newItem =
                                        await widget.onCreateItem!(localSearch);
                                    setLocalState(() => loading = false);
                                    if (newItem != null && ctx.mounted) {
                                      localController.dispose();
                                      Navigator.of(ctx).pop(newItem);
                                    }
                                  },
                                ),
                            ],
                          ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIconTextMode() {
    return SelectionTrigger(
      label: widget.required ? '${widget.label} *' : widget.label,
      hint: widget.hint ?? (widget.required ? null : L10nManager.l10n.optional),
      errorText: widget.errorText,
      displayText:
          _selectedItem != null ? widget.displayField(_selectedItem as T) : '',
      prefixIcon: widget.icon,
      prefixIconSize: 24,
      onTap: () => _showSelectionSheet(),
    );
  }

  Widget _buildBadgeMode() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      children: [
        CommonBadge(
          icon: widget.icon,
          text: _selectedItem != null
              ? widget.displayField(_selectedItem as T)
              : widget.hint ?? widget.label ?? '',
          onTap: () => _showSelectionSheet(),
          selected: _selectedItem != null,
          backgroundColor: _selectedItem != null
              ? (widget.badgeColor ?? colorScheme.secondaryContainer)
              : null,
          textColor: _selectedItem != null
              ? (widget.badgeColor != null
                  ? theme.colorScheme.onSurface
                  : colorScheme.onSecondaryContainer)
              : null,
          iconColor: _selectedItem != null
              ? (widget.badgeColor != null
                  ? theme.colorScheme.onSurface
                  : colorScheme.onSecondaryContainer)
              : null,
          borderColor: colorScheme.outline.withAlpha(51),
        ),
      ],
    );
  }

  Widget _buildMoreButton(double buttonWidth, ThemeData theme) {
    return SizedBox(
      width: buttonWidth,
      child: Center(
        child: ActionChip(
          elevation: 0,
          pressElevation: 0,
          side: BorderSide(
            color: theme.colorScheme.outline.withAlpha(80),
            width: 1,
          ),
          backgroundColor:
              theme.colorScheme.surfaceContainerHighest.withAlpha(30),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          labelPadding: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: SizedBox(
            width: buttonWidth - 32,
            child: Text(
              L10nManager.l10n.more,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: () => _showSelectionSheet(),
        ),
      ),
    );
  }

  Widget _buildAddButton(double buttonWidth, ThemeData theme) {
    return SizedBox(
      width: buttonWidth,
      child: Center(
        child: ActionChip(
          elevation: 0,
          pressElevation: 0,
          side: BorderSide(
            color: theme.colorScheme.primary.withAlpha(60),
            width: 1,
          ),
          backgroundColor: theme.colorScheme.primary.withAlpha(10),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          labelPadding: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: SizedBox(
            width: buttonWidth - 32,
            child: Text(
              L10nManager.l10n.addNew(widget.label ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          onPressed: () => _showSelectionSheet(isAddMode: true),
        ),
      ),
    );
  }

  Widget _buildExpandMode() {
    final theme = Theme.of(context);

    final itemsPerRow =
        (widget.expandCount / widget.expandRows).ceil();
    final buttonWidth =
        (MediaQuery.of(context).size.width - 32 - (itemsPerRow - 1) * 8) /
            itemsPerRow;

    final showMore = widget.items.length > widget.expandCount;
    final showAdd = !showMore && widget.allowCreate;

    List<T> displayItems = [];
    if (showMore) {
      displayItems = List.from(widget.items.take(widget.expandCount));
    } else {
      displayItems = List.from(widget.items);
    }

    if (_selectedItem != null &&
        displayItems
            .where((item) => widget.keyField(item) == widget.value)
            .isEmpty) {
      if (showMore) {
        if (displayItems.length >= widget.expandCount) {
          displayItems[widget.expandCount - 1] = _selectedItem as T;
        } else {
          displayItems.add(_selectedItem as T);
        }
      } else if (!showAdd || displayItems.length < widget.expandCount) {
        displayItems.add(_selectedItem as T);
      } else if (displayItems.isNotEmpty) {
        displayItems[displayItems.length - 1] = _selectedItem as T;
      }
    }

    final rows = <List<T>>[];
    for (var i = 0; i < displayItems.length; i += itemsPerRow) {
      final actualEndIndex = (i + itemsPerRow > displayItems.length)
          ? displayItems.length
          : (i + itemsPerRow == displayItems.length && (showMore || showAdd) &&
                  displayItems.length % itemsPerRow == 0 &&
                  displayItems.length >= itemsPerRow)
              ? i + itemsPerRow - 1
              : i + itemsPerRow;
      rows.add(displayItems.sublist(i, actualEndIndex));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...rows.map((rowItems) {
          final isLastRow = rows.indexOf(rowItems) == rows.length - 1;
          final showButton = isLastRow && (showMore || showAdd);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...rowItems.map((item) {
                    final isSelected = widget.value != null &&
                        widget.keyField(item) == widget.value;

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: buttonWidth,
                      child: Center(
                        child: ChoiceChip(
                          showCheckmark: false,
                          elevation: 0,
                          pressElevation: 0,
                          selectedColor:
                              theme.colorScheme.primaryContainer,
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline.withAlpha(35),
                            width: isSelected ? 1.2 : 1,
                          ),
                          labelStyle:
                              theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : null,
                          ),
                          labelPadding: EdgeInsets.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          label: SizedBox(
                            width: buttonWidth - 32,
                            child: Text(
                              widget.displayField(item),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            _handleItemChanged(
                                selected ? item : null);
                          },
                        ),
                      ),
                    );
                  }),
                  if (showButton)
                    SizedBox(
                      width: buttonWidth,
                      child: showMore
                          ? _buildMoreButton(buttonWidth, theme)
                          : _buildAddButton(buttonWidth, theme),
                    ),
                ],
              ),
            ),
          );
        }),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.displayMode) {
      case DisplayMode.iconText:
        return _buildIconTextMode();
      case DisplayMode.badge:
        return _buildBadgeMode();
      case DisplayMode.expand:
        return _buildExpandMode();
    }
  }
}

// ============================================================
// 多选模式实现
// ============================================================

class _MultiSelectFieldWidget<T> extends StatelessWidget {
  final List<T> items;
  final List<String> value;
  final String Function(T item) displayField;
  final dynamic Function(T item) keyField;
  final IconData? icon;
  final String? label;
  final String? hint;
  final bool searchable;
  final bool allowCreate;
  final String? errorText;
  final ValueChanged<List<String>>? onChanged;
  final Future<T?> Function(String value)? onCreateItem;

  const _MultiSelectFieldWidget({
    required this.items,
    required this.value,
    required this.displayField,
    required this.keyField,
    this.icon,
    this.label,
    this.hint,
    required this.searchable,
    required this.allowCreate,
    this.errorText,
    this.onChanged,
    this.onCreateItem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

    // Build display text: show selected items' names
    final selectedNames = value
        .map((id) {
          try {
            final item = items.firstWhere((i) => keyField(i) == id);
            return displayField(item);
          } catch (_) {
            return id;
          }
        })
        .join(', ');

    // Build MultiSelectSheet options
    final options = items
        .map((item) => MultiSelectOption(
              key: keyField(item).toString(),
              name: displayField(item),
            ))
        .toList();

    return InkWell(
      onTap: () async {
        HapticFeedback.mediumImpact();
        final result = await MultiSelectSheet.show(
          context,
          title: label ?? '',
          options: options,
          selectedIds: value,
        );
        if (result != null && onChanged != null) {
          onChanged!(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          hintText: hint ?? (selectedNames.isEmpty ? '请选择' : null),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withAlpha(30),
          prefixIcon: icon != null
              ? Icon(icon, color: colorScheme.onSurfaceVariant, size: 24)
              : null,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: BorderSide(
              color: colorScheme.primary.withAlpha(120),
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          selectedNames.isNotEmpty ? selectedNames : '请选择',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selectedNames.isNotEmpty
                ? null
                : colorScheme.onSurface.withAlpha(128),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 选择面板组件
// ============================================================

class _SheetItemTile<T> extends StatelessWidget {
  final T item;
  final bool isSelected;
  final String Function(T) displayField;
  final VoidCallback onTap;

  const _SheetItemTile({
    required this.item,
    required this.isSelected,
    required this.displayField,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final name = displayField(item);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withAlpha(25)
            : Colors.transparent,
        border: isSelected
            ? Border(left: BorderSide(color: colorScheme.primary, width: 3))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                const SizedBox(width: 16),
                LevelTab(level: 0, color: colorScheme.primary, isSelected: isSelected),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? colorScheme.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetCreateTile<T> extends StatelessWidget {
  final String searchText;
  final String label;
  final bool loading;
  final VoidCallback onCreate;

  const _SheetCreateTile({
    required this.searchText,
    required this.label,
    required this.loading,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onCreate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.primary.withAlpha(6),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: loading
                      ? SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(Icons.add_rounded, size: 22, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L10nManager.l10n.addNew(searchText),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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

