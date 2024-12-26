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
class CommonSelectFormField<T> extends FormField<T> {
  CommonSelectFormField({
    super.key,
    required List<T> items,
    T? value,
    DisplayMode displayMode = DisplayMode.iconText,
    required String Function(T item) displayField,
    required dynamic Function(T item) keyField,
    IconData? icon,
    String? label,
    String? hint,
    int expandCount = 6,
    int expandRows = 2,
    bool searchable = true,
    bool allowCreate = true,
    ValueChanged<T?>? onChanged,
    Future<T?> Function(String value)? onCreateItem,
    bool? required,
    String? Function(T?)? validator,
  }) : super(
          initialValue: value,
          validator: validator,
          builder: (state) {
            return _CommonSelectFormFieldWidget<T>(
              items: items,
              value: state.value,
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
                state.didChange(value);
                onChanged?.call(value);
              },
              onCreateItem: onCreateItem,
            );
          },
        );
}

class _CommonSelectFormFieldWidget<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
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
  final ValueChanged<T?>? onChanged;
  final Future<T?> Function(String value)? onCreateItem;

  const _CommonSelectFormFieldWidget({
    required this.items,
    this.value,
    required this.displayMode,
    required this.displayField,
    required this.keyField,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                        widget.keyField(item) == widget.keyField(widget.value!);

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

    if (result != null && widget.onChanged != null) {
      widget.onChanged!(result);
    }
  }

  /// 构建图标文本模式
  Widget _buildIconTextMode() {
    return InkWell(
      onTap: _showSelectDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          icon: widget.icon != null ? Icon(widget.icon) : null,
          labelText: widget.required ? '${widget.label} *' : widget.label,
          hintText: widget.hint,
          errorText: widget.errorText,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.value != null ? widget.displayField(widget.value!) : '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  /// 构建徽章模式
  Widget _buildBadgeMode() {
    return InkWell(
      onTap: _showSelectDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          icon: widget.icon != null ? Icon(widget.icon) : null,
          labelText: widget.required ? '${widget.label} *' : widget.label,
          hintText: widget.hint,
          errorText: widget.errorText,
        ),
        child: widget.value != null
            ? Chip(
                label: Text(widget.displayField(widget.value!)),
                onDeleted: () {
                  widget.onChanged?.call(null);
                },
              )
            : null,
      ),
    );
  }

  /// 构建展开模式
  Widget _buildExpandMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.required ? '${widget.label} *' : widget.label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.items.take(widget.expandCount).map((item) {
              final isSelected = widget.value != null &&
                  widget.keyField(item) == widget.keyField(widget.value!);
              return ChoiceChip(
                label: Text(widget.displayField(item)),
                selected: isSelected,
                onSelected: (selected) {
                  widget.onChanged?.call(selected ? item : null);
                },
              );
            }),
            if (widget.items.length > widget.expandCount)
              ActionChip(
                label: const Text('更多'),
                onPressed: _showSelectDialog,
              ),
          ],
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Text(
              widget.errorText!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
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
