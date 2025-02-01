import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../models/common.dart';
import '../../utils/toast_util.dart';
import 'common_app_bar.dart';
import 'common_dialog.dart';
import 'common_text_form_field.dart';

/// 通用列表页面配置
class CommonSimpleCrudListConfig<T> {
  /// 页面标题
  final String title;

  /// 是否显示类型
  final bool showType;

  /// 类型选项（如果 showType 为 true，则必须提供）
  final List<String>? typeOptions;

  /// 获取类型显示文本
  final String Function(String type)? getTypeText;

  /// 获取项目名称
  final String Function(T item) getName;

  /// 获取项目类型
  final String? Function(T item)? getType;

  /// 数据加载方法
  final Future<OperateResult<List<T>>> Function() loadData;

  /// 创建项目方法
  final Future<OperateResult<String>> Function(String name, String? type) createItem;

  /// 更新项目方法
  final Future<OperateResult<void>> Function(T item, {required String name, String? type}) updateItem;

  /// 删除项目方法
  final Future<OperateResult<void>> Function(T item) deleteItem;

  /// 筛选区域组件（可选）
  final PreferredSizeWidget? filterWidget;

  const CommonSimpleCrudListConfig({
    required this.title,
    this.showType = false,
    this.typeOptions,
    this.getTypeText,
    required this.getName,
    this.getType,
    required this.loadData,
    required this.createItem,
    required this.updateItem,
    required this.deleteItem,
    this.filterWidget,
  });
}

class CommonSimpleCrudList<T> extends StatefulWidget {
  final CommonSimpleCrudListConfig<T> config;
  final VoidCallback? onFilterChanged;

  const CommonSimpleCrudList({
    super.key,
    required this.config,
    this.onFilterChanged,
  });

  @override
  State<CommonSimpleCrudList<T>> createState() => CommonSimpleCrudListState<T>();
}

class CommonSimpleCrudListState<T> extends State<CommonSimpleCrudList<T>> {
  List<T>? _items;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.config.loadData();
      if (mounted) {
        setState(() {
          _loading = false;
          if (result.ok) {
            _items = result.data;
          } else {
            _error = result.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _showFormDialog({T? item}) async {
    var inputName = item != null ? widget.config.getName(item) : '';
    String? selectedType;
    if (item != null) {
      selectedType = widget.config.getType?.call(item);
    }
    selectedType ??= widget.config.typeOptions?.first;

    final result = await CommonDialog.show<bool>(
      context: context,
      title: item == null ? L10nManager.l10n.create : L10nManager.l10n.edit,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonTextFormField(
            initialValue: inputName,
            labelText: L10nManager.l10n.name,
            hintText: L10nManager.l10n.required,
            required: true,
            onChanged: (value) => inputName = value,
          ),
          if (widget.config.showType && widget.config.typeOptions != null) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: widget.config.typeOptions!.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(widget.config.getTypeText!(type)),
                );
              }).toList(),
              onChanged: (value) => selectedType = value,
              decoration: InputDecoration(
                labelText: L10nManager.l10n.type,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(L10nManager.l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(L10nManager.l10n.confirm),
              ),
            ],
          ),
        ],
      ),
      showCloseButton: false,
    );

    if (result == true) {
      if (inputName.trim().isEmpty) {
        return;
      }

      setState(() => _loading = true);
      try {
        if (item == null) {
          // 创建
          final result = await widget.config.createItem(inputName, selectedType);
          if (result.ok) {
            await _loadData();
          } else {
            _showError(result.message);
          }
        } else {
          // 更新
          final result = await widget.config.updateItem(
            item,
            name: inputName,
            type: selectedType,
          );
          if (result.ok) {
            await _loadData();
          } else {
            _showError(result.message);
          }
        }
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
  }

  Future<void> _deleteItem(T item) async {
    final confirm = await CommonDialog.show<bool>(
      context: context,
      title: L10nManager.l10n.confirmDelete,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(L10nManager.l10n.deleteConfirmMessage(widget.config.getName(item))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(L10nManager.l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(L10nManager.l10n.confirm),
              ),
            ],
          ),
        ],
      ),
      showCloseButton: false,
    );

    if (confirm == true) {
      setState(() => _loading = true);
      try {
        final result = await widget.config.deleteItem(item);
        if (result.ok) {
          await _loadData();
        } else {
          _showError(result.message);
        }
      } finally {
        if (mounted) {
          setState(() => _loading = false);
        }
      }
    }
  }

  void _showError(String? message) {
    if (mounted && message != null) {
      ToastUtil.showError(message);
    }
  }

  void refresh() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.config.title),
        bottom: widget.config.filterWidget,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                      TextButton(
                        onPressed: _loadData,
                        child: Text(L10nManager.l10n.retry),
                      ),
                    ],
                  ),
                )
              : _items?.isEmpty == true
                  ? Center(
                      child: Text(L10nManager.l10n.noData),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _items?.length ?? 0,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _items![index];
                        final type = widget.config.getType?.call(item);

                        return ListTile(
                          title: Text(widget.config.getName(item)),
                          subtitle: widget.config.showType && type != null ? Text(widget.config.getTypeText!(type)) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showFormDialog(item: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteItem(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
