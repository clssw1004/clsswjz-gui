import 'package:clsswjz/enums/currency_symbol.dart';

import '../../constants/account_book_icons.dart';
import '../../enums/business_type.dart';
import 'log_runner.dart';

class LogRunnerBuilder {
  static CreateBookLog createBook(String who,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol = CurrencySymbol.cny,
      String? icon}) {
    return CreateBookLog().who(who).withData({
      'name': name,
      'description': description,
      'currencySymbol': currencySymbol?.symbol,
      'icon': icon ?? accountBookIcons.first.toString()
    }) as CreateBookLog;
  }

  static UpdateBookLog updateBook(String who,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon}) {
    return UpdateBookLog().who(who).withData({
      'name': name,
      'description': description,
      'currencySymbol': currencySymbol?.symbol,
      'icon': icon,
    }) as UpdateBookLog;
  }

  static DeleteLog deleteBook(
      {required String id, required String operatorId}) {
    return DeleteLog().doWith(BusinessType.book).who(operatorId).inBook(id)
        as DeleteLog;
  }
}
