import 'package:drift/drift.dart';
import '../../enums/business_type.dart';
import '../../models/dto/attachment_filter_dto.dart';
import '../database.dart';
import '../tables/attachment_table.dart';
import 'base_dao.dart';

class AttachmentDao extends BaseDao<AttachmentTable, Attachment> {
  AttachmentDao(super.db);
  @override
  TableInfo<AttachmentTable, Attachment> get table => db.attachmentTable;

  Future<List<Attachment>> findByBusinessId(
      BusinessType businessType, String businessId) async {
    return (db.select(db.attachmentTable)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.businessCode.equals(businessType.code)))
        .get();
  }

  Future<void> deleteByBook(String accountBookId) async {
    try {
      final query = db.delete(table)
        ..where((t) =>
            t.businessCode.equals(BusinessType.item.code) &
            t.businessId.isInQuery(
              db.selectOnly(db.accountItemTable)
                ..addColumns([db.accountItemTable.id])
                ..where(
                    db.accountItemTable.accountBookId.equals(accountBookId)),
            ));
      await query.go();
    } catch (e, stackTrace) {
      print(stackTrace);
      rethrow;
    }
  }

  /// 分页查询附件
  Future<List<Attachment>> listByBook(
    String userId, {
    int? limit,
    int? offset,
    AttachmentFilterDTO? filter,
  }) async {
    var query = db.select(table)..where((t) => t.createdBy.equals(userId));

    // 应用筛选条件
    if (filter != null) {
      // 业务类型筛选
      if (filter.businessCode != null) {
        query = query
          ..where((t) => t.businessCode.equals(filter.businessCode!));
      }

      // 业务ID列表筛选
      if (filter.businessIds?.isNotEmpty == true) {
        query = query..where((t) => t.businessId.isIn(filter.businessIds!));
      }

      // 文件扩展名筛选
      if (filter.extensions?.isNotEmpty == true) {
        query = query..where((t) => t.extension.isIn(filter.extensions!));
      }

      // 内容类型筛选
      if (filter.contentTypes?.isNotEmpty == true) {
        query = query..where((t) => t.contentType.isIn(filter.contentTypes!));
      }

      // 文件大小范围筛选
      if (filter.minFileSize != null) {
        query = query
          ..where(
              (t) => t.fileLength.isBiggerOrEqualValue(filter.minFileSize!));
      }
      if (filter.maxFileSize != null) {
        query = query
          ..where(
              (t) => t.fileLength.isSmallerOrEqualValue(filter.maxFileSize!));
      }

      // 创建时间范围筛选
      if (filter.startDate != null) {
        query = query
          ..where((t) => t.createdAt
              .isBiggerOrEqualValue(filter.startDate!.millisecondsSinceEpoch));
      }
      if (filter.endDate != null) {
        query = query
          ..where((t) => t.createdAt
              .isSmallerOrEqualValue(filter.endDate!.millisecondsSinceEpoch));
      }

      // 文件名关键字筛选
      if (filter.fileNameKeyword != null &&
          filter.fileNameKeyword!.isNotEmpty) {
        query = query
          ..where((t) => t.originName.contains(filter.fileNameKeyword!));
      }
    }

    // 按创建时间倒序排序
    query = query..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

    // 应用分页
    if (limit != null && limit > 0) {
      query = query..limit(limit, offset: offset);
    }

    return query.get();
  }
}
