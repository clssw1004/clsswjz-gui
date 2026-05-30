import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/statistics_provider.dart';
import '../../enums/account_type.dart';

/// 分类标签选择器
class CategoryTabSelector extends StatelessWidget {
  const CategoryTabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildTab(context, l10n.expense, AccountItemType.expense.code)),
          const SizedBox(width: 4),
          Expanded(child: _buildTab(context, l10n.income, AccountItemType.income.code)),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String title, String tab) {
    final theme = Theme.of(context);
    final statisticsProvider = Provider.of<StatisticsProvider>(context);
    final isSelected = statisticsProvider.selectedTab == tab;

    return GestureDetector(
      onTap: () => statisticsProvider.switchTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
