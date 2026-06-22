import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/recurring_config_vo.dart';
import '../../providers/recurring_config_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/recurring_config_service.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_loading_view.dart';

/// 固定收支配置详情页
class RecurringConfigDetailPage extends StatefulWidget {
  final RecurringConfigVO config;

  const RecurringConfigDetailPage({super.key, required this.config});

  @override
  State<RecurringConfigDetailPage> createState() => _RecurringConfigDetailPageState();
}

class _RecurringConfigDetailPageState extends State<RecurringConfigDetailPage> {
  List<AccountItem>? _generatedItems;
  bool _loadingItems = false;

  @override
  void initState() {
    super.initState();
    _loadGeneratedItems();
  }

  Future<void> _loadGeneratedItems() async {
    setState(() => _loadingItems = true);
    try {
      final items = await RecurringConfigService.getGeneratedItems(widget.config.id);
      setState(() {
        _generatedItems = items;
        _loadingItems = false;
      });
    } catch (e) {
      setState(() => _loadingItems = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final config = widget.config;
    final amountColor = config.isIncome ? colorScheme.tertiary : colorScheme.error;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.recurringConfigDetail),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => _handleAction(context, v),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('编辑')),
              const PopupMenuItem(value: 'generate', child: Text('立即生成')),
              const PopupMenuItem(value: 'delete', child: Text('删除')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: spacing.contentPadding,
        children: [
          // 基本信息
          _buildSectionTitle(context, '基本信息'),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      config.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                      color: amountColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      config.isIncome ? '收入' : '支出',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '¥${config.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: spacing.listItemSpacing),
                _buildInfoRow(context, '分类', config.categoryName ?? config.categoryCode),
                _buildInfoRow(context, '账户', config.fundName ?? config.fundId),
                if (config.shopName != null)
                  _buildInfoRow(context, '商户', config.shopName!),
                if (config.description != null && config.description!.isNotEmpty)
                  _buildInfoRow(context, '备注', config.description!),
              ],
            ),
          ),
          SizedBox(height: spacing.formItemSpacing),

          // 频率信息
          _buildSectionTitle(context, L10nManager.l10n.recurringConfigFrequency),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: Column(
              children: [
                _buildInfoRow(context, '频率', config.frequencyDesc),
                _buildInfoRow(context, '开始日期', config.startDate),
                _buildInfoRow(context, '结束条件', config.endConditionDesc),
              ],
            ),
          ),
          SizedBox(height: spacing.formItemSpacing),

          // 生成统计
          _buildSectionTitle(context, '生成统计'),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: Column(
              children: [
                _buildInfoRow(context, '已生成次数', '${config.generatedCount}次'),
                if (config.lastGeneratedAt != null)
                  _buildInfoRow(context, '上次生成', config.lastGeneratedAt!),
                _buildInfoRow(context, '状态', config.isActive ? '启用' : '已停用'),
              ],
            ),
          ),
          SizedBox(height: spacing.formItemSpacing),

          // 启用/停用
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: SwitchListTile(
              title: Text(config.isActive ? '已启用' : '已停用'),
              subtitle: Text(config.isActive ? '自动生成已开启' : '自动生成已关闭'),
              value: config.isActive,
              onChanged: (v) async {
                final provider = context.read<RecurringConfigProvider>();
                await provider.toggleActive(config.id, v);
                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
          ),
          SizedBox(height: spacing.formItemSpacing),

          // 生成的账目列表
          _buildSectionTitle(context, L10nManager.l10n.recurringConfigGeneratedRecords),
          if (_loadingItems)
            const CommonLoadingView()
          else if (_generatedItems == null || _generatedItems!.isEmpty)
            CommonCardContainer(
              padding: spacing.contentPadding,
              child: Center(
                child: Text('暂无生成记录', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
            )
          else
            ...List.generate(_generatedItems!.length, (i) {
              final item = _generatedItems![i];
              return CommonCardContainer(
                padding: spacing.contentPadding,
                margin: EdgeInsets.only(bottom: spacing.formItemSpacing),
                child: ListTile(
                  leading: Icon(
                    item.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: item.type == 'income' ? colorScheme.tertiary : colorScheme.error,
                  ),
                  title: Text('¥${item.amount.toStringAsFixed(2)}'),
                  subtitle: Text(item.accountDate),
                  trailing: Text(
                    item.type == 'income' ? '收入' : '支出',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) async {
    final provider = context.read<RecurringConfigProvider>();

    switch (action) {
      case 'edit':
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.recurringConfigForm,
          arguments: widget.config,
        );
        if (result == true && context.mounted) {
          Navigator.pop(context, true);
        }
      case 'generate':
        final result = await provider.generateNow(widget.config.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result == 'generated' ? '生成成功' : result == 'skip' ? '已存在，跳过' : result)),
          );
          _loadGeneratedItems();
        }
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除此固定收支配置吗？'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除')),
            ],
          ),
        );
        if (confirm == true) {
          await provider.deleteConfig(widget.config.id);
          if (context.mounted) {
            Navigator.pop(context, true);
          }
        }
    }
  }
}
