import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../enums/fund_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../widgets/common/common_data_list_page.dart';
import 'fund_form_page.dart';

/// 资金账户列表页面
class FundListPage extends StatelessWidget {
  const FundListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonDataListPage<UserFundVO>(
      config: CommonDataListPageConfig(
        title: l10n.tabFunds,
        onLoad: () async {
          final result = await ServiceManager.accountFundService
              .getFundsByUser(AppConfigManager.instance.userId!);
          return result.ok ? result.data! : [];
        },
        itemBuilder: (context, item) {
          final type = item.fundType;

          // 获取默认账本
          final defaultBook = item.relatedBooks
              .where((book) => book.isDefault)
              .firstOrNull;

          return ListTile(
            leading: Icon(
              switch (type) {
                FundType.cash => Icons.payments_outlined,
                FundType.debitCard => Icons.credit_card_outlined,
                FundType.creditCard => Icons.credit_score_outlined,
                FundType.prepaidCard => Icons.card_giftcard_outlined,
                FundType.alipay => Icons.account_balance_wallet_outlined,
                FundType.wechat => Icons.chat_outlined,
                FundType.debt => Icons.money_off_outlined,
                FundType.investment => Icons.trending_up_outlined,
                FundType.eWallet => Icons.account_balance_wallet_outlined,
                FundType.other => Icons.account_balance_outlined,
              },
            ),
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.balance}: ${item.fundBalance}',
                  style: theme.textTheme.bodySmall,
                ),
                if (defaultBook != null)
                  Text(
                    '${l10n.defaultBook}: ${defaultBook.name}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            trailing: Text(
              switch (type) {
                FundType.cash => l10n.fundTypeCash,
                FundType.debitCard => l10n.fundTypeDebitCard,
                FundType.creditCard => l10n.fundTypeCreditCard,
                FundType.prepaidCard => l10n.fundTypePrepaidCard,
                FundType.alipay => l10n.fundTypeAlipay,
                FundType.wechat => l10n.fundTypeWechat,
                FundType.debt => l10n.fundTypeDebt,
                FundType.investment => l10n.fundTypeInvestment,
                FundType.eWallet => l10n.fundTypeEWallet,
                FundType.other => l10n.fundTypeOther,
              },
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FundFormPage(fund: item),
                ),
              );
            },
          );
        },
        onAdd: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FundFormPage(),
            ),
          );
        },
      ),
    );
  }
} 