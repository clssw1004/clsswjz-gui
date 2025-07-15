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
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(
                context: context,
                title: l10n.expense,
                tab: AccountItemType.expense.code,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTabButton(
                context: context,
                title: l10n.income,
                tab: AccountItemType.income.code,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTabButton({
    required BuildContext context,
    required String title,
    required String tab,
  }) {
    final theme = Theme.of(context);
    final statisticsProvider = Provider.of<StatisticsProvider>(context);
    final isSelected = statisticsProvider.selectedTab == tab;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => statisticsProvider.switchTab(tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isSelected 
                  ? theme.colorScheme.onPrimaryContainer 
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
} 