import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/common.dart';
import 'common_app_bar.dart';
import 'common_dialog.dart';
import 'common_text_form_field.dart';

/// 通用列表页面配置
class CommonListConfig<T> {
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
  final Future<OperateResult<String>> Function(String name, String code, String? type) createItem;
  
  /// 更新项目方法
  final Future<OperateResult<void>> Function(T item, {required String name, String? type}) updateItem;
  
  /// 删除项目方法
  final Future<OperateResult<void>> Function(T item) deleteItem;

  /// 筛选区域组件（可选）
  final PreferredSizeWidget? filterWidget;

  const CommonListConfig({
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

class CommonListPage<T> extends StatefulWidget {
  final CommonListConfig<T> config;
  final VoidCallback? onFilterChanged;

  const CommonListPage({
    super.key,
    required this.config,
    this.onFilterChanged,
  });

  @override
  State<CommonListPage<T>> createState() => CommonListPageState<T>();
}

class CommonListPageState<T> extends State<CommonListPage<T>> {
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
    final l10n = AppLocalizations.of(context)!;
    var inputName = item != null ? widget.config.getName(item) : '';
    String? selectedType;
    if (item != null) {
      selectedType = widget.config.getType?.call(item);
    }
    selectedType ??= widget.config.typeOptions?.first;

    final result = await CommonDialog.show<bool>(
      context: context,
      title: item == null ? l10n.create : l10n.edit,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonTextFormField(
            initialValue: inputName,
            labelText: l10n.name,
            hintText: l10n.required,
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
                labelText: l10n.type,
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
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.confirm),
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
          final code = inputName.toLowerCase().replaceAll(' ', '_');
          final result = await widget.config.createItem(inputName, code, selectedType);
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
    final l10n = AppLocalizations.of(context)!;
    final confirm = await CommonDialog.show<bool>(
      context: context,
      title: l10n.confirmDelete,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.deleteConfirmMessage(widget.config.getName(item))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.confirm),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void refresh() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.config.filterWidget != null
          ? AppBar(
              title: Text(widget.config.title),
              bottom: widget.config.filterWidget,
            )
          : CommonAppBar(
              title: Text(widget.config.title),
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
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _items?.isEmpty == true
                  ? Center(
                      child: Text(l10n.noData),
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
                          subtitle: widget.config.showType && type != null
                              ? Text(widget.config.getTypeText!(type))
                              : null,
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