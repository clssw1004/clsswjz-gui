import '../database/database.dart';
import '../database/tables/account_book_table.dart';
import '../database/tables/rel_accountbook_user_table.dart';

/// 同步数据传输对象
class SyncDataDto {
  final int lastSyncTime;
  final SyncChanges changes;

  SyncDataDto({
    required this.lastSyncTime,
    required this.changes,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastSyncTime': lastSyncTime,
      'changes': changes.toJson(),
    };
  }

  factory SyncDataDto.fromJson(Map<String, dynamic> json) {
    return SyncDataDto(
      lastSyncTime: json['lastSyncTime'] as int,
      changes: SyncChanges.fromJson(json['changes'] as Map<String, dynamic>),
    );
  }
}

/// 同步变更数据
class SyncChanges {
  final List<User>? users;
  final List<AccountBook>? accountBooks;
  final List<AccountCategory>? accountCategories;
  final List<AccountItem>? accountItems;
  final List<AccountShop>? accountShops;
  final List<AccountSymbol>? accountSymbols;
  final List<AccountFund>? accountFunds;
  final List<RelAccountbookFund>? accountBookFunds;
  final List<RelAccountbookUser>? accountBookUsers;

  SyncChanges({
    this.users,
    this.accountBooks,
    this.accountCategories,
    this.accountItems,
    this.accountShops,
    this.accountSymbols,
    this.accountFunds,
    this.accountBookFunds,
    this.accountBookUsers,
  });

  Map<String, dynamic> toJson() {
    return {
      if (users != null) 'users': users!.map((e) => e.toJson()).toList(),
      if (accountBooks != null)
        'accountBooks': accountBooks!.map((e) => e.toJson()).toList(),
      if (accountCategories != null)
        'accountCategories': accountCategories!.map((e) => e.toJson()).toList(),
      if (accountItems != null)
        'accountItems': accountItems!.map((e) => e.toJson()).toList(),
      if (accountShops != null)
        'accountShops': accountShops!.map((e) => e.toJson()).toList(),
      if (accountSymbols != null)
        'accountSymbols': accountSymbols!.map((e) => e.toJson()).toList(),
      if (accountFunds != null)
        'accountFunds': accountFunds!.map((e) => e.toJson()).toList(),
      if (accountBookFunds != null)
        'accountBookFunds': accountBookFunds!.map((e) => e.toJson()).toList(),
      if (accountBookUsers != null)
        'accountBookUsers': accountBookUsers!.map((e) => e.toJson()).toList(),
    };
  }

  factory SyncChanges.fromJson(Map<String, dynamic> json) {
    return SyncChanges(
      users: (json['users'] as List<dynamic>?)
          ?.map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountBooks: (json['accountBooks'] as List<dynamic>?)
          ?.map((e) => AccountBook.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountCategories: (json['accountCategories'] as List<dynamic>?)
          ?.map((e) => AccountCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountItems: (json['accountItems'] as List<dynamic>?)
          ?.map((e) => AccountItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountShops: (json['accountShops'] as List<dynamic>?)
          ?.map((e) => AccountShop.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountSymbols: (json['accountSymbols'] as List<dynamic>?)
          ?.map((e) => AccountSymbol.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountFunds: (json['accountFunds'] as List<dynamic>?)
          ?.map((e) => AccountFund.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountBookFunds: (json['accountBookFunds'] as List<dynamic>?)
          ?.map((e) => RelAccountbookFund.fromJson(e as Map<String, dynamic>))
          .toList(),
      accountBookUsers: (json['accountBookUsers'] as List<dynamic>?)
          ?.map((e) => RelAccountbookUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SyncInitResponse {
  SyncChanges data;
  int lasySyncTime;

  SyncInitResponse({
    required this.data,
    required this.lasySyncTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'serverTime': lasySyncTime,
    };
  }

  factory SyncInitResponse.fromJson(Map<String, dynamic> json) {
    return SyncInitResponse(
      data: SyncChanges.fromJson(json['data'] as Map<String, dynamic>),
      lasySyncTime: json['lasySyncTime'] as int,
    );
  }
}

/// 同步响应数据
class SyncResponse {
  final SyncChanges serverChanges;
  final SyncChanges? conflicts;

  SyncResponse({
    required this.serverChanges,
    this.conflicts,
  });

  Map<String, dynamic> toJson() {
    return {
      'serverChanges': serverChanges.toJson(),
      if (conflicts != null) 'conflicts': conflicts!.toJson(),
    };
  }

  factory SyncResponse.fromJson(Map<String, dynamic> json) {
    return SyncResponse(
      serverChanges:
          SyncChanges.fromJson(json['serverChanges'] as Map<String, dynamic>),
      conflicts: json['conflicts'] == null
          ? null
          : SyncChanges.fromJson(json['conflicts'] as Map<String, dynamic>),
    );
  }
}
