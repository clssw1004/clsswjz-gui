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
import '../../theme/theme_radius.dart';
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
          final result = await DriverFactory.driver
              .listFundsByBook(AppConfigManager.instance.userId, accountBook.id);
          return result.ok ? result.data! : [];
        },
        itemBuilder: (context, item) {
          final type = item.fundType;
          final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(radius * 1.5),
              child: InkWell(
                borderRadius: BorderRadius.circular(radius * 1.5),
                onTap: () {
                  final filter = ItemFilterDTO(fundIds: [item.id]);
                  Navigator.of(context).pushNamed(
                    AppRoutes.items,
                    arguments: [accountBook, filter, item.name],
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius * 1.5),
                    border: Border.all(color: colorScheme.outline.withAlpha(25)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // type icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(type.icon, size: 24,
                              color: colorScheme.onSecondaryContainer),
                        ),
                        const SizedBox(width: 14),
                        // name + type
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _typeLabel(type),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // balance
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              item.fundBalance.toStringAsFixed(2),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
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
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () async {
                            final r = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (context) => FundFormPage(fund: item),
                              ),
                            );
                            if (r == true) CommonDataListPage.refresh(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.edit_outlined, size: 18,
                                color: colorScheme.onSurfaceVariant.withAlpha(120)),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 20,
                            color: colorScheme.onSurfaceVariant.withAlpha(80)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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

  String _typeLabel(FundType type) {
    switch (type) {
      case FundType.cash: return L10nManager.l10n.fundTypeCash;
      case FundType.debitCard: return L10nManager.l10n.fundTypeDebitCard;
      case FundType.creditCard: return L10nManager.l10n.fundTypeCreditCard;
      case FundType.prepaidCard: return L10nManager.l10n.fundTypePrepaidCard;
      case FundType.alipay: return L10nManager.l10n.fundTypeAlipay;
      case FundType.wechat: return L10nManager.l10n.fundTypeWechat;
      case FundType.debt: return L10nManager.l10n.fundTypeDebt;
      case FundType.investment: return L10nManager.l10n.fundTypeInvestment;
      case FundType.eWallet: return L10nManager.l10n.fundTypeEWallet;
      case FundType.other: return L10nManager.l10n.fundTypeOther;
    }
  }

}
