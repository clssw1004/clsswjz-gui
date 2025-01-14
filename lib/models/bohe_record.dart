class BoheRecord {
  final String type; // 类型
  final String currency; // 货币
  final double amount; // 金额
  final double exchangeRate; // 汇率
  final String project; // 项目
  final String category; // 分类
  final String parentCategory; // 父类
  final String account; // 账户
  final String payment; // 付款
  final String receipt; // 收款
  final String merchant; // 商家
  final String address; // 地址
  final DateTime date; // 日期
  final String tag; // 标签
  final String author; // 作者
  final String description; // 备注
  final String image1; // 图一
  final String image2; // 图二
  final String image3; // 图三

  BoheRecord({
    required this.type,
    required this.currency,
    required this.amount,
    required this.exchangeRate,
    required this.project,
    required this.category,
    required this.parentCategory,
    required this.account,
    required this.payment,
    required this.receipt,
    required this.merchant,
    required this.address,
    required this.date,
    required this.tag,
    required this.author,
    required this.description,
    required this.image1,
    required this.image2,
    required this.image3,
  });

  factory BoheRecord.fromCsv(List<String> row) {
    return BoheRecord(
      type: row[0],
      currency: row[1],
      amount: double.tryParse(row[2]) ?? 0.0,
      exchangeRate: double.tryParse(row[3]) ?? 1.0,
      project: row[4],
      category: row[5],
      parentCategory: row[6],
      account: row[7],
      payment: row[8],
      receipt: row[9],
      merchant: row[10],
      address: row[11],
      date: DateTime.tryParse(row[12].replaceAll(' ', 'T')) ?? DateTime.now(),
      tag: row[13],
      author: row[14],
      description: row[15],
      image1: row[16],
      image2: row[17],
      image3: row[18],
    );
  }
}
