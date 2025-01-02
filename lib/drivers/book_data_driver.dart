import 'package:clsswjz/models/vo/user_book_vo.dart';

import '../enums/currency_symbol.dart';
import '../models/common.dart';

abstract class BookDataDriver {
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon});

  Future<OperateResult<void>> updateBook(String userId, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon});

  Future<OperateResult<void>> deleteBook(String userId, String bookId);

  Future<OperateResult<UserBookVO>> getBook(String userId, String bookId);

  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId);
}
