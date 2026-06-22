import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/recurring_config_table.dart';
import 'base_dao.dart';

/// 固定收支配置数据访问对象
class RecurringConfigDao extends BaseBookDao<RecurringConfigTable, RecurringConfig> {
  RecurringConfigDao(super.db);

  @override
  TableInfo<RecurringConfigTable, RecurringConfig> get table => db.recurringConfigTable;

  /// 查询到期需生成的配置
  /// 条件: isActive=true AND startDate <= today
  Future<List<RecurringConfig>> findActiveByNextDate(String today) async {
    final query = (db.select(table)
      ..where((t) => t.isActive.equals(true))
    );
    final results = await query.get();
    // Filter by date comparison in Dart
    return results.where((c) => c.startDate.compareTo(today) <= 0).toList();
  }

  /// 查询某账本所有配置（含过滤）
  Future<List<RecurringConfig>> findByBookWithFilter(
    String accountBookId, {
    String? type,
    bool? isActive,
    String? frequencyType,
    String? keyword,
  }) {
    final query = (db.select(table)
      ..where((t) => t.accountBookId.equals(accountBookId))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
    );
    if (type != null) {
      query.where((t) => t.type.equals(type));
    }
    if (isActive != null) {
      query.where((t) => t.isActive.equals(isActive));
    }
    if (frequencyType != null) {
      query.where((t) => t.frequencyType.equals(frequencyType));
    }
    if (keyword != null && keyword.isNotEmpty) {
      query.where((t) => t.description.contains(keyword));
    }
    return query.get();
  }

  /// 批量停用某账本所有配置
  Future<int> batchDeactivateByBook(String accountBookId) async {
    return (db.update(table)
      ..where((t) => t.accountBookId.equals(accountBookId))
    ).write(const RecurringConfigTableCompanion(
      isActive: Value(false),
    ));
  }

  /// 批量更新状态（下次生成日期和已生成次数）
  Future<void> batchUpdateStatus(List<RecurringConfigStatusUpdate> updates) async {
    await db.batch((batch) {
      for (final update in updates) {
        batch.update(
          table,
          RecurringConfigTableCompanion(
            isActive: update.isActive != null ? Value(update.isActive!) : const Value.absent(),
            generatedCount: update.generatedCount != null ? Value(update.generatedCount!) : const Value.absent(),
            lastGeneratedAt: update.lastGeneratedAt != null ? Value(update.lastGeneratedAt!) : const Value.absent(),
            updatedBy: const Value.absent(),
            updatedAt: const Value.absent(),
            accountBookId: const Value.absent(),
            id: const Value.absent(),
            type: const Value.absent(),
            amount: const Value.absent(),
            description: const Value.absent(),
            categoryCode: const Value.absent(),
            fundId: const Value.absent(),
            shopCode: const Value.absent(),
            tagCode: const Value.absent(),
            projectCode: const Value.absent(),
            frequencyType: const Value.absent(),
            frequencyValue: const Value.absent(),
            startDate: const Value.absent(),
            endType: const Value.absent(),
            endDate: const Value.absent(),
            endCount: const Value.absent(),
            createdBy: const Value.absent(),
            createdAt: const Value.absent(),
          ),
          where: (t) => t.id.equals(update.configId),
        );
      }
    });
  }

  /// 插入
  Future<void> insertConfig(RecurringConfigTableCompanion companion) async {
    await db.into(table).insert(companion);
  }
}

/// 状态更新参数
class RecurringConfigStatusUpdate {
  final String configId;
  final bool? isActive;
  final int? generatedCount;
  final String? lastGeneratedAt;

  RecurringConfigStatusUpdate({
    required this.configId,
    this.isActive,
    this.generatedCount,
    this.lastGeneratedAt,
  });
}
