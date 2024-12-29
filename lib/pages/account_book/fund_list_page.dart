import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../enums/fund_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../utils/color_util.dart';
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
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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
            title: Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
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
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.fundBalance.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: item.fundBalance >= 0
                        ? ColorUtil.INCOME
                        : ColorUtil.EXPENSE,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(item.createdAt)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FundFormPage(fund: item),
                ),
              );
              if (result == true) {
                CommonDataListPage.refresh(context);
              }
            },
          );
        },
        onAdd: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FundFormPage(),
            ),
          );
          if (result == true) {
            CommonDataListPage.refresh(context);
          }
        },
      ),
    );
  }
}
