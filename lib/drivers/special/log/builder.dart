import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/enums/currency_symbol.dart';
import 'package:drift/drift.dart';

import '../../../constants/account_book_icons.dart';
import '../../../database/tables/account_book_table.dart';
import '../../../database/tables/rel_accountbook_user_table.dart';
import '../../../enums/business_type.dart';
import '../../../models/vo/book_member_vo.dart';
import '../../../utils/date_util.dart';
import 'builder/book.builder.dart';
import 'builder/book_member.builder.dart';

class LogRunnerBuilder {
  static Value<T> absentIfNull<T>(T? value) {
    return value != null ? Value(value) : const Value.absent();
  }

  static CreateBookLog createBook(String who,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol = CurrencySymbol.cny,
      String? icon}) {
    return CreateBookLog().who(who).withData(AccountBookTable.toCreateCompanion(
        who,
        name: name,
        description: description,
        currencySymbol: currencySymbol?.symbol ?? CurrencySymbol.cny.symbol,
        icon: icon)) as CreateBookLog;
  }

  static UpdateBookLog updateBook(String who, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO>? members}) {
    return UpdateBookLog().inBook(bookId).who(who).withData(
        AccountBookTable.toUpdateCompanion(who,
            name: name,
            description: description,
            currencySymbol: currencySymbol?.symbol ?? CurrencySymbol.cny.symbol,
            icon: icon)) as UpdateBookLog;
  }

  static DeleteLog deleteBook(String who, String bookId) {
    return DeleteLog().who(who).doWith(BusinessType.book).inBook(bookId)
        as DeleteLog;
  }

  static CreateMemberLog addMember(String who,
      {required String accountBookId,
      required String userId,
      bool canViewBook = true,
      bool canEditBook = false,
      bool canDeleteBook = false,
      bool canViewItem = true,
      bool canEditItem = false,
      bool canDeleteItem = false}) {
    return CreateMemberLog().who(who).inBook(accountBookId).withData(
        RelAccountbookUserTable.toCreateCompanion(
            accountBookId: accountBookId,
            userId: userId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem)) as CreateMemberLog;
  }
}
