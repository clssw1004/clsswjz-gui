import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import 'multi_select_dialog.dart';

/// 多选底部弹出面板 — 风格与 [CommonSelectFormField] 一致,支持多选 + 搜索
class MultiSelectSheet extends StatefulWidget {
  final String title;
  final List<MultiSelectOption> options;
  final List<String>? selectedIds;

  const MultiSelectSheet({
    super.key,
    required this.title,
    required this.options,
    this.selectedIds,
  });

  /// 便捷弹出入口
  static Future<List<String>?> show(BuildContext context,
      {required String title,
      required List<MultiSelectOption> options,
      List<String>? selectedIds}) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => MultiSelectSheet(
        title: title,
        options: options,
        selectedIds: selectedIds,
      ),
    );
  }

  @override
  State<MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<MultiSelectSheet> {
  late List<String> _selected;
  final _searchCtl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selectedIds ?? []);
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  List<MultiSelectOption> get _filtered => _search.isEmpty
      ? widget.options
      : widget.options
          .where((o) =>
              o.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();

  void _toggle(String key) {
    setState(() {
      _selected.contains(key) ? _selected.remove(key) : _selected.add(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l10n = L10nManager.l10n;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title,
                      style: t.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (_selected.isNotEmpty)
                  Text(
                    '${_selected.length}',
                    style: t.textTheme.labelMedium
                        ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),

          // 搜索框
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtl,
              autofocus: widget.options.length > 10,
              style: t.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon:
                    Icon(Icons.search, color: cs.primary, size: 22),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchCtl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: cs.surfaceContainerHighest.withAlpha(40),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // 分割线
          if (_filtered.isNotEmpty)
            Divider(height: 1, color: cs.outline.withAlpha(20)),

          // 列表
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 40,
                            color: cs.onSurfaceVariant.withAlpha(60)),
                        const SizedBox(height: 8),
                        Text(l10n.noData,
                            style: t.textTheme.bodyMedium
                                ?.copyWith(color: cs.onSurfaceVariant.withAlpha(100))),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    children: _filtered.map((opt) {
                      final sel = _selected.contains(opt.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                sel ? cs.primary.withAlpha(10) : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            leading: Icon(
                              sel
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 22,
                              color: sel ? cs.primary : cs.outline.withAlpha(60),
                            ),
                            title: Text(
                              opt.name,
                              style: t.textTheme.bodyMedium?.copyWith(
                                fontWeight: sel ? FontWeight.w600 : null,
                                color: sel ? cs.primary : null,
                              ),
                            ),
                            trailing: opt.icon != null
                                ? Icon(opt.icon,
                                    size: 20,
                                    color: sel
                                        ? cs.primary
                                        : cs.outline.withAlpha(60))
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onTap: () => _toggle(opt.key),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // 底部操作栏
          Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: cs.outlineVariant, width: 0.5)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Row(
              children: [
                // 清空
                TextButton(
                  onPressed: () =>
                      setState(() => _selected.clear()),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.outline,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text(l10n.clear,
                      style: t.textTheme.labelLarge
                          ?.copyWith(color: cs.outline)),
                ),
                const Spacer(),
                // 确认
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(100, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22)),
                    elevation: 0,
                  ),
                  child: Text(l10n.confirm,
                      style: t.textTheme.labelLarge
                          ?.copyWith(color: cs.onPrimary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
