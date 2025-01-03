import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../utils/date_util.dart';
import '../base_entity.dart';
import '../database.dart';
import 'base_table.dart';

part 'account_book_table.g.dart';

@UseRowClass(AccountBook)
class AccountBookTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get currencySymbol =>
      text().named('currency_symbol').withDefault(const Constant('¥'))();
  TextColumn get icon => text().nullable().named('icon')();
}

@JsonSerializable()
class AccountBook extends BaseEntity implements Insertable<AccountBook> {
  String name;
  String? description;
  String currencySymbol;
  String? icon;

  AccountBook({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    required super.updatedBy,
    required this.name,
    this.description,
    required this.currencySymbol,
    this.icon,
  });

  AccountBook.withUser(
    super.userId, {
    required this.name,
    this.description,
    required this.currencySymbol,
    this.icon,
  }) : super.withUser();


  // JSON序列化方法
  factory AccountBook.fromJson(Map<String, dynamic> json) =>
      _$AccountBookFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBookToJson(this);

  AccountBook copyWithUpdate(
    String who, {
    String? name,
    String? description,
    String? currencySymbol,
    String? icon,
  }) =>
      AccountBook(
        id: id,
        createdAt: createdAt,
        createdBy: createdBy,
        updatedBy: who,
        updatedAt: DateUtil.now(),
        name: name ?? this.name,
        description: description ?? this.description,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        icon: icon ?? this.icon,
      );

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return AccountBookTableCompanion(
      id: nullIfAbsent(id),
      name: nullIfAbsent(name),
      description: nullIfAbsent(description),
      currencySymbol: nullIfAbsent(currencySymbol),
      icon: nullIfAbsent(icon),
      createdAt: nullIfAbsent(createdAt),
      createdBy: nullIfAbsent(createdBy),
      updatedAt: nullIfAbsent(updatedAt),
      updatedBy: nullIfAbsent(updatedBy),
    ).toColumns(nullToAbsent);
  }
}
