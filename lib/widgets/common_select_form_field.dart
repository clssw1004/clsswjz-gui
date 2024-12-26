import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    String? Function(dynamic)? validator,
    Color? badgeColor,
  }) : super(
          initialValue: value,
          validator: validator,
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
  State<_CommonSelectFormFieldWidget<T>> createState() =>
      _CommonSelectFormFieldWidgetState<T>();
}

class _CommonSelectFormFieldWidgetState<T>
    extends State<_CommonSelectFormFieldWidget<T>> {
  /// 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  /// 是否显示搜索框
  bool _showSearch = false;

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
  Future<void> _showSelectDialog() async {
    final result = await showDialog<T>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.searchable) ...[
                    if (_showSearch)
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.search,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchText = '';
                                _showSearch = false;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.label ?? ''),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                _showSearch = true;
                              });
                            },
                          ),
                        ],
                      ),
                  ] else
                    Text(widget.label ?? ''),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredItems.length +
                      (_searchText.isNotEmpty && widget.allowCreate ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _filteredItems.length) {
                      // 显示新增选项
                      return ListTile(
                        leading: const Icon(Icons.add),
                        title: Text('新增"$_searchText"'),
                        onTap: () async {
                          if (widget.onCreateItem != null) {
                            final newItem =
                                await widget.onCreateItem!(_searchText);
                            if (newItem != null) {
                              Navigator.of(context).pop(newItem);
                            }
                          }
                        },
                      );
                    }

                    final item = _filteredItems[index];
                    final isSelected = widget.value != null &&
                        widget.keyField(item) == widget.value;

                    return ListTile(
                      leading: widget.icon != null ? Icon(widget.icon) : null,
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

  /// 构建图标文本模式
  Widget _buildIconTextMode() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      readOnly: true,
      onTap: _showSelectDialog,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        suffixIcon: const Icon(Icons.arrow_drop_down),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: const UnderlineInputBorder(),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      controller: TextEditingController(
        text: _selectedItem != null ? widget.displayField(_selectedItem!) : '',
      ),
      style: theme.textTheme.bodyLarge,
    );
  }

  /// 构建徽章模式
  Widget _buildBadgeMode() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final badgeColor = widget.badgeColor ?? colorScheme.secondaryContainer;
    final badgeTextColor = widget.badgeColor != null
        ? theme.colorScheme.onSurface
        : colorScheme.onSecondaryContainer;

    return Wrap(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showSelectDialog,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _selectedItem != null
                    ? badgeColor
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: _selectedItem != null
                          ? badgeTextColor
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    _selectedItem != null
                        ? widget.displayField(_selectedItem!)
                        : widget.hint ?? widget.label ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _selectedItem != null
                          ? badgeTextColor
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建展开模式
  Widget _buildExpandMode() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 计算每行显示的数量
    final itemsPerRow = (widget.expandCount / widget.expandRows).ceil();
    // 计算按钮宽度
    final buttonWidth =
        (MediaQuery.of(context).size.width - 32 - (itemsPerRow - 1) * 8) /
            itemsPerRow;

    // 获取要显示的选项
    List<T> displayItems = List.from(widget.items.take(widget.expandCount));

    // 如果选中项不在显示列表中，替换最后一个选项
    if (_selectedItem != null && !displayItems.contains(_selectedItem)) {
      if (displayItems.isNotEmpty) {
        displayItems[displayItems.length - 1] = _selectedItem!;
      }
    }

    // 是否需要显示更多按钮
    final showMore = widget.items.length > widget.expandCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.required ? '${widget.label} *' : widget.label!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...displayItems.map((item) {
              final isSelected =
                  widget.value != null && widget.keyField(item) == widget.value;

              return SizedBox(
                width: buttonWidth,
                child: Center(
                  child: ChoiceChip(
                    showCheckmark: false,
                    elevation: 0,
                    pressElevation: 0,
                    selectedColor: theme.colorScheme.primaryContainer,
                    side: BorderSide(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 1,
                    ),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
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
            if (showMore)
              SizedBox(
                width: buttonWidth,
                child: Center(
                  child: ActionChip(
                    elevation: 0,
                    pressElevation: 0,
                    side: BorderSide(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    labelPadding: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    label: SizedBox(
                      width: buttonWidth - 32,
                      child: Text(
                        AppLocalizations.of(context)!.more,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onPressed: _showSelectDialog,
                  ),
                ),
              ),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Text(
              widget.errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
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
