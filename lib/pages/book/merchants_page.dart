import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/provider_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/shop_provider.dart';
import '../../routes/app_routes.dart';

class MerchantsPage extends StatefulWidget {
  const MerchantsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  State<MerchantsPage> createState() => _MerchantsPageState();
}

class _MerchantsPageState extends State<MerchantsPage> {
  ShopProvider get _provider => ProviderManager.shopProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadTree(widget.accountBook.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(L10nManager.l10n.merchant)),
          body: _provider.tree.isEmpty
              ? const Center(child: Text('暂无商户'))
              : _buildTreeView(),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => _showAddDialog(null),
          ),
        );
      },
    );
  }

  Widget _buildTreeView() {
    final flattened = TreeBuilder.flatten(_provider.tree);
    return ListView.builder(
      itemCount: flattened.length,
      itemBuilder: (context, index) {
        final node = flattened[index];
        final hasChildren = node.children.isNotEmpty;
        return Padding(
          padding: EdgeInsets.only(left: node.level * 24.0),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: ListTile(
              leading: hasChildren
                  ? IconButton(
                      icon: Icon(
                        _provider.expandedIds.contains(node.data.id)
                            ? Icons.expand_more
                            : Icons.chevron_right,
                      ),
                      onPressed: () =>
                          _provider.toggleExpand(node.data.id),
                    )
                  : const SizedBox(width: 48),
              title: Text(node.data.name),
              subtitle: Text('#${node.data.code}'),
              onTap: () {
                final filter = ItemFilterDTO(
                  shopCodes: _provider.expandCodes(node.data.code),
                );
                Navigator.of(context).pushNamed(
                  AppRoutes.items,
                  arguments: [
                    widget.accountBook,
                    filter,
                    node.data.name,
                  ],
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    onPressed: () => _showAddDialog(node.data.id),
                    tooltip: '添加子商户',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showEditDialog(node.data),
                    tooltip: '编辑',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _confirmDelete(node.data),
                    tooltip: '删除',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(String? parentId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentId == null ? '添加商户' : '添加子商户'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final result = await _provider.create(
                name: controller.text.trim(),
                parentId: parentId,
              );
              if (result.ok && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(AccountShop shop) {
    final controller = TextEditingController(text: shop.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final result = await _provider.update(
                shop.id,
                name: controller.text.trim(),
              );
              if (result.ok && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(AccountShop shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定删除「${shop.name}」及其所有子商户？\n此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final result = await _provider.delete(shop.id);
              if (result.ok && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
