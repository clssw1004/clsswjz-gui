import '../manager/database_manager.dart';
import '../manager/user_config_manager.dart';
import '../models/common.dart';
import '../models/vo/statistic_vo.dart';
import '../models/vo/user_vo.dart';

class StatisticService {
  // 统计当前用户的账本数、账目数、记账天数
  Future<OperateResult<UserStatisticVO>> getUserStatisticInfo(
      String userId) async {
    UserVO user = UserConfigManager.instance.currentUser;
    final db = DatabaseManager.db;
    // 1. 统计账本数量
    final bookCount = await (db.select(db.relAccountbookUserTable)
          ..where((tbl) => tbl.userId.equals(user.id)))
        .get()
        .then((value) => value.length);

    // 2. 统计账目数量
    final itemCount = await (db.select(db.accountItemTable)
          ..where((tbl) => tbl.createdBy.equals(user.id)))
        .get()
        .then((value) => value.length);

    // 3. 统计记账天数(根据账目创建时间去重计算)
    final days = await (db.select(db.accountItemTable)
          ..where((tbl) => tbl.createdBy.equals(user.id)))
        .get()
        .then((items) => items
            .map((e) => DateTime.fromMillisecondsSinceEpoch(e.createdAt)
                .toString()
                .split(' ')[0])
            .toSet()
            .length);

    return OperateResult.success(UserStatisticVO(
      bookCount: bookCount,
      itemCount: itemCount,
      dayCount: days,
    ));
  }
}
