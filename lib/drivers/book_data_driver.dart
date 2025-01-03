import 'package:clsswjz/models/vo/user_book_vo.dart';
import '../enums/currency_symbol.dart';
import '../models/common.dart';
import '../models/vo/book_member_vo.dart';

abstract class BookDataDriver {
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []});

  Future<OperateResult<void>> updateBook(String userId, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []});

  Future<OperateResult<void>> deleteBook(String userId, String bookId);

  Future<OperateResult<UserBookVO>> getBook(String userId, String bookId);

  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId);
}
