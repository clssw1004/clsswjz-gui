import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_radius.dart';
import 'common_badge.dart';

/// 展示模式
enum DisplayMode {
  /// 图标+文本
  iconText,

  /// 徽章显示
  badge,

  /// 展开显示
  expand,
}

/// 通用选择表单组件
class CommonSelectFormField<T> extends FormField<dynamic> {
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
  }) : super(
          initialValue: value,
          builder: (state) {
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
  });

  @override
  State<_CommonSelectFormFieldWidget<T>> createState() => _CommonSelectFormFieldWidgetState<T>();
}

class _CommonSelectFormFieldWidgetState<T> extends State<_CommonSelectFormFieldWidget<T>> {
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 搜索关键字
  String _searchText = '';

  /// 过滤后的数据列表
  List<T> get _filteredItems {
    if (_searchText.isEmpty) return widget.items;
    return widget.items.where((item) {
      final text = widget.displayField(item).toLowerCase();
      return text.contains(_searchText.toLowerCase());
    }).toList();
  }

  /// 获取当前选中的项
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 处理选项改变
  void _handleItemChanged(T? item) {
    if (widget.onChanged != null) {
      widget.onChanged!(widget.onchangeArgs(item as T));
    }
  }

  /// 显示选择弹窗
  Future<void> _showSelectDialog({bool isAddMode = false}) async {
    final result = await showDialog<T>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Theme.of(context).extension<ThemeRadius>()?.radius ?? 16,
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 当没有选项时，始终显示搜索框
                  if (widget.items.isEmpty || widget.searchable || isAddMode)
                    TextField(
                      controller: _searchController,
                      autofocus: widget.items.isEmpty || isAddMode, // 当没有选项或新增模式时自动获取焦点
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: widget.items.isEmpty || isAddMode ? L10nManager.l10n.addNew(widget.label ?? '') : L10nManager.l10n.search,
                        prefixIcon: Icon(
                          widget.items.isEmpty || isAddMode ? Icons.add : Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        suffixIcon: _searchText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchText = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Theme.of(context).extension<ThemeRadius>()?.radius ?? 4,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      },
                    )
                  else
                    Text(
                      widget.label ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: widget.items.isEmpty && _searchText.isEmpty
                    ? Center(
                        child: Text(
                          L10nManager.l10n.noData,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(60),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredItems.length + (_searchText.isNotEmpty && widget.allowCreate ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _filteredItems.length) {
                            // 显示新增选项
                            return ListTile(
                              leading: const Icon(Icons.add),
                              title: Text(L10nManager.l10n.addNew(_searchText)),
                              onTap: () async {
                                if (widget.onCreateItem != null) {
                                  final newItem = await widget.onCreateItem!(_searchText);
                                  if (newItem != null && mounted) {
                                    setState(() {
                                      _searchController.clear();
                                      _searchText = '';
                                    });
                                    Navigator.of(context).pop(newItem);
                                  }
                                }
                              },
                            );
                          }

                          final item = _filteredItems[index];
                          final isSelected = widget.value != null && widget.keyField(item) == widget.value;

                          return ListTile(
                            title: Text(widget.displayField(item)),
                            selected: isSelected,
                            onTap: () {
                              Navigator.of(context).pop(item);
                            },
                          );
                        },
                      ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      _handleItemChanged(result);
    }
  }

  /// 构建图标
  Widget? _buildIcon(IconData? icon) {
    if (icon == null) return null;
    return Icon(
      icon,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: 24,
    );
  }

  /// 构建图标文本模式
  Widget _buildIconTextMode() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: theme.colorScheme.surface,
      child: TextFormField(
        readOnly: true,
        onTap: _showSelectDialog,
        decoration: InputDecoration(
          labelText: widget.required ? '${widget.label} *' : widget.label,
          hintText: widget.hint ?? (widget.required ? null : L10nManager.l10n.optional),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(60),
          ),
          errorText: widget.errorText,
          prefixIcon: _buildIcon(widget.icon),
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: colorScheme.onSurfaceVariant,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.all(16),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
          ),
        ),
        controller: TextEditingController(
          text: _selectedItem != null ? widget.displayField(_selectedItem as T) : '',
        ),
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  /// 构建徽章模式
  Widget _buildBadgeMode() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      children: [
        CommonBadge(
          icon: widget.icon,
          text: _selectedItem != null ? widget.displayField(_selectedItem as T) : widget.hint ?? widget.label ?? '',
          onTap: _showSelectDialog,
          selected: _selectedItem != null,
          backgroundColor: _selectedItem != null ? (widget.badgeColor ?? colorScheme.secondaryContainer) : null,
          textColor:
              _selectedItem != null ? (widget.badgeColor != null ? theme.colorScheme.onSurface : colorScheme.onSecondaryContainer) : null,
          iconColor:
              _selectedItem != null ? (widget.badgeColor != null ? theme.colorScheme.onSurface : colorScheme.onSecondaryContainer) : null,
          borderColor: colorScheme.outline.withAlpha(51),
        ),
      ],
    );
  }

  /// 构建更多按钮
  Widget _buildMoreButton(double buttonWidth, ThemeData theme) {
    return SizedBox(
      width: buttonWidth,
      child: Center(
        child: ActionChip(
          elevation: 0,
          pressElevation: 0,
          side: BorderSide(
            color: theme.colorScheme.outline,
            width: 1,
          ),
          backgroundColor: theme.colorScheme.surface,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
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
          onPressed: _showSelectDialog,
        ),
      ),
    );
  }

  /// 构建新增按钮
  Widget _buildAddButton(double buttonWidth, ThemeData theme) {
    return SizedBox(
      width: buttonWidth,
      child: Center(
        child: ActionChip(
          elevation: 0,
          pressElevation: 0,
          side: BorderSide(
            color: theme.colorScheme.primary.withAlpha(50),
            width: 1,
          ),
          backgroundColor: theme.colorScheme.primary.withAlpha(5),
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          avatar: null,
          labelPadding: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          label: SizedBox(
            width: buttonWidth - 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    L10nManager.l10n.addNew(widget.label ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          onPressed: () {
            _searchController.clear();
            _searchText = '';
            _showSelectDialog(isAddMode: true);
          },
        ),
      ),
    );
  }

  /// 构建展开模式
  Widget _buildExpandMode() {
    final theme = Theme.of(context);

    // 计算每行显示的数量
    final itemsPerRow = (widget.expandCount / widget.expandRows).ceil();
    // 计算按钮宽度（减去padding和spacing的空间）
    final buttonWidth = (MediaQuery.of(context).size.width - 32 - (itemsPerRow - 1) * 8) / itemsPerRow;

    // 是否需要显示更多按钮
    final showMore = widget.items.length > widget.expandCount;
    // 是否显示新增按钮（当项目数量少于展开数量且允许创建时）
    final showAdd = !showMore && widget.allowCreate;

    // 获取要显示的选项
    List<T> displayItems = [];
    if (showMore) {
      // 如果需要显示更多按钮，则显示expandCount个选项
      displayItems = List.from(widget.items.take(widget.expandCount));
    } else {
      // 否则显示所有选项
      displayItems = List.from(widget.items);
    }

    // 如果选中项不在显示列表中，添加到列表末尾
    if (_selectedItem != null && displayItems.where((item) => widget.keyField(item) == widget.value).isEmpty) {
      if (showMore) {
        // 如果显示更多按钮，确保不超过expandCount
        if (displayItems.length >= widget.expandCount) {
          displayItems[widget.expandCount - 1] = _selectedItem as T;
        } else {
          displayItems.add(_selectedItem as T);
        }
      } else if (!showAdd || displayItems.length < widget.expandCount) {
        // 如果不显示更多按钮，且（不显示新增按钮或还有空间），直接添加
        displayItems.add(_selectedItem as T);
      } else if (displayItems.isNotEmpty) {
        // 如果要显示新增按钮且没有空间，替换最后一项
        displayItems[displayItems.length - 1] = _selectedItem as T;
      }
    }

    // 将选项按行分组
    final rows = <List<T>>[];
    for (var i = 0; i < displayItems.length; i += itemsPerRow) {
      final endIndex = i + itemsPerRow;
      // 计算实际结束索引
      final actualEndIndex = endIndex > displayItems.length
          ? displayItems.length
          : (i + itemsPerRow == displayItems.length && // 是最后一行
                (showMore || showAdd) && // 需要显示按钮
                displayItems.length % itemsPerRow == 0 && // 正好填满一行
                displayItems.length >= itemsPerRow) // 不是第一行
              ? endIndex - 1
              : endIndex;
      rows.add(displayItems.sublist(i, actualEndIndex));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
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
                        final isSelected = widget.value != null && widget.keyField(item) == widget.value;

                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: buttonWidth,
                          child: Center(
                            child: ChoiceChip(
                              showCheckmark: false,
                              elevation: 0,
                              pressElevation: 0,
                              selectedColor: theme.colorScheme.primaryContainer,
                              side: BorderSide(
                                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                                width: 1,
                              ),
                              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                              ),
                              labelPadding: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                _handleItemChanged(selected ? item : null);
                              },
                            ),
                          ),
                        );
                      }),
                      if (showButton)
                        SizedBox(
                          width: buttonWidth,
                          child: showMore ? _buildMoreButton(buttonWidth, theme) : _buildAddButton(buttonWidth, theme),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
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
