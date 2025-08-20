import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/fund_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../utils/color_util.dart';
import '../../widgets/common/common_data_list_page.dart';
import 'fund_form_page.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../routes/app_routes.dart';

/// 资金账户列表页面
class FundListPage extends StatelessWidget {
  const FundListPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return CommonDataListPage<UserFundVO>(
      config: CommonDataListPageConfig(
        title: L10nManager.l10n.tabFunds,
        onLoad: () async {
          final result = await DriverFactory.driver.listFundsByBook(AppConfigManager.instance.userId, accountBook.id);
          return result.ok ? result.data! : [];
        },
        itemBuilder: (context, item) {
          final type = item.fundType;

          return ListTile(
            leading: Icon(type.icon),
            title: Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              switch (type) {
                FundType.cash => L10nManager.l10n.fundTypeCash,
                FundType.debitCard => L10nManager.l10n.fundTypeDebitCard,
                FundType.creditCard => L10nManager.l10n.fundTypeCreditCard,
                FundType.prepaidCard => L10nManager.l10n.fundTypePrepaidCard,
                FundType.alipay => L10nManager.l10n.fundTypeAlipay,
                FundType.wechat => L10nManager.l10n.fundTypeWechat,
                FundType.debt => L10nManager.l10n.fundTypeDebt,
                FundType.investment => L10nManager.l10n.fundTypeInvestment,
                FundType.eWallet => L10nManager.l10n.fundTypeEWallet,
                FundType.other => L10nManager.l10n.fundTypeOther,
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
                    color: item.fundBalance >= 0 ? ColorUtil.INCOME : ColorUtil.EXPENSE,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(DateTime.fromMillisecondsSinceEpoch(item.createdAt)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            onTap: () async {
              // 跳转到账目列表，按账户过滤
              final filter = ItemFilterDTO(fundIds: [item.id]);
              Navigator.of(context).pushNamed(
                AppRoutes.items,
                arguments: [accountBook, filter, item.name],
              );
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
