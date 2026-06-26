import 'package:flutter/material.dart';
import '../../models/vo/tree_node_vo.dart';

/// Configuration for tree management
class TreeManageConfig<T> {
  final String title;
  final String Function(T) getName;
  final List<TreeNode<T>> Function() getTree;
  final Future<bool> Function(String name, String? parentId) onCreate;
  final Future<bool> Function(String id, String name) onUpdate;
  final Future<bool> Function(String id) onDelete;
  final void Function(String id, String? parentId, int sortOrder) onReorder;
  final void Function(T)? onItemTap;

  TreeManageConfig({
    required this.title,
    required this.getName,
    required this.getTree,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
    required this.onReorder,
    this.onItemTap,
  });
}

class TreeManageWidget<T> extends StatefulWidget {
  final TreeManageConfig<T> config;

  const TreeManageWidget({super.key, required this.config});

  @override
  State<TreeManageWidget<T>> createState() => _TreeManageWidgetState<T>();
}

class _TreeManageWidgetState<T> extends State<TreeManageWidget<T>> {
  final Set<String> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    final roots = widget.config.getTree();
    return ListView(
      children: [
        ..._buildNodeList(roots),
      ],
    );
  }

  List<Widget> _buildNodeList(List<TreeNode<T>> nodes) {
    final result = <Widget>[];
    for (final node in nodes) {
      result.add(_buildNodeItem(node));
      if (_expandedIds.contains(widget.config.getName(node.data))) {
        result.addAll(_buildNodeList(node.children));
      }
    }
    return result;
  }

  Widget _buildNodeItem(TreeNode<T> node) {
    final name = widget.config.getName(node.data);
    final hasChildren = node.children.isNotEmpty;
    final isExpanded = _expandedIds.contains(name);

    return Padding(
      padding: EdgeInsets.only(left: node.level * 24.0),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: ListTile(
          leading: hasChildren
              ? IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedIds.remove(name);
                      } else {
                        _expandedIds.add(name);
                      }
                    });
                  },
                )
              : const SizedBox(width: 48),
          title: Text(name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => _showAddDialog(name),
                tooltip: '添加子节点',
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showEditDialog(node.data),
                tooltip: '编辑',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _showDeleteConfirm(node.data),
                tooltip: '删除',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDialog(String? parentName) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentName == null ? '添加根节点' : '添加子节点'),
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
              final success = await widget.config.onCreate(
                  controller.text.trim(), parentName);
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(T data) {
    final controller = TextEditingController(text: widget.config.getName(data));
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
              final success = await widget.config.onUpdate('', controller.text.trim());
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(T data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定删除「${widget.config.getName(data)}」及其所有子节点？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await widget.config.onDelete('');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
