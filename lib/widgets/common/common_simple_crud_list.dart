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

  /// 列表项点击事件（可选）
  final void Function(T item)? onItemTap;

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
    this.onItemTap,
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
    final theme = Theme.of(context);
    var inputName = item != null ? widget.config.getName(item) : '';
    String? selectedType;
    if (item != null) {
      selectedType = widget.config.getType?.call(item);
    }
    selectedType ??= widget.config.typeOptions?.first;

    final result = await CommonDialog.show<bool>(
      context: context,
      title: item == null ? L10nManager.l10n.create : L10nManager.l10n.edit,
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60), width: 1),
        ),
        child: Column(
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: widget.config.typeOptions!.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(widget.config.getTypeText!(type)),
                  );
                }).toList(),
                onChanged: (value) => selectedType = value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  labelText: L10nManager.l10n.type,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(120)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(L10nManager.l10n.cancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (inputName.trim().isEmpty) {
                      ToastUtil.showError(L10nManager.l10n.required);
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text(L10nManager.l10n.confirm),
                ),
              ],
            ),
          ],
        ),
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
    final theme = Theme.of(context);
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
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
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
    final colorScheme = theme.colorScheme;

    Widget buildEmpty() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: colorScheme.onSurfaceVariant.withAlpha(128)),
            const SizedBox(height: 12),
            Text(L10nManager.l10n.noData, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(L10nManager.l10n.retry),
            ),
          ],
        ),
      );
    }

    Widget buildError() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 12),
            Text(_error!, style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.error)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: Text(L10nManager.l10n.retry),
            ),
          ],
        ),
      );
    }

    final list = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? buildError()
            : _items?.isEmpty == true
                ? buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _items?.length ?? 0,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _items![index];
                      final type = widget.config.getType?.call(item);
                      final title = widget.config.getName(item);
                      final subtitle = widget.config.showType && type != null
                          ? widget.config.getTypeText!(type)
                          : null;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: widget.config.onItemTap == null ? null : () => widget.config.onItemTap!(item),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colorScheme.outlineVariant.withAlpha(60), width: 1),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (subtitle != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          subtitle,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _showFormDialog(item: item),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                ),
                                const SizedBox(width: 4),
                                IconButton.filledTonal(
                                  visualDensity: VisualDensity.compact,
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.errorContainer,
                                    foregroundColor: colorScheme.onErrorContainer,
                                  ),
                                  onPressed: () => _deleteItem(item),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.config.title),
        bottom: widget.config.filterWidget,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading || _error != null || (_items?.isEmpty ?? true)
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: list),
              )
            : list,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: Text(L10nManager.l10n.addNew('')),
      ),
    );
  }
}
