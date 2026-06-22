import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/recurring_config_vo.dart';
import '../../providers/books_provider.dart';
import '../../providers/recurring_config_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_bottom_sheet.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_empty_view.dart';
import '../../widgets/common/common_loading_view.dart';
import '../../models/vo/user_book_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';

/// 固定收支配置列表页
class RecurringConfigListPage extends StatefulWidget {
  const RecurringConfigListPage({super.key});

  @override
  State<RecurringConfigListPage> createState() => _RecurringConfigListPageState();
}

class _RecurringConfigListPageState extends State<RecurringConfigListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() async {
    if (!mounted) return;
    final provider = context.read<RecurringConfigProvider>();
    final booksProvider = context.read<BooksProvider>();
    final bookId = booksProvider.selectedBook?.id;
    if (bookId != null) {
      await provider.loadConfigs(bookId);
      if (!mounted) return;
      // 检查到期记录
      await provider.checkDueGenerations(bookId: bookId);
      if (!mounted) return;
      await provider.loadConfigs(bookId);
    }
  }

  String? get _currentBookId {
    return context.read<BooksProvider>().selectedBook?.id;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.recurringConfigList),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: L10nManager.l10n.recurringConfigCopy,
            onPressed: _showCopyDialog,
          ),
        ],
      ),
      body: Consumer<RecurringConfigProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.configs.isEmpty) {
            return const CommonLoadingView();
          }
          if (provider.error != null && provider.configs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!, style: TextStyle(color: colorScheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text(L10nManager.l10n.retry),
                  ),
                ],
              ),
            );
          }
          if (provider.configs.isEmpty) {
            return CommonEmptyView(
              message: L10nManager.l10n.emptyRecurringConfigs,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final bookId = _currentBookId;
              if (bookId != null) {
                await provider.loadConfigs(bookId);
              }
            },
            child: ListView.builder(
              padding: spacing.listPadding,
              itemCount: provider.configs.length,
              itemBuilder: (context, index) {
                final config = provider.configs[index];
                return _buildConfigCard(context, config, provider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bookId = _currentBookId;
          if (bookId == null) return;
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.recurringConfigForm,
            arguments: {'bookId': bookId},
          );
          if (result == true) {
            context.read<RecurringConfigProvider>().loadConfigs(bookId);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context, RecurringConfigVO config, RecurringConfigProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    final amountColor = config.isIncome ? colorScheme.tertiary : colorScheme.error;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
      child: CommonCardContainer(
        padding: spacing.contentPadding,
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.recurringConfigDetail,
            arguments: config,
          ).then((_) {
            final bookId = _currentBookId;
            if (bookId != null) provider.loadConfigs(bookId);
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  config.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: amountColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  config.categoryName ?? config.categoryCode,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${config.isIncome ? '+' : '-'}¥${config.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.listItemSpacing),
            Row(
              children: [
                Icon(Icons.repeat, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  config.frequencyDesc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                if (config.fundName != null)
                  Text(
                    config.fundName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            SizedBox(height: spacing.listItemSpacing),
            Row(
              children: [
                if (config.lastGeneratedAt != null) ...[
                  Icon(Icons.check_circle_outline, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(L10nManager.l10n.recurringConfigGeneratedCount(config.generatedCount), style: theme.textTheme.bodySmall),
                ] else
                  Text('待生成', style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
                const Spacer(),
                Switch(
                  value: config.isActive,
                  onChanged: (v) {
                    provider.toggleActive(config.id, v, bookId: _currentBookId);
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(context, config, provider, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('编辑')),
                    const PopupMenuItem(value: 'generate', child: Text('立即生成')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, RecurringConfigVO config, RecurringConfigProvider provider, String action) async {
    switch (action) {
      case 'edit':
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.recurringConfigForm,
          arguments: {'config': config, 'bookId': _currentBookId},
        );
        if (result == true) {
          final bookId = _currentBookId;
          if (bookId != null) provider.loadConfigs(bookId);
        }
      case 'generate':
        final result = await provider.generateNow(config.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result == 'generated' ? '生成成功' : result == 'skip' ? '已存在，跳过' : result)),
          );
          final bookId = _currentBookId;
          if (bookId != null) provider.loadConfigs(bookId);
        }
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(L10nManager.l10n.recurringConfigConfirmDelete),
            content: Text(L10nManager.l10n.recurringConfigDeleteConfirmMsg),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(L10nManager.l10n.cancel)),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(L10nManager.l10n.delete(''))),
            ],
          ),
        );
        if (confirm == true) {
          await provider.deleteConfig(config.id, bookId: _currentBookId);
        }
    }
  }

  void _showCopyDialog() {
    final booksProvider = context.read<BooksProvider>();
    final books = booksProvider.books.where((b) => b.id != _currentBookId).toList();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => CommonBottomSheet(
        title: L10nManager.l10n.recurringConfigCopy,
        child: books.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(L10nManager.l10n.recurringConfigCopySourceEmpty),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: books.map((book) => ListTile(
                  leading: Icon(book.icon != null ? Icons.book : Icons.book_outlined),
                  title: Text(book.name),
                  onTap: () {
                    Navigator.pop(ctx);
                    _doCopy(book);
                  },
                )).toList(),
              ),
      ),
    );
  }

  void _doCopy(UserBookVO sourceBook) async {
    // Load source book configs
    final provider = context.read<RecurringConfigProvider>();
    final result = await DriverFactory.driver.listRecurringConfigsWithNames(
      AppConfigManager.instance.userId,
      sourceBook.id,
    );
    if (!result.ok || result.data == null || result.data!.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10nManager.l10n.recurringConfigCopySourceEmpty)),
        );
      }
      return;
    }

    final sourceConfigs = result.data!;
    final selectedIds = <String>{};
    bool deactivateOrigin = false;

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => CommonBottomSheet(
          title: L10nManager.l10n.recurringConfigCopySelect,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sourceConfigs.length,
                  itemBuilder: (ctx, i) {
                    final c = sourceConfigs[i];
                    final isSelected = selectedIds.contains(c.id);
                    return CheckboxListTile(
                      title: Text('${c.isIncome ? L10nManager.l10n.income : L10nManager.l10n.expense} ¥${c.amount.toStringAsFixed(2)}'),
                      subtitle: Text('${c.categoryName ?? c.categoryCode} · ${c.frequencyDesc}'),
                      value: isSelected,
                      onChanged: (v) {
                        setSheetState(() {
                          if (v == true) {
                            selectedIds.add(c.id);
                          } else {
                            selectedIds.remove(c.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              CheckboxListTile(
                title: Text(L10nManager.l10n.recurringConfigDeactivateOrigin),
                value: deactivateOrigin,
                onChanged: (v) => setSheetState(() => deactivateOrigin = v ?? false),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: selectedIds.isEmpty ? null : () async {
                    Navigator.pop(ctx);
                    final targetBookId = _currentBookId;
                    if (targetBookId == null) return;

                    final copyResult = await provider.copyFromBook(
                      sourceBook.id, targetBookId, selectedIds.toList(),
                      deactivateOrigin: deactivateOrigin,
                    );

                    if (context.mounted) {
                      await provider.loadConfigs(targetBookId);
                      if (copyResult.failCount > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                            L10nManager.l10n.recurringConfigCopyPartial(copyResult.successCount, copyResult.failCount)
                          )),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                            L10nManager.l10n.recurringConfigCopySuccess(copyResult.successCount)
                          )),
                        );
                      }
                    }
                  },
                  child: Text(L10nManager.l10n.recurringConfigCopyConfirm(selectedIds.length.toString())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
