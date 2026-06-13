import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import 'common_app_bar.dart';

/// 通用数据列表页面配置
class CommonDataListPageConfig<T> {
  /// 页面标题
  final String title;

  /// 数据加载方法
  final Future<List<T>> Function() onLoad;

  /// 项目构建器
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// 添加按钮点击事件
  final VoidCallback? onAdd;

  /// 空数据提示文本（默认使用 l10n.noData）
  final String? emptyText;

  /// 空数据图标
  final IconData? emptyIcon;

  const CommonDataListPageConfig({
    required this.title,
    required this.onLoad,
    required this.itemBuilder,
    this.onAdd,
    this.emptyText,
    this.emptyIcon,
  });
}

/// 通用数据列表页面
class CommonDataListPage<T> extends StatefulWidget {
  /// 页面配置
  final CommonDataListPageConfig<T> config;

  const CommonDataListPage({
    super.key,
    required this.config,
  });

  @override
  State<CommonDataListPage<T>> createState() => _CommonDataListPageState<T>();

  /// 刷新列表数据
  static void refresh(BuildContext context) {
    final state = context.findAncestorStateOfType<_CommonDataListPageState>();
    state?._loadData();
  }
}

class _CommonDataListPageState<T> extends State<CommonDataListPage<T>> {
  List<T>? _items;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await widget.config.onLoad();
      if (mounted) {
        setState(() {
          _loading = false;
          _items = items;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(title: Text(widget.config.title)),
      body: _loading
          ? _buildLoading()
          : _error != null
              ? _buildError(theme, colorScheme)
              : _items?.isEmpty == true
                  ? _buildEmpty(theme, colorScheme)
                  : _buildList(),
      floatingActionButton: widget.config.onAdd != null
          ? FloatingActionButton(
              onPressed: widget.config.onAdd,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(60),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 12, width: 160, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 100, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.error_outline_rounded, size: 32, color: colorScheme.error),
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(L10nManager.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                widget.config.emptyIcon ?? Icons.inbox_outlined,
                size: 36,
                color: colorScheme.onSurfaceVariant.withAlpha(100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.config.emptyText ?? L10nManager.l10n.noData,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.config.onAdd != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: widget.config.onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(L10nManager.l10n.addNew(widget.config.title)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items?.length ?? 0,
        itemBuilder: (context, index) {
          return widget.config.itemBuilder(context, _items![index]);
        },
      ),
    );
  }
}
