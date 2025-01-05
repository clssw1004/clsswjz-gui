import '../../enums/fund_type.dart';

class BookFundVO {
  final String id;
  final String name;
  final double balance;
  final FundType fundType;
  final String? fundRemark;
  final bool fundOut;
  final bool fundIn;

  BookFundVO({
    required this.id,
    required this.name,
    this.balance = 0.0,
    required this.fundType,
    this.fundRemark,
    this.fundOut = false,
    this.fundIn = false,
  });
}
