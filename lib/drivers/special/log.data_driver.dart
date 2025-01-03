import '../../manager/service_manager.dart';
import '../../models/vo/book_member_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../enums/currency_symbol.dart';
import '../../models/common.dart';
import '../book_data_driver.dart';
import 'log/builder.dart';
import '../../constants/account_book_icons.dart';

class LogDataDriver implements BookDataDriver {
  @override
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []}) async {
    final id = await LogRunnerBuilder.createBook(userId,
            name: name,
            description: description,
            currencySymbol: currencySymbol ?? CurrencySymbol.cny,
            icon: icon ?? defaultIcon())
        .execute();

    await LogRunnerBuilder.addMember(userId,
            accountBookId: id,
            userId: userId,
            canViewBook: true,
            canEditBook: true,
            canDeleteBook: true,
            canViewItem: true,
            canEditItem: true,
            canDeleteItem: true)
        .execute();
    for (var member in members) {
      await LogRunnerBuilder.addMember(userId,
              accountBookId: id,
              userId: member.userId,
              canViewBook: member.permission.canViewBook,
              canEditBook: member.permission.canEditBook,
              canDeleteBook: member.permission.canDeleteBook,
              canViewItem: member.permission.canViewItem,
              canEditItem: member.permission.canEditItem,
              canDeleteItem: member.permission.canDeleteItem)
          .execute();
    }
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteBook(String userId, String bookId) async {
    await LogRunnerBuilder.deleteBook(userId, bookId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<UserBookVO>> getBook(String userId, String bookId) {
    throw UnimplementedError();
  }

  @override
  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId) async {
    List<UserBookVO> books =
        await ServiceManager.accountBookService.getBooksByUserId(userId);
    return OperateResult.success(books);
  }

  @override
  Future<OperateResult<void>> updateBook(String userId, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []}) async {
    await LogRunnerBuilder.updateBook(userId, bookId,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            icon: icon)
        .execute();
    return OperateResult.success(null);
  }
}
