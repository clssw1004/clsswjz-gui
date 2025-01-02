import 'package:clsswjz/manager/service_manager.dart';
import 'package:clsswjz/models/vo/user_book_vo.dart';

import '../enums/currency_symbol.dart';
import '../models/common.dart';
import 'book_data_driver.dart';
import 'log/log_runner_builder.dart';

class LogDataDriver implements BookDataDriver {
  @override
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon}) async {
    final id = await LogRunnerBuilder.createBook(userId,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            icon: icon)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteBook(String userId, String bookId) async {
    await LogRunnerBuilder.deleteBook(id: bookId, operatorId: userId).execute();
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
      String? icon}) async {
    await LogRunnerBuilder.updateBook(userId,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            icon: icon)
        .execute();
    return OperateResult.success(null);
  }
}
