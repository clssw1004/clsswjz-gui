import '../../database/database.dart';

/// 账目视图对象
class UserItemVO {
  /// ID
  final String id;

  /// 金额
  double amount;

  /// 描述
  String? description;

  /// 类型
  String type;

  /// 分类代码
  String? categoryCode;

  /// 账目日期时间（格式：yyyy-MM-dd HH:mm:ss）
  String accountDate;

  /// 账目日期（格式：yyyy-MM-dd）
  String get accountDateOnly => accountDate.split(' ')[0];

  /// 账目时间（格式：HH:mm:ss）
  String get accountTimeOnly {
    final time = accountDate.split(' ');
    if (time.length > 1) {
      return time[1].substring(0, 5);
    }
    return '00:00';
  }

  /// 账本ID
  String accountBookId;

  /// 资金账户ID
  String? fundId;

  /// 商家代码
  String? shopCode;

  /// 标签代码
  String? tagCode;

  /// 项目代码
  String? projectCode;

  /// 创建人ID
  final String createdBy;

  /// 更新人ID
  String updatedBy;

  /// 创建时间
  final int createdAt;

  /// 更新时间
  int updatedAt;

  /// 分类名称
  String? categoryName;

  /// 账户名称
  String? fundName;

  /// 商户名称
  String? shopName;

  /// 标签名称
  String? tagName;

  /// 项目名称
  String? projectName;

  /// 创建人姓名
  final String? createdByName;

  /// 更新人姓名
  String? updatedByName;

  /// 创建时间（格式化）
  final String createdAtString;

  /// 更新时间（格式化）
  String updatedAtString;

  /// 账目来源
  String? source;

  /// 账目来源ID
  String? sourceId;

  UserItemVO({
    required this.id,
    required this.amount,
    this.description,
    required this.type,
    this.categoryCode,
    required this.accountDate,
    required this.accountBookId,
    this.fundId,
    this.shopCode,
    this.tagCode,
    this.projectCode,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.fundName,
    this.shopName,
    this.tagName,
    this.projectName,
    this.createdByName,
    this.updatedByName,
    required this.createdAtString,
    required this.updatedAtString,
    this.source,
    this.sourceId,
  });

  /// 从账目对象创建视图对象
  static UserItemVO fromAccountItem({
    required AccountItem item,
    String? categoryName,
    String? fundName,
    String? shopName,
    String? tagName,
    String? projectName,
    String? createdByName,
    String? updatedByName,
  }) {
    return UserItemVO(
      id: item.id,
      amount: item.amount,
      description: item.description,
      type: item.type,
      categoryCode: item.categoryCode,
      accountDate: item.accountDate,
      accountBookId: item.accountBookId,
      fundId: item.fundId,
      shopCode: item.shopCode,
      tagCode: item.tagCode,
      projectCode: item.projectCode,
      createdBy: item.createdBy,
      updatedBy: item.updatedBy,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      categoryName: categoryName,
      fundName: fundName,
      shopName: shopName,
      tagName: tagName,
      projectName: projectName,
      createdByName: createdByName,
      updatedByName: updatedByName,
      source: item.source,
      sourceId: item.sourceId,
      createdAtString: _formatTimestamp(item.createdAt),
      updatedAtString: _formatTimestamp(item.updatedAt),
    );
  }

  static AccountItem toAccountItem(UserItemVO vo) {
    return AccountItem(
      id: vo.id,
      amount: vo.amount,
      description: vo.description,
      type: vo.type,
      categoryCode: vo.categoryCode,
      accountDate: vo.accountDate,
      accountBookId: vo.accountBookId,
      fundId: vo.fundId,
      shopCode: vo.shopCode,
      tagCode: vo.tagCode,
      projectCode: vo.projectCode,
      createdBy: vo.createdBy,
      updatedBy: vo.updatedBy,
      createdAt: vo.createdAt,
      updatedAt: vo.updatedAt,
    );
  }

  void setCategory(AccountCategory category) {
    categoryName = category.name;
    categoryCode = category.code;
  }

  void setFund(AccountFund fund) {
    fundName = fund.name;
    fundId = fund.id;
  }

  void setShop(AccountShop shop) {
    shopName = shop.name;
    shopCode = shop.code;
  }

  void setTag(AccountSymbol tag) {
    tagName = tag.name;
    tagCode = tag.code;
  }

  void setProject(AccountSymbol project) {
    projectName = project.name;
    projectCode = project.code;
  }

  /// 格式化时间戳
  static String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.year}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// 创建一个新的实例，只更新指定的属性
  UserItemVO copyWith({
    String? id,
    double? amount,
    String? description,
    String? type,
    String? categoryCode,
    String? categoryName,
    String? accountDate,
    String? accountBookId,
    String? fundId,
    String? fundName,
    String? shopCode,
    String? shopName,
    String? tagCode,
    String? tagName,
    String? projectCode,
    String? projectName,
    String? createdBy,
    String? updatedBy,
    int? createdAt,
    int? updatedAt,
    String? createdByName,
    String? updatedByName,
    String? createdAtString,
    String? updatedAtString,
  }) {
    return UserItemVO(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      accountDate: accountDate ?? this.accountDate,
      accountBookId: accountBookId ?? this.accountBookId,
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      shopCode: shopCode ?? this.shopCode,
      shopName: shopName ?? this.shopName,
      tagCode: tagCode ?? this.tagCode,
      tagName: tagName ?? this.tagName,
      projectCode: projectCode ?? this.projectCode,
      projectName: projectName ?? this.projectName,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByName: createdByName ?? this.createdByName,
      updatedByName: updatedByName ?? this.updatedByName,
      createdAtString: createdAtString ?? this.createdAtString,
      updatedAtString: updatedAtString ?? this.updatedAtString,
    );
  }

  /// 更新账目日期时间
  void updateDateTime(String date, String time) {
    accountDate = '$date $time';
  }
}
