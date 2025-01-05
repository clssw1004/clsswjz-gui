import 'package:clsswjz/manager/dao_manager.dart';
import 'package:drift/drift.dart';
import '../database/tables/account_book_table.dart';
import '../models/common.dart';
import '../models/sync.dart';
import '../utils/http_client.dart';
import 'base_service.dart';

/// 数据同步服务
class SyncService extends BaseService {
  final HttpClient _httpClient;

  SyncService({required HttpClient httpClient}) : _httpClient = httpClient;

  Future<OperateResult<int>> syncInit() async {
    final result = await _getInitialData();
    if (result.ok && result.data != null) {
      await _applyServerChanges(result.data!.data);
    }
    return OperateResult.success(result.data!.lasySyncTime);
  }

  /// 批量同步数据
  Future<OperateResult<SyncResponse>> syncChange(int lastSyncTime) async {
    try {
      final changes = await getLocalChanges(lastSyncTime);
      final data = SyncDataDto(
        lastSyncTime: lastSyncTime,
        changes: changes,
      );
      final response = await _httpClient.post<SyncResponse>(
        path: '/api/sync/batch',
        data: data.toJson(),
        transform: (json) => SyncResponse.fromJson(json['data']),
      );

      if (response.success) {
        return OperateResult.success(response.data!);
      } else {
        return OperateResult.failWithMessage(
          message: response.message ?? '同步数据失败',
        );
      }
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '同步数据失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取初始数据
  Future<OperateResult<SyncInitResponse>> _getInitialData() async {
    final response = await _httpClient.get<SyncInitResponse>(
      path: '/api/sync/initial',
      transform: (json) => SyncInitResponse.fromJson(json['data']),
    );

    if (response.success) {
      return OperateResult.success(response.data!);
    } else {
      return OperateResult.failWithMessage(
        message: response.message ?? '获取初始数据失败',
        exception:
            response.message != null ? Exception(response.message) : null,
      );
    }
  }

  /// 应用服务器变更
  Future<void> _applyServerChanges(SyncChanges changes) async {
    await db.transaction(() async {
      if (changes.users != null) {
        await batchInsert(db.userTable, changes.users!);
      }
      // 应用账本变更
      if (changes.accountBooks != null) {
        await DaoManager.accountBookDao.batchInsert(changes.accountBooks!);
      }

      // 应用分类变更
      if (changes.accountCategories != null) {
        await DaoManager.accountCategoryDao
            .batchInsert(changes.accountCategories!);
      }

      // 应用账目变更
      if (changes.accountItems != null) {
        await DaoManager.accountItemDao.batchInsert(changes.accountItems!);
      }

      // 应用商家变更
      if (changes.accountShops != null) {
        await DaoManager.accountShopDao.batchInsert(changes.accountShops!);
      }

      // 应用标签变更
      if (changes.accountSymbols != null) {
        await DaoManager.accountSymbolDao.batchInsert(changes.accountSymbols!);
      }

      // 应用资金账户变更
      if (changes.accountFunds != null) {
        await DaoManager.accountFundDao.batchInsert(changes.accountFunds!);
      }

      // 应用账本资金账户关联变更
      if (changes.accountBookFunds != null) {
        await DaoManager.relAccountbookFundDao
            .batchInsert(changes.accountBookFunds!);
      }

      // 应用账本用户关联变更
      if (changes.accountBookUsers != null) {
        await DaoManager.relAccountbookUserDao
            .batchInsert(changes.accountBookUsers!);
      }
    });
  }

  /// 处理冲突
  Future<void> handleConflicts(SyncChanges conflicts) async {
    // TODO: 根据业务需求实现冲突处理逻辑
    // 1. 可以选择保留服务器版本
    // 2. 可以选择合并数据
    // 3. 可以让用户选择处理方式
  }

  /// 获取本地变更
  Future<SyncChanges> getLocalChanges(int timestamp) async {
    return SyncChanges(
      accountBooks: await (db.select(db.accountBookTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
      accountCategories: await (db.select(db.accountCategoryTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
      accountItems: await (db.select(db.accountItemTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
      accountShops: await (db.select(db.accountShopTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
      accountSymbols: await (db.select(db.accountSymbolTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
      accountFunds: await (db.select(db.accountFundTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
      accountBookFunds: await (db.select(db.relAccountbookFundTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
      accountBookUsers: await (db.select(db.relAccountbookUserTable)
            ..where((t) => t.updatedAt.isBiggerThan(Variable(timestamp))))
          .get(),
    );
  }
}
