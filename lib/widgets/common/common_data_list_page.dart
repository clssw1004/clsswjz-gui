import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  const CommonDataListPageConfig({
    required this.title,
    required this.onLoad,
    required this.itemBuilder,
    this.onAdd,
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
  /// 数据列表
  List<T>? _items;

  /// 是否正在加载
  bool _loading = false;

  /// 错误信息
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载数据
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

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.config.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
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
                        return widget.config.itemBuilder(context, _items![index]);
                      },
                    ),
      floatingActionButton: widget.config.onAdd != null
          ? FloatingActionButton(
              onPressed: widget.config.onAdd,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
