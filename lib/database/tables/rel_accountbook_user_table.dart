import 'package:drift/drift.dart';
import 'package:json_annotation/json_annotation.dart';
import '../base_entity.dart';
import '../database.dart';
import 'base_table.dart';

part 'rel_accountbook_user_table.g.dart';

@UseRowClass(RelAccountbookUser)
class RelAccountbookUserTable extends BaseTable {
  TextColumn get userId => text().named('user_id')();
  TextColumn get accountBookId => text().named('account_book_id')();
  BoolColumn get canViewBook =>
      boolean().named('can_view_book').withDefault(const Constant(true))();
  BoolColumn get canEditBook =>
      boolean().named('can_edit_book').withDefault(const Constant(false))();
  BoolColumn get canDeleteBook =>
      boolean().named('can_delete_book').withDefault(const Constant(false))();
  BoolColumn get canViewItem =>
      boolean().named('can_view_item').withDefault(const Constant(true))();
  BoolColumn get canEditItem =>
      boolean().named('can_edit_item').withDefault(const Constant(false))();
  BoolColumn get canDeleteItem =>
      boolean().named('can_delete_item').withDefault(const Constant(false))();
}

@JsonSerializable()
class RelAccountbookUser extends DateEntity implements Insertable<RelAccountbookUser> {
  final String userId;
  final String accountBookId;
  final bool canViewBook;
  final bool canEditBook;
  final bool canDeleteBook;
  final bool canViewItem;
  final bool canEditItem;
  final bool canDeleteItem;

  RelAccountbookUser({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.userId,
    required this.accountBookId,
    this.canViewBook = true,
    this.canEditBook = false,
    this.canDeleteBook = false,
    this.canViewItem = true,
    this.canEditItem = false,
    this.canDeleteItem = false,
  });

  RelAccountbookUser.withBookPermission( {
    required this.userId,
    required this.accountBookId,
    this.canViewBook = true,
    this.canEditBook = false,
    this.canDeleteBook = false,
    this.canViewItem = true,
    this.canEditItem = false,
    this.canDeleteItem = false,
  }) : super.now();

  // JSON序列化方法
  factory RelAccountbookUser.fromJson(Map<String, dynamic> json) =>
      _$RelAccountbookUserFromJson(json);

  Map<String, dynamic> toJson() => _$RelAccountbookUserToJson(this);

  @override
  Map<String, Expression<Object>> toColumns(bool nullToAbsent) {
    return RelAccountbookUserTableCompanion(
      id: Value(id),
      userId: Value(userId),
      accountBookId: Value(accountBookId),
      canViewBook: Value(canViewBook),
      canEditBook: Value(canEditBook),
      canDeleteBook: Value(canDeleteBook),
      canViewItem: Value(canViewItem),
      canEditItem: Value(canEditItem),
      canDeleteItem: Value(canDeleteItem),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    ).toColumns(nullToAbsent);
  }
}
