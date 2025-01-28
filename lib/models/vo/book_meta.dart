import '../../database/database.dart';
import 'user_book_vo.dart';

class BookMetaVO extends UserBookVO {
  List<AccountFund>? funds;
  List<AccountCategory>? categories;
  List<AccountSymbol>? symbols;
  List<AccountShop>? shops;

  BookMetaVO({
    required UserBookVO bookInfo,
    this.funds = const [],
    this.categories = const [],
    this.symbols = const [],
    this.shops = const [],
  }) : super(
            id: bookInfo.id,
            name: bookInfo.name,
            currencySymbol: bookInfo.currencySymbol,
            createdBy: bookInfo.createdBy,
            createdByName: bookInfo.createdByName,
            updatedBy: bookInfo.updatedBy,
            updatedByName: bookInfo.updatedByName,
            createdAt: bookInfo.createdAt,
            updatedAt: bookInfo.updatedAt,
            permission: bookInfo.permission);
}
