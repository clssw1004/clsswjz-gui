// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UserTableTable extends UserTable with TableInfo<$UserTableTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nicknameMeta =
      const VerificationMeta('nickname');
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
      'nickname', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _inviteCodeMeta =
      const VerificationMeta('inviteCode');
  @override
  late final GeneratedColumn<String> inviteCode = GeneratedColumn<String>(
      'invite_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('zh-CN'));
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Asia/Shanghai'));
  @override
  List<GeneratedColumn> get $columns => [
        createdAt,
        updatedAt,
        id,
        username,
        nickname,
        avatar,
        password,
        email,
        phone,
        inviteCode,
        language,
        timezone
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_table';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(_nicknameMeta,
          nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta));
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('invite_code')) {
      context.handle(
          _inviteCodeMeta,
          inviteCode.isAcceptableOrUnknown(
              data['invite_code']!, _inviteCodeMeta));
    } else if (isInserting) {
      context.missing(_inviteCodeMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      nickname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nickname'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      inviteCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invite_code'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
    );
  }

  @override
  $UserTableTable createAlias(String alias) {
    return $UserTableTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String username;
  final String nickname;
  final String? avatar;
  final String password;
  final String? email;
  final String? phone;
  final String inviteCode;
  final String language;
  final String timezone;
  const User(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.username,
      required this.nickname,
      this.avatar,
      required this.password,
      this.email,
      this.phone,
      required this.inviteCode,
      required this.language,
      required this.timezone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    map['nickname'] = Variable<String>(nickname);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['password'] = Variable<String>(password);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['invite_code'] = Variable<String>(inviteCode);
    map['language'] = Variable<String>(language);
    map['timezone'] = Variable<String>(timezone);
    return map;
  }

  UserTableCompanion toCompanion(bool nullToAbsent) {
    return UserTableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      username: Value(username),
      nickname: Value(nickname),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      password: Value(password),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      inviteCode: Value(inviteCode),
      language: Value(language),
      timezone: Value(timezone),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      nickname: serializer.fromJson<String>(json['nickname']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      password: serializer.fromJson<String>(json['password']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      inviteCode: serializer.fromJson<String>(json['inviteCode']),
      language: serializer.fromJson<String>(json['language']),
      timezone: serializer.fromJson<String>(json['timezone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'nickname': serializer.toJson<String>(nickname),
      'avatar': serializer.toJson<String?>(avatar),
      'password': serializer.toJson<String>(password),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'inviteCode': serializer.toJson<String>(inviteCode),
      'language': serializer.toJson<String>(language),
      'timezone': serializer.toJson<String>(timezone),
    };
  }

  User copyWith(
          {int? createdAt,
          int? updatedAt,
          String? id,
          String? username,
          String? nickname,
          Value<String?> avatar = const Value.absent(),
          String? password,
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          String? inviteCode,
          String? language,
          String? timezone}) =>
      User(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        username: username ?? this.username,
        nickname: nickname ?? this.nickname,
        avatar: avatar.present ? avatar.value : this.avatar,
        password: password ?? this.password,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        inviteCode: inviteCode ?? this.inviteCode,
        language: language ?? this.language,
        timezone: timezone ?? this.timezone,
      );
  User copyWithCompanion(UserTableCompanion data) {
    return User(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      password: data.password.present ? data.password.value : this.password,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      inviteCode:
          data.inviteCode.present ? data.inviteCode.value : this.inviteCode,
      language: data.language.present ? data.language.value : this.language,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('password: $password, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('language: $language, ')
          ..write('timezone: $timezone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, username, nickname,
      avatar, password, email, phone, inviteCode, language, timezone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.username == this.username &&
          other.nickname == this.nickname &&
          other.avatar == this.avatar &&
          other.password == this.password &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.inviteCode == this.inviteCode &&
          other.language == this.language &&
          other.timezone == this.timezone);
}

class UserTableCompanion extends UpdateCompanion<User> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> username;
  final Value<String> nickname;
  final Value<String?> avatar;
  final Value<String> password;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> inviteCode;
  final Value<String> language;
  final Value<String> timezone;
  final Value<int> rowid;
  const UserTableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.nickname = const Value.absent(),
    this.avatar = const Value.absent(),
    this.password = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.inviteCode = const Value.absent(),
    this.language = const Value.absent(),
    this.timezone = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTableCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String username,
    required String nickname,
    this.avatar = const Value.absent(),
    required String password,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required String inviteCode,
    this.language = const Value.absent(),
    this.timezone = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        username = Value(username),
        nickname = Value(nickname),
        password = Value(password),
        inviteCode = Value(inviteCode);
  static Insertable<User> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? nickname,
    Expression<String>? avatar,
    Expression<String>? password,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? inviteCode,
    Expression<String>? language,
    Expression<String>? timezone,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      if (password != null) 'password': password,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (inviteCode != null) 'invite_code': inviteCode,
      if (language != null) 'language': language,
      if (timezone != null) 'timezone': timezone,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTableCompanion copyWith(
      {Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? username,
      Value<String>? nickname,
      Value<String?>? avatar,
      Value<String>? password,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String>? inviteCode,
      Value<String>? language,
      Value<String>? timezone,
      Value<int>? rowid}) {
    return UserTableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      password: password ?? this.password,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      inviteCode: inviteCode ?? this.inviteCode,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (inviteCode.present) {
      map['invite_code'] = Variable<String>(inviteCode.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('nickname: $nickname, ')
          ..write('avatar: $avatar, ')
          ..write('password: $password, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('inviteCode: $inviteCode, ')
          ..write('language: $language, ')
          ..write('timezone: $timezone, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountBookTableTable extends AccountBookTable
    with TableInfo<$AccountBookTableTable, AccountBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountBookTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencySymbolMeta =
      const VerificationMeta('currencySymbol');
  @override
  late final GeneratedColumn<String> currencySymbol = GeneratedColumn<String>(
      'currency_symbol', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('¥'));
  static const VerificationMeta _defaultFundIdMeta =
      const VerificationMeta('defaultFundId');
  @override
  late final GeneratedColumn<String> defaultFundId = GeneratedColumn<String>(
      'default_fund_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        name,
        description,
        currencySymbol,
        defaultFundId,
        icon
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_book_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountBook> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('currency_symbol')) {
      context.handle(
          _currencySymbolMeta,
          currencySymbol.isAcceptableOrUnknown(
              data['currency_symbol']!, _currencySymbolMeta));
    }
    if (data.containsKey('default_fund_id')) {
      context.handle(
          _defaultFundIdMeta,
          defaultFundId.isAcceptableOrUnknown(
              data['default_fund_id']!, _defaultFundIdMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountBook(
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      currencySymbol: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}currency_symbol'])!,
      defaultFundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_fund_id']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
    );
  }

  @override
  $AccountBookTableTable createAlias(String alias) {
    return $AccountBookTableTable(attachedDatabase, alias);
  }
}

class AccountBook extends DataClass implements Insertable<AccountBook> {
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final String? description;
  final String currencySymbol;

  /// 默认资金账户(无特殊作用，新增账目时默认选中的账户)
  final String? defaultFundId;
  final String? icon;
  const AccountBook(
      {required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      this.description,
      required this.currencySymbol,
      this.defaultFundId,
      this.icon});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['currency_symbol'] = Variable<String>(currencySymbol);
    if (!nullToAbsent || defaultFundId != null) {
      map['default_fund_id'] = Variable<String>(defaultFundId);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  AccountBookTableCompanion toCompanion(bool nullToAbsent) {
    return AccountBookTableCompanion(
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      currencySymbol: Value(currencySymbol),
      defaultFundId: defaultFundId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultFundId),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory AccountBook.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountBook(
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      currencySymbol: serializer.fromJson<String>(json['currencySymbol']),
      defaultFundId: serializer.fromJson<String?>(json['defaultFundId']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'currencySymbol': serializer.toJson<String>(currencySymbol),
      'defaultFundId': serializer.toJson<String?>(defaultFundId),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  AccountBook copyWith(
          {String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? currencySymbol,
          Value<String?> defaultFundId = const Value.absent(),
          Value<String?> icon = const Value.absent()}) =>
      AccountBook(
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        currencySymbol: currencySymbol ?? this.currencySymbol,
        defaultFundId:
            defaultFundId.present ? defaultFundId.value : this.defaultFundId,
        icon: icon.present ? icon.value : this.icon,
      );
  AccountBook copyWithCompanion(AccountBookTableCompanion data) {
    return AccountBook(
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      currencySymbol: data.currencySymbol.present
          ? data.currencySymbol.value
          : this.currencySymbol,
      defaultFundId: data.defaultFundId.present
          ? data.defaultFundId.value
          : this.defaultFundId,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountBook(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('defaultFundId: $defaultFundId, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdBy, updatedBy, createdAt, updatedAt,
      id, name, description, currencySymbol, defaultFundId, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountBook &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.currencySymbol == this.currencySymbol &&
          other.defaultFundId == this.defaultFundId &&
          other.icon == this.icon);
}

class AccountBookTableCompanion extends UpdateCompanion<AccountBook> {
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> currencySymbol;
  final Value<String?> defaultFundId;
  final Value<String?> icon;
  final Value<int> rowid;
  const AccountBookTableCompanion({
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.defaultFundId = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountBookTableCompanion.insert({
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.currencySymbol = const Value.absent(),
    this.defaultFundId = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        name = Value(name);
  static Insertable<AccountBook> custom({
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? currencySymbol,
    Expression<String>? defaultFundId,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (defaultFundId != null) 'default_fund_id': defaultFundId,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountBookTableCompanion copyWith(
      {Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? currencySymbol,
      Value<String?>? defaultFundId,
      Value<String?>? icon,
      Value<int>? rowid}) {
    return AccountBookTableCompanion(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      defaultFundId: defaultFundId ?? this.defaultFundId,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (currencySymbol.present) {
      map['currency_symbol'] = Variable<String>(currencySymbol.value);
    }
    if (defaultFundId.present) {
      map['default_fund_id'] = Variable<String>(defaultFundId.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountBookTableCompanion(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('currencySymbol: $currencySymbol, ')
          ..write('defaultFundId: $defaultFundId, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountItemTableTable extends AccountItemTable
    with TableInfo<$AccountItemTableTable, AccountItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountItemTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryCodeMeta =
      const VerificationMeta('categoryCode');
  @override
  late final GeneratedColumn<String> categoryCode = GeneratedColumn<String>(
      'category_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountDateMeta =
      const VerificationMeta('accountDate');
  @override
  late final GeneratedColumn<String> accountDate = GeneratedColumn<String>(
      'account_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fundIdMeta = const VerificationMeta('fundId');
  @override
  late final GeneratedColumn<String> fundId = GeneratedColumn<String>(
      'fund_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shopCodeMeta =
      const VerificationMeta('shopCode');
  @override
  late final GeneratedColumn<String> shopCode = GeneratedColumn<String>(
      'shop_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagCodeMeta =
      const VerificationMeta('tagCode');
  @override
  late final GeneratedColumn<String> tagCode = GeneratedColumn<String>(
      'tag_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _projectCodeMeta =
      const VerificationMeta('projectCode');
  @override
  late final GeneratedColumn<String> projectCode = GeneratedColumn<String>(
      'project_code', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        amount,
        description,
        type,
        categoryCode,
        accountDate,
        fundId,
        shopCode,
        tagCode,
        projectCode,
        source,
        sourceId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_item_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_code')) {
      context.handle(
          _categoryCodeMeta,
          categoryCode.isAcceptableOrUnknown(
              data['category_code']!, _categoryCodeMeta));
    }
    if (data.containsKey('account_date')) {
      context.handle(
          _accountDateMeta,
          accountDate.isAcceptableOrUnknown(
              data['account_date']!, _accountDateMeta));
    } else if (isInserting) {
      context.missing(_accountDateMeta);
    }
    if (data.containsKey('fund_id')) {
      context.handle(_fundIdMeta,
          fundId.isAcceptableOrUnknown(data['fund_id']!, _fundIdMeta));
    }
    if (data.containsKey('shop_code')) {
      context.handle(_shopCodeMeta,
          shopCode.isAcceptableOrUnknown(data['shop_code']!, _shopCodeMeta));
    }
    if (data.containsKey('tag_code')) {
      context.handle(_tagCodeMeta,
          tagCode.isAcceptableOrUnknown(data['tag_code']!, _tagCodeMeta));
    }
    if (data.containsKey('project_code')) {
      context.handle(
          _projectCodeMeta,
          projectCode.isAcceptableOrUnknown(
              data['project_code']!, _projectCodeMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountItem(
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      categoryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_code']),
      accountDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_date'])!,
      fundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fund_id']),
      shopCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_code']),
      tagCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_code']),
      projectCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_code']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id']),
    );
  }

  @override
  $AccountItemTableTable createAlias(String alias) {
    return $AccountItemTableTable(attachedDatabase, alias);
  }
}

class AccountItem extends DataClass implements Insertable<AccountItem> {
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final double amount;
  final String? description;
  final String type;
  final String? categoryCode;
  final String accountDate;
  final String? fundId;
  final String? shopCode;
  final String? tagCode;
  final String? projectCode;

  /// 账目来源
  final String? source;

  /// 账目来源ID
  final String? sourceId;
  const AccountItem(
      {required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.amount,
      this.description,
      required this.type,
      this.categoryCode,
      required this.accountDate,
      this.fundId,
      this.shopCode,
      this.tagCode,
      this.projectCode,
      this.source,
      this.sourceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryCode != null) {
      map['category_code'] = Variable<String>(categoryCode);
    }
    map['account_date'] = Variable<String>(accountDate);
    if (!nullToAbsent || fundId != null) {
      map['fund_id'] = Variable<String>(fundId);
    }
    if (!nullToAbsent || shopCode != null) {
      map['shop_code'] = Variable<String>(shopCode);
    }
    if (!nullToAbsent || tagCode != null) {
      map['tag_code'] = Variable<String>(tagCode);
    }
    if (!nullToAbsent || projectCode != null) {
      map['project_code'] = Variable<String>(projectCode);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    return map;
  }

  AccountItemTableCompanion toCompanion(bool nullToAbsent) {
    return AccountItemTableCompanion(
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
      categoryCode: categoryCode == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryCode),
      accountDate: Value(accountDate),
      fundId:
          fundId == null && nullToAbsent ? const Value.absent() : Value(fundId),
      shopCode: shopCode == null && nullToAbsent
          ? const Value.absent()
          : Value(shopCode),
      tagCode: tagCode == null && nullToAbsent
          ? const Value.absent()
          : Value(tagCode),
      projectCode: projectCode == null && nullToAbsent
          ? const Value.absent()
          : Value(projectCode),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
    );
  }

  factory AccountItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountItem(
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
      categoryCode: serializer.fromJson<String?>(json['categoryCode']),
      accountDate: serializer.fromJson<String>(json['accountDate']),
      fundId: serializer.fromJson<String?>(json['fundId']),
      shopCode: serializer.fromJson<String?>(json['shopCode']),
      tagCode: serializer.fromJson<String?>(json['tagCode']),
      projectCode: serializer.fromJson<String?>(json['projectCode']),
      source: serializer.fromJson<String?>(json['source']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountBookId': serializer.toJson<String>(accountBookId),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
      'categoryCode': serializer.toJson<String?>(categoryCode),
      'accountDate': serializer.toJson<String>(accountDate),
      'fundId': serializer.toJson<String?>(fundId),
      'shopCode': serializer.toJson<String?>(shopCode),
      'tagCode': serializer.toJson<String?>(tagCode),
      'projectCode': serializer.toJson<String?>(projectCode),
      'source': serializer.toJson<String?>(source),
      'sourceId': serializer.toJson<String?>(sourceId),
    };
  }

  AccountItem copyWith(
          {String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          double? amount,
          Value<String?> description = const Value.absent(),
          String? type,
          Value<String?> categoryCode = const Value.absent(),
          String? accountDate,
          Value<String?> fundId = const Value.absent(),
          Value<String?> shopCode = const Value.absent(),
          Value<String?> tagCode = const Value.absent(),
          Value<String?> projectCode = const Value.absent(),
          Value<String?> source = const Value.absent(),
          Value<String?> sourceId = const Value.absent()}) =>
      AccountItem(
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        type: type ?? this.type,
        categoryCode:
            categoryCode.present ? categoryCode.value : this.categoryCode,
        accountDate: accountDate ?? this.accountDate,
        fundId: fundId.present ? fundId.value : this.fundId,
        shopCode: shopCode.present ? shopCode.value : this.shopCode,
        tagCode: tagCode.present ? tagCode.value : this.tagCode,
        projectCode: projectCode.present ? projectCode.value : this.projectCode,
        source: source.present ? source.value : this.source,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
      );
  AccountItem copyWithCompanion(AccountItemTableCompanion data) {
    return AccountItem(
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      type: data.type.present ? data.type.value : this.type,
      categoryCode: data.categoryCode.present
          ? data.categoryCode.value
          : this.categoryCode,
      accountDate:
          data.accountDate.present ? data.accountDate.value : this.accountDate,
      fundId: data.fundId.present ? data.fundId.value : this.fundId,
      shopCode: data.shopCode.present ? data.shopCode.value : this.shopCode,
      tagCode: data.tagCode.present ? data.tagCode.value : this.tagCode,
      projectCode:
          data.projectCode.present ? data.projectCode.value : this.projectCode,
      source: data.source.present ? data.source.value : this.source,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountItem(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('accountDate: $accountDate, ')
          ..write('fundId: $fundId, ')
          ..write('shopCode: $shopCode, ')
          ..write('tagCode: $tagCode, ')
          ..write('projectCode: $projectCode, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      accountBookId,
      createdBy,
      updatedBy,
      createdAt,
      updatedAt,
      id,
      amount,
      description,
      type,
      categoryCode,
      accountDate,
      fundId,
      shopCode,
      tagCode,
      projectCode,
      source,
      sourceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountItem &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.type == this.type &&
          other.categoryCode == this.categoryCode &&
          other.accountDate == this.accountDate &&
          other.fundId == this.fundId &&
          other.shopCode == this.shopCode &&
          other.tagCode == this.tagCode &&
          other.projectCode == this.projectCode &&
          other.source == this.source &&
          other.sourceId == this.sourceId);
}

class AccountItemTableCompanion extends UpdateCompanion<AccountItem> {
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<double> amount;
  final Value<String?> description;
  final Value<String> type;
  final Value<String?> categoryCode;
  final Value<String> accountDate;
  final Value<String?> fundId;
  final Value<String?> shopCode;
  final Value<String?> tagCode;
  final Value<String?> projectCode;
  final Value<String?> source;
  final Value<String?> sourceId;
  final Value<int> rowid;
  const AccountItemTableCompanion({
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryCode = const Value.absent(),
    this.accountDate = const Value.absent(),
    this.fundId = const Value.absent(),
    this.shopCode = const Value.absent(),
    this.tagCode = const Value.absent(),
    this.projectCode = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountItemTableCompanion.insert({
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required double amount,
    this.description = const Value.absent(),
    required String type,
    this.categoryCode = const Value.absent(),
    required String accountDate,
    this.fundId = const Value.absent(),
    this.shopCode = const Value.absent(),
    this.tagCode = const Value.absent(),
    this.projectCode = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        amount = Value(amount),
        type = Value(type),
        accountDate = Value(accountDate);
  static Insertable<AccountItem> custom({
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? type,
    Expression<String>? categoryCode,
    Expression<String>? accountDate,
    Expression<String>? fundId,
    Expression<String>? shopCode,
    Expression<String>? tagCode,
    Expression<String>? projectCode,
    Expression<String>? source,
    Expression<String>? sourceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (categoryCode != null) 'category_code': categoryCode,
      if (accountDate != null) 'account_date': accountDate,
      if (fundId != null) 'fund_id': fundId,
      if (shopCode != null) 'shop_code': shopCode,
      if (tagCode != null) 'tag_code': tagCode,
      if (projectCode != null) 'project_code': projectCode,
      if (source != null) 'source': source,
      if (sourceId != null) 'source_id': sourceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountItemTableCompanion copyWith(
      {Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<double>? amount,
      Value<String?>? description,
      Value<String>? type,
      Value<String?>? categoryCode,
      Value<String>? accountDate,
      Value<String?>? fundId,
      Value<String?>? shopCode,
      Value<String?>? tagCode,
      Value<String?>? projectCode,
      Value<String?>? source,
      Value<String?>? sourceId,
      Value<int>? rowid}) {
    return AccountItemTableCompanion(
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      categoryCode: categoryCode ?? this.categoryCode,
      accountDate: accountDate ?? this.accountDate,
      fundId: fundId ?? this.fundId,
      shopCode: shopCode ?? this.shopCode,
      tagCode: tagCode ?? this.tagCode,
      projectCode: projectCode ?? this.projectCode,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryCode.present) {
      map['category_code'] = Variable<String>(categoryCode.value);
    }
    if (accountDate.present) {
      map['account_date'] = Variable<String>(accountDate.value);
    }
    if (fundId.present) {
      map['fund_id'] = Variable<String>(fundId.value);
    }
    if (shopCode.present) {
      map['shop_code'] = Variable<String>(shopCode.value);
    }
    if (tagCode.present) {
      map['tag_code'] = Variable<String>(tagCode.value);
    }
    if (projectCode.present) {
      map['project_code'] = Variable<String>(projectCode.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountItemTableCompanion(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('accountDate: $accountDate, ')
          ..write('fundId: $fundId, ')
          ..write('shopCode: $shopCode, ')
          ..write('tagCode: $tagCode, ')
          ..write('projectCode: $projectCode, ')
          ..write('source: $source, ')
          ..write('sourceId: $sourceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountCategoryTableTable extends AccountCategoryTable
    with TableInfo<$AccountCategoryTableTable, AccountCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountCategoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lastAccountItemAtMeta =
      const VerificationMeta('lastAccountItemAt');
  @override
  late final GeneratedColumn<String> lastAccountItemAt =
      GeneratedColumn<String>('last_account_item_at', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryTypeMeta =
      const VerificationMeta('categoryType');
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
      'category_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        lastAccountItemAt,
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        name,
        code,
        categoryType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_category_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_account_item_at')) {
      context.handle(
          _lastAccountItemAtMeta,
          lastAccountItemAt.isAcceptableOrUnknown(
              data['last_account_item_at']!, _lastAccountItemAtMeta));
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('category_type')) {
      context.handle(
          _categoryTypeMeta,
          categoryType.isAcceptableOrUnknown(
              data['category_type']!, _categoryTypeMeta));
    } else if (isInserting) {
      context.missing(_categoryTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {name, accountBookId, categoryType},
      ];
  @override
  AccountCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountCategory(
      lastAccountItemAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_account_item_at']),
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      categoryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_type'])!,
    );
  }

  @override
  $AccountCategoryTableTable createAlias(String alias) {
    return $AccountCategoryTableTable(attachedDatabase, alias);
  }
}

class AccountCategory extends DataClass implements Insertable<AccountCategory> {
  final String? lastAccountItemAt;
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final String code;
  final String categoryType;
  const AccountCategory(
      {this.lastAccountItemAt,
      required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      required this.code,
      required this.categoryType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || lastAccountItemAt != null) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt);
    }
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['category_type'] = Variable<String>(categoryType);
    return map;
  }

  AccountCategoryTableCompanion toCompanion(bool nullToAbsent) {
    return AccountCategoryTableCompanion(
      lastAccountItemAt: lastAccountItemAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccountItemAt),
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      code: Value(code),
      categoryType: Value(categoryType),
    );
  }

  factory AccountCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountCategory(
      lastAccountItemAt:
          serializer.fromJson<String?>(json['lastAccountItemAt']),
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      categoryType: serializer.fromJson<String>(json['categoryType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lastAccountItemAt': serializer.toJson<String?>(lastAccountItemAt),
      'accountBookId': serializer.toJson<String>(accountBookId),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'categoryType': serializer.toJson<String>(categoryType),
    };
  }

  AccountCategory copyWith(
          {Value<String?> lastAccountItemAt = const Value.absent(),
          String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? name,
          String? code,
          String? categoryType}) =>
      AccountCategory(
        lastAccountItemAt: lastAccountItemAt.present
            ? lastAccountItemAt.value
            : this.lastAccountItemAt,
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        categoryType: categoryType ?? this.categoryType,
      );
  AccountCategory copyWithCompanion(AccountCategoryTableCompanion data) {
    return AccountCategory(
      lastAccountItemAt: data.lastAccountItemAt.present
          ? data.lastAccountItemAt.value
          : this.lastAccountItemAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      categoryType: data.categoryType.present
          ? data.categoryType.value
          : this.categoryType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountCategory(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('categoryType: $categoryType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lastAccountItemAt, accountBookId, createdBy,
      updatedBy, createdAt, updatedAt, id, name, code, categoryType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountCategory &&
          other.lastAccountItemAt == this.lastAccountItemAt &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.categoryType == this.categoryType);
}

class AccountCategoryTableCompanion extends UpdateCompanion<AccountCategory> {
  final Value<String?> lastAccountItemAt;
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String> categoryType;
  final Value<int> rowid;
  const AccountCategoryTableCompanion({
    this.lastAccountItemAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountCategoryTableCompanion.insert({
    this.lastAccountItemAt = const Value.absent(),
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    required String code,
    required String categoryType,
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        name = Value(name),
        code = Value(code),
        categoryType = Value(categoryType);
  static Insertable<AccountCategory> custom({
    Expression<String>? lastAccountItemAt,
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? categoryType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lastAccountItemAt != null) 'last_account_item_at': lastAccountItemAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (categoryType != null) 'category_type': categoryType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountCategoryTableCompanion copyWith(
      {Value<String?>? lastAccountItemAt,
      Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<String>? code,
      Value<String>? categoryType,
      Value<int>? rowid}) {
    return AccountCategoryTableCompanion(
      lastAccountItemAt: lastAccountItemAt ?? this.lastAccountItemAt,
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      categoryType: categoryType ?? this.categoryType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lastAccountItemAt.present) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(categoryType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountCategoryTableCompanion(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('categoryType: $categoryType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountFundTableTable extends AccountFundTable
    with TableInfo<$AccountFundTableTable, AccountFund> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountFundTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lastAccountItemAtMeta =
      const VerificationMeta('lastAccountItemAt');
  @override
  late final GeneratedColumn<String> lastAccountItemAt =
      GeneratedColumn<String>('last_account_item_at', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fundTypeMeta =
      const VerificationMeta('fundType');
  @override
  late final GeneratedColumn<String> fundType = GeneratedColumn<String>(
      'fund_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fundRemarkMeta =
      const VerificationMeta('fundRemark');
  @override
  late final GeneratedColumn<String> fundRemark = GeneratedColumn<String>(
      'fund_remark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fundBalanceMeta =
      const VerificationMeta('fundBalance');
  @override
  late final GeneratedColumn<double> fundBalance = GeneratedColumn<double>(
      'fund_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.00));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        lastAccountItemAt,
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        name,
        fundType,
        fundRemark,
        fundBalance,
        isDefault
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_fund_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountFund> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_account_item_at')) {
      context.handle(
          _lastAccountItemAtMeta,
          lastAccountItemAt.isAcceptableOrUnknown(
              data['last_account_item_at']!, _lastAccountItemAtMeta));
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('fund_type')) {
      context.handle(_fundTypeMeta,
          fundType.isAcceptableOrUnknown(data['fund_type']!, _fundTypeMeta));
    } else if (isInserting) {
      context.missing(_fundTypeMeta);
    }
    if (data.containsKey('fund_remark')) {
      context.handle(
          _fundRemarkMeta,
          fundRemark.isAcceptableOrUnknown(
              data['fund_remark']!, _fundRemarkMeta));
    }
    if (data.containsKey('fund_balance')) {
      context.handle(
          _fundBalanceMeta,
          fundBalance.isAcceptableOrUnknown(
              data['fund_balance']!, _fundBalanceMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountFund map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountFund(
      lastAccountItemAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_account_item_at']),
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      fundType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fund_type'])!,
      fundRemark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fund_remark']),
      fundBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}fund_balance'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default']),
    );
  }

  @override
  $AccountFundTableTable createAlias(String alias) {
    return $AccountFundTableTable(attachedDatabase, alias);
  }
}

class AccountFund extends DataClass implements Insertable<AccountFund> {
  final String? lastAccountItemAt;
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final String fundType;
  final String? fundRemark;
  final double fundBalance;
  final bool? isDefault;
  const AccountFund(
      {this.lastAccountItemAt,
      required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      required this.fundType,
      this.fundRemark,
      required this.fundBalance,
      this.isDefault});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || lastAccountItemAt != null) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt);
    }
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['fund_type'] = Variable<String>(fundType);
    if (!nullToAbsent || fundRemark != null) {
      map['fund_remark'] = Variable<String>(fundRemark);
    }
    map['fund_balance'] = Variable<double>(fundBalance);
    if (!nullToAbsent || isDefault != null) {
      map['is_default'] = Variable<bool>(isDefault);
    }
    return map;
  }

  AccountFundTableCompanion toCompanion(bool nullToAbsent) {
    return AccountFundTableCompanion(
      lastAccountItemAt: lastAccountItemAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccountItemAt),
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      fundType: Value(fundType),
      fundRemark: fundRemark == null && nullToAbsent
          ? const Value.absent()
          : Value(fundRemark),
      fundBalance: Value(fundBalance),
      isDefault: isDefault == null && nullToAbsent
          ? const Value.absent()
          : Value(isDefault),
    );
  }

  factory AccountFund.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountFund(
      lastAccountItemAt:
          serializer.fromJson<String?>(json['lastAccountItemAt']),
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fundType: serializer.fromJson<String>(json['fundType']),
      fundRemark: serializer.fromJson<String?>(json['fundRemark']),
      fundBalance: serializer.fromJson<double>(json['fundBalance']),
      isDefault: serializer.fromJson<bool?>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lastAccountItemAt': serializer.toJson<String?>(lastAccountItemAt),
      'accountBookId': serializer.toJson<String>(accountBookId),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fundType': serializer.toJson<String>(fundType),
      'fundRemark': serializer.toJson<String?>(fundRemark),
      'fundBalance': serializer.toJson<double>(fundBalance),
      'isDefault': serializer.toJson<bool?>(isDefault),
    };
  }

  AccountFund copyWith(
          {Value<String?> lastAccountItemAt = const Value.absent(),
          String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? name,
          String? fundType,
          Value<String?> fundRemark = const Value.absent(),
          double? fundBalance,
          Value<bool?> isDefault = const Value.absent()}) =>
      AccountFund(
        lastAccountItemAt: lastAccountItemAt.present
            ? lastAccountItemAt.value
            : this.lastAccountItemAt,
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        fundType: fundType ?? this.fundType,
        fundRemark: fundRemark.present ? fundRemark.value : this.fundRemark,
        fundBalance: fundBalance ?? this.fundBalance,
        isDefault: isDefault.present ? isDefault.value : this.isDefault,
      );
  AccountFund copyWithCompanion(AccountFundTableCompanion data) {
    return AccountFund(
      lastAccountItemAt: data.lastAccountItemAt.present
          ? data.lastAccountItemAt.value
          : this.lastAccountItemAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fundType: data.fundType.present ? data.fundType.value : this.fundType,
      fundRemark:
          data.fundRemark.present ? data.fundRemark.value : this.fundRemark,
      fundBalance:
          data.fundBalance.present ? data.fundBalance.value : this.fundBalance,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountFund(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fundType: $fundType, ')
          ..write('fundRemark: $fundRemark, ')
          ..write('fundBalance: $fundBalance, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      lastAccountItemAt,
      accountBookId,
      createdBy,
      updatedBy,
      createdAt,
      updatedAt,
      id,
      name,
      fundType,
      fundRemark,
      fundBalance,
      isDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountFund &&
          other.lastAccountItemAt == this.lastAccountItemAt &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.fundType == this.fundType &&
          other.fundRemark == this.fundRemark &&
          other.fundBalance == this.fundBalance &&
          other.isDefault == this.isDefault);
}

class AccountFundTableCompanion extends UpdateCompanion<AccountFund> {
  final Value<String?> lastAccountItemAt;
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> fundType;
  final Value<String?> fundRemark;
  final Value<double> fundBalance;
  final Value<bool?> isDefault;
  final Value<int> rowid;
  const AccountFundTableCompanion({
    this.lastAccountItemAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fundType = const Value.absent(),
    this.fundRemark = const Value.absent(),
    this.fundBalance = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountFundTableCompanion.insert({
    this.lastAccountItemAt = const Value.absent(),
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    required String fundType,
    this.fundRemark = const Value.absent(),
    this.fundBalance = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        name = Value(name),
        fundType = Value(fundType);
  static Insertable<AccountFund> custom({
    Expression<String>? lastAccountItemAt,
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fundType,
    Expression<String>? fundRemark,
    Expression<double>? fundBalance,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lastAccountItemAt != null) 'last_account_item_at': lastAccountItemAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fundType != null) 'fund_type': fundType,
      if (fundRemark != null) 'fund_remark': fundRemark,
      if (fundBalance != null) 'fund_balance': fundBalance,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountFundTableCompanion copyWith(
      {Value<String?>? lastAccountItemAt,
      Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<String>? fundType,
      Value<String?>? fundRemark,
      Value<double>? fundBalance,
      Value<bool?>? isDefault,
      Value<int>? rowid}) {
    return AccountFundTableCompanion(
      lastAccountItemAt: lastAccountItemAt ?? this.lastAccountItemAt,
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      fundType: fundType ?? this.fundType,
      fundRemark: fundRemark ?? this.fundRemark,
      fundBalance: fundBalance ?? this.fundBalance,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lastAccountItemAt.present) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fundType.present) {
      map['fund_type'] = Variable<String>(fundType.value);
    }
    if (fundRemark.present) {
      map['fund_remark'] = Variable<String>(fundRemark.value);
    }
    if (fundBalance.present) {
      map['fund_balance'] = Variable<double>(fundBalance.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountFundTableCompanion(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fundType: $fundType, ')
          ..write('fundRemark: $fundRemark, ')
          ..write('fundBalance: $fundBalance, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountShopTableTable extends AccountShopTable
    with TableInfo<$AccountShopTableTable, AccountShop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountShopTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lastAccountItemAtMeta =
      const VerificationMeta('lastAccountItemAt');
  @override
  late final GeneratedColumn<String> lastAccountItemAt =
      GeneratedColumn<String>('last_account_item_at', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        lastAccountItemAt,
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        name,
        code
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_shop_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountShop> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_account_item_at')) {
      context.handle(
          _lastAccountItemAtMeta,
          lastAccountItemAt.isAcceptableOrUnknown(
              data['last_account_item_at']!, _lastAccountItemAtMeta));
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountShop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountShop(
      lastAccountItemAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_account_item_at']),
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
    );
  }

  @override
  $AccountShopTableTable createAlias(String alias) {
    return $AccountShopTableTable(attachedDatabase, alias);
  }
}

class AccountShop extends DataClass implements Insertable<AccountShop> {
  final String? lastAccountItemAt;
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final String code;
  const AccountShop(
      {this.lastAccountItemAt,
      required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      required this.code});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || lastAccountItemAt != null) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt);
    }
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    return map;
  }

  AccountShopTableCompanion toCompanion(bool nullToAbsent) {
    return AccountShopTableCompanion(
      lastAccountItemAt: lastAccountItemAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccountItemAt),
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      code: Value(code),
    );
  }

  factory AccountShop.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountShop(
      lastAccountItemAt:
          serializer.fromJson<String?>(json['lastAccountItemAt']),
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lastAccountItemAt': serializer.toJson<String?>(lastAccountItemAt),
      'accountBookId': serializer.toJson<String>(accountBookId),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
    };
  }

  AccountShop copyWith(
          {Value<String?> lastAccountItemAt = const Value.absent(),
          String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? name,
          String? code}) =>
      AccountShop(
        lastAccountItemAt: lastAccountItemAt.present
            ? lastAccountItemAt.value
            : this.lastAccountItemAt,
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
      );
  AccountShop copyWithCompanion(AccountShopTableCompanion data) {
    return AccountShop(
      lastAccountItemAt: data.lastAccountItemAt.present
          ? data.lastAccountItemAt.value
          : this.lastAccountItemAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountShop(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lastAccountItemAt, accountBookId, createdBy,
      updatedBy, createdAt, updatedAt, id, name, code);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountShop &&
          other.lastAccountItemAt == this.lastAccountItemAt &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code);
}

class AccountShopTableCompanion extends UpdateCompanion<AccountShop> {
  final Value<String?> lastAccountItemAt;
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<int> rowid;
  const AccountShopTableCompanion({
    this.lastAccountItemAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountShopTableCompanion.insert({
    this.lastAccountItemAt = const Value.absent(),
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    required String code,
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        name = Value(name),
        code = Value(code);
  static Insertable<AccountShop> custom({
    Expression<String>? lastAccountItemAt,
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lastAccountItemAt != null) 'last_account_item_at': lastAccountItemAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountShopTableCompanion copyWith(
      {Value<String?>? lastAccountItemAt,
      Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<String>? code,
      Value<int>? rowid}) {
    return AccountShopTableCompanion(
      lastAccountItemAt: lastAccountItemAt ?? this.lastAccountItemAt,
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lastAccountItemAt.present) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountShopTableCompanion(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountSymbolTableTable extends AccountSymbolTable
    with TableInfo<$AccountSymbolTableTable, AccountSymbol> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountSymbolTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lastAccountItemAtMeta =
      const VerificationMeta('lastAccountItemAt');
  @override
  late final GeneratedColumn<String> lastAccountItemAt =
      GeneratedColumn<String>('last_account_item_at', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolTypeMeta =
      const VerificationMeta('symbolType');
  @override
  late final GeneratedColumn<String> symbolType = GeneratedColumn<String>(
      'symbol_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        lastAccountItemAt,
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        name,
        code,
        symbolType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_symbol_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountSymbol> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('last_account_item_at')) {
      context.handle(
          _lastAccountItemAtMeta,
          lastAccountItemAt.isAcceptableOrUnknown(
              data['last_account_item_at']!, _lastAccountItemAtMeta));
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('symbol_type')) {
      context.handle(
          _symbolTypeMeta,
          symbolType.isAcceptableOrUnknown(
              data['symbol_type']!, _symbolTypeMeta));
    } else if (isInserting) {
      context.missing(_symbolTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountSymbol map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountSymbol(
      lastAccountItemAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_account_item_at']),
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      symbolType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol_type'])!,
    );
  }

  @override
  $AccountSymbolTableTable createAlias(String alias) {
    return $AccountSymbolTableTable(attachedDatabase, alias);
  }
}

class AccountSymbol extends DataClass implements Insertable<AccountSymbol> {
  final String? lastAccountItemAt;
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String name;
  final String code;
  final String symbolType;
  const AccountSymbol(
      {this.lastAccountItemAt,
      required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      required this.code,
      required this.symbolType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || lastAccountItemAt != null) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt);
    }
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['code'] = Variable<String>(code);
    map['symbol_type'] = Variable<String>(symbolType);
    return map;
  }

  AccountSymbolTableCompanion toCompanion(bool nullToAbsent) {
    return AccountSymbolTableCompanion(
      lastAccountItemAt: lastAccountItemAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccountItemAt),
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      code: Value(code),
      symbolType: Value(symbolType),
    );
  }

  factory AccountSymbol.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountSymbol(
      lastAccountItemAt:
          serializer.fromJson<String?>(json['lastAccountItemAt']),
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String>(json['code']),
      symbolType: serializer.fromJson<String>(json['symbolType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lastAccountItemAt': serializer.toJson<String?>(lastAccountItemAt),
      'accountBookId': serializer.toJson<String>(accountBookId),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String>(code),
      'symbolType': serializer.toJson<String>(symbolType),
    };
  }

  AccountSymbol copyWith(
          {Value<String?> lastAccountItemAt = const Value.absent(),
          String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? name,
          String? code,
          String? symbolType}) =>
      AccountSymbol(
        lastAccountItemAt: lastAccountItemAt.present
            ? lastAccountItemAt.value
            : this.lastAccountItemAt,
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        code: code ?? this.code,
        symbolType: symbolType ?? this.symbolType,
      );
  AccountSymbol copyWithCompanion(AccountSymbolTableCompanion data) {
    return AccountSymbol(
      lastAccountItemAt: data.lastAccountItemAt.present
          ? data.lastAccountItemAt.value
          : this.lastAccountItemAt,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      symbolType:
          data.symbolType.present ? data.symbolType.value : this.symbolType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountSymbol(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('symbolType: $symbolType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lastAccountItemAt, accountBookId, createdBy,
      updatedBy, createdAt, updatedAt, id, name, code, symbolType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountSymbol &&
          other.lastAccountItemAt == this.lastAccountItemAt &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.symbolType == this.symbolType);
}

class AccountSymbolTableCompanion extends UpdateCompanion<AccountSymbol> {
  final Value<String?> lastAccountItemAt;
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> code;
  final Value<String> symbolType;
  final Value<int> rowid;
  const AccountSymbolTableCompanion({
    this.lastAccountItemAt = const Value.absent(),
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.symbolType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountSymbolTableCompanion.insert({
    this.lastAccountItemAt = const Value.absent(),
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    required String code,
    required String symbolType,
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        name = Value(name),
        code = Value(code),
        symbolType = Value(symbolType);
  static Insertable<AccountSymbol> custom({
    Expression<String>? lastAccountItemAt,
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<String>? symbolType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lastAccountItemAt != null) 'last_account_item_at': lastAccountItemAt,
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (symbolType != null) 'symbol_type': symbolType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountSymbolTableCompanion copyWith(
      {Value<String?>? lastAccountItemAt,
      Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<String>? code,
      Value<String>? symbolType,
      Value<int>? rowid}) {
    return AccountSymbolTableCompanion(
      lastAccountItemAt: lastAccountItemAt ?? this.lastAccountItemAt,
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      symbolType: symbolType ?? this.symbolType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lastAccountItemAt.present) {
      map['last_account_item_at'] = Variable<String>(lastAccountItemAt.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (symbolType.present) {
      map['symbol_type'] = Variable<String>(symbolType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountSymbolTableCompanion(')
          ..write('lastAccountItemAt: $lastAccountItemAt, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('symbolType: $symbolType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelAccountbookUserTableTable extends RelAccountbookUserTable
    with TableInfo<$RelAccountbookUserTableTable, RelAccountbookUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelAccountbookUserTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _canViewBookMeta =
      const VerificationMeta('canViewBook');
  @override
  late final GeneratedColumn<bool> canViewBook = GeneratedColumn<bool>(
      'can_view_book', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_view_book" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _canEditBookMeta =
      const VerificationMeta('canEditBook');
  @override
  late final GeneratedColumn<bool> canEditBook = GeneratedColumn<bool>(
      'can_edit_book', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_edit_book" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _canDeleteBookMeta =
      const VerificationMeta('canDeleteBook');
  @override
  late final GeneratedColumn<bool> canDeleteBook = GeneratedColumn<bool>(
      'can_delete_book', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_delete_book" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _canViewItemMeta =
      const VerificationMeta('canViewItem');
  @override
  late final GeneratedColumn<bool> canViewItem = GeneratedColumn<bool>(
      'can_view_item', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_view_item" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _canEditItemMeta =
      const VerificationMeta('canEditItem');
  @override
  late final GeneratedColumn<bool> canEditItem = GeneratedColumn<bool>(
      'can_edit_item', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_edit_item" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _canDeleteItemMeta =
      const VerificationMeta('canDeleteItem');
  @override
  late final GeneratedColumn<bool> canDeleteItem = GeneratedColumn<bool>(
      'can_delete_item', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_delete_item" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        createdAt,
        updatedAt,
        id,
        userId,
        accountBookId,
        canViewBook,
        canEditBook,
        canDeleteBook,
        canViewItem,
        canEditItem,
        canDeleteItem
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rel_accountbook_user_table';
  @override
  VerificationContext validateIntegrity(Insertable<RelAccountbookUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('can_view_book')) {
      context.handle(
          _canViewBookMeta,
          canViewBook.isAcceptableOrUnknown(
              data['can_view_book']!, _canViewBookMeta));
    }
    if (data.containsKey('can_edit_book')) {
      context.handle(
          _canEditBookMeta,
          canEditBook.isAcceptableOrUnknown(
              data['can_edit_book']!, _canEditBookMeta));
    }
    if (data.containsKey('can_delete_book')) {
      context.handle(
          _canDeleteBookMeta,
          canDeleteBook.isAcceptableOrUnknown(
              data['can_delete_book']!, _canDeleteBookMeta));
    }
    if (data.containsKey('can_view_item')) {
      context.handle(
          _canViewItemMeta,
          canViewItem.isAcceptableOrUnknown(
              data['can_view_item']!, _canViewItemMeta));
    }
    if (data.containsKey('can_edit_item')) {
      context.handle(
          _canEditItemMeta,
          canEditItem.isAcceptableOrUnknown(
              data['can_edit_item']!, _canEditItemMeta));
    }
    if (data.containsKey('can_delete_item')) {
      context.handle(
          _canDeleteItemMeta,
          canDeleteItem.isAcceptableOrUnknown(
              data['can_delete_item']!, _canDeleteItemMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RelAccountbookUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelAccountbookUser(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      canViewBook: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_view_book'])!,
      canEditBook: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_edit_book'])!,
      canDeleteBook: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_delete_book'])!,
      canViewItem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_view_item'])!,
      canEditItem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_edit_item'])!,
      canDeleteItem: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_delete_item'])!,
    );
  }

  @override
  $RelAccountbookUserTableTable createAlias(String alias) {
    return $RelAccountbookUserTableTable(attachedDatabase, alias);
  }
}

class RelAccountbookUser extends DataClass
    implements Insertable<RelAccountbookUser> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String userId;
  final String accountBookId;
  final bool canViewBook;
  final bool canEditBook;
  final bool canDeleteBook;
  final bool canViewItem;
  final bool canEditItem;
  final bool canDeleteItem;
  const RelAccountbookUser(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.userId,
      required this.accountBookId,
      required this.canViewBook,
      required this.canEditBook,
      required this.canDeleteBook,
      required this.canViewItem,
      required this.canEditItem,
      required this.canDeleteItem});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_book_id'] = Variable<String>(accountBookId);
    map['can_view_book'] = Variable<bool>(canViewBook);
    map['can_edit_book'] = Variable<bool>(canEditBook);
    map['can_delete_book'] = Variable<bool>(canDeleteBook);
    map['can_view_item'] = Variable<bool>(canViewItem);
    map['can_edit_item'] = Variable<bool>(canEditItem);
    map['can_delete_item'] = Variable<bool>(canDeleteItem);
    return map;
  }

  RelAccountbookUserTableCompanion toCompanion(bool nullToAbsent) {
    return RelAccountbookUserTableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      userId: Value(userId),
      accountBookId: Value(accountBookId),
      canViewBook: Value(canViewBook),
      canEditBook: Value(canEditBook),
      canDeleteBook: Value(canDeleteBook),
      canViewItem: Value(canViewItem),
      canEditItem: Value(canEditItem),
      canDeleteItem: Value(canDeleteItem),
    );
  }

  factory RelAccountbookUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelAccountbookUser(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      canViewBook: serializer.fromJson<bool>(json['canViewBook']),
      canEditBook: serializer.fromJson<bool>(json['canEditBook']),
      canDeleteBook: serializer.fromJson<bool>(json['canDeleteBook']),
      canViewItem: serializer.fromJson<bool>(json['canViewItem']),
      canEditItem: serializer.fromJson<bool>(json['canEditItem']),
      canDeleteItem: serializer.fromJson<bool>(json['canDeleteItem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountBookId': serializer.toJson<String>(accountBookId),
      'canViewBook': serializer.toJson<bool>(canViewBook),
      'canEditBook': serializer.toJson<bool>(canEditBook),
      'canDeleteBook': serializer.toJson<bool>(canDeleteBook),
      'canViewItem': serializer.toJson<bool>(canViewItem),
      'canEditItem': serializer.toJson<bool>(canEditItem),
      'canDeleteItem': serializer.toJson<bool>(canDeleteItem),
    };
  }

  RelAccountbookUser copyWith(
          {int? createdAt,
          int? updatedAt,
          String? id,
          String? userId,
          String? accountBookId,
          bool? canViewBook,
          bool? canEditBook,
          bool? canDeleteBook,
          bool? canViewItem,
          bool? canEditItem,
          bool? canDeleteItem}) =>
      RelAccountbookUser(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        userId: userId ?? this.userId,
        accountBookId: accountBookId ?? this.accountBookId,
        canViewBook: canViewBook ?? this.canViewBook,
        canEditBook: canEditBook ?? this.canEditBook,
        canDeleteBook: canDeleteBook ?? this.canDeleteBook,
        canViewItem: canViewItem ?? this.canViewItem,
        canEditItem: canEditItem ?? this.canEditItem,
        canDeleteItem: canDeleteItem ?? this.canDeleteItem,
      );
  RelAccountbookUser copyWithCompanion(RelAccountbookUserTableCompanion data) {
    return RelAccountbookUser(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      canViewBook:
          data.canViewBook.present ? data.canViewBook.value : this.canViewBook,
      canEditBook:
          data.canEditBook.present ? data.canEditBook.value : this.canEditBook,
      canDeleteBook: data.canDeleteBook.present
          ? data.canDeleteBook.value
          : this.canDeleteBook,
      canViewItem:
          data.canViewItem.present ? data.canViewItem.value : this.canViewItem,
      canEditItem:
          data.canEditItem.present ? data.canEditItem.value : this.canEditItem,
      canDeleteItem: data.canDeleteItem.present
          ? data.canDeleteItem.value
          : this.canDeleteItem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelAccountbookUser(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('canViewBook: $canViewBook, ')
          ..write('canEditBook: $canEditBook, ')
          ..write('canDeleteBook: $canDeleteBook, ')
          ..write('canViewItem: $canViewItem, ')
          ..write('canEditItem: $canEditItem, ')
          ..write('canDeleteItem: $canDeleteItem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      createdAt,
      updatedAt,
      id,
      userId,
      accountBookId,
      canViewBook,
      canEditBook,
      canDeleteBook,
      canViewItem,
      canEditItem,
      canDeleteItem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelAccountbookUser &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountBookId == this.accountBookId &&
          other.canViewBook == this.canViewBook &&
          other.canEditBook == this.canEditBook &&
          other.canDeleteBook == this.canDeleteBook &&
          other.canViewItem == this.canViewItem &&
          other.canEditItem == this.canEditItem &&
          other.canDeleteItem == this.canDeleteItem);
}

class RelAccountbookUserTableCompanion
    extends UpdateCompanion<RelAccountbookUser> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountBookId;
  final Value<bool> canViewBook;
  final Value<bool> canEditBook;
  final Value<bool> canDeleteBook;
  final Value<bool> canViewItem;
  final Value<bool> canEditItem;
  final Value<bool> canDeleteItem;
  final Value<int> rowid;
  const RelAccountbookUserTableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountBookId = const Value.absent(),
    this.canViewBook = const Value.absent(),
    this.canEditBook = const Value.absent(),
    this.canDeleteBook = const Value.absent(),
    this.canViewItem = const Value.absent(),
    this.canEditItem = const Value.absent(),
    this.canDeleteItem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelAccountbookUserTableCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String userId,
    required String accountBookId,
    this.canViewBook = const Value.absent(),
    this.canEditBook = const Value.absent(),
    this.canDeleteBook = const Value.absent(),
    this.canViewItem = const Value.absent(),
    this.canEditItem = const Value.absent(),
    this.canDeleteItem = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        userId = Value(userId),
        accountBookId = Value(accountBookId);
  static Insertable<RelAccountbookUser> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountBookId,
    Expression<bool>? canViewBook,
    Expression<bool>? canEditBook,
    Expression<bool>? canDeleteBook,
    Expression<bool>? canViewItem,
    Expression<bool>? canEditItem,
    Expression<bool>? canDeleteItem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (canViewBook != null) 'can_view_book': canViewBook,
      if (canEditBook != null) 'can_edit_book': canEditBook,
      if (canDeleteBook != null) 'can_delete_book': canDeleteBook,
      if (canViewItem != null) 'can_view_item': canViewItem,
      if (canEditItem != null) 'can_edit_item': canEditItem,
      if (canDeleteItem != null) 'can_delete_item': canDeleteItem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelAccountbookUserTableCompanion copyWith(
      {Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? userId,
      Value<String>? accountBookId,
      Value<bool>? canViewBook,
      Value<bool>? canEditBook,
      Value<bool>? canDeleteBook,
      Value<bool>? canViewItem,
      Value<bool>? canEditItem,
      Value<bool>? canDeleteItem,
      Value<int>? rowid}) {
    return RelAccountbookUserTableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountBookId: accountBookId ?? this.accountBookId,
      canViewBook: canViewBook ?? this.canViewBook,
      canEditBook: canEditBook ?? this.canEditBook,
      canDeleteBook: canDeleteBook ?? this.canDeleteBook,
      canViewItem: canViewItem ?? this.canViewItem,
      canEditItem: canEditItem ?? this.canEditItem,
      canDeleteItem: canDeleteItem ?? this.canDeleteItem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (canViewBook.present) {
      map['can_view_book'] = Variable<bool>(canViewBook.value);
    }
    if (canEditBook.present) {
      map['can_edit_book'] = Variable<bool>(canEditBook.value);
    }
    if (canDeleteBook.present) {
      map['can_delete_book'] = Variable<bool>(canDeleteBook.value);
    }
    if (canViewItem.present) {
      map['can_view_item'] = Variable<bool>(canViewItem.value);
    }
    if (canEditItem.present) {
      map['can_edit_item'] = Variable<bool>(canEditItem.value);
    }
    if (canDeleteItem.present) {
      map['can_delete_item'] = Variable<bool>(canDeleteItem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelAccountbookUserTableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('canViewBook: $canViewBook, ')
          ..write('canEditBook: $canEditBook, ')
          ..write('canDeleteBook: $canDeleteBook, ')
          ..write('canViewItem: $canViewItem, ')
          ..write('canEditItem: $canEditItem, ')
          ..write('canDeleteItem: $canDeleteItem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogSyncTableTable extends LogSyncTable
    with TableInfo<$LogSyncTableTable, LogSync> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogSyncTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentTypeMeta =
      const VerificationMeta('parentType');
  @override
  late final GeneratedColumn<String> parentType = GeneratedColumn<String>(
      'parent_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatorIdMeta =
      const VerificationMeta('operatorId');
  @override
  late final GeneratedColumn<String> operatorId = GeneratedColumn<String>(
      'operator_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatedAtMeta =
      const VerificationMeta('operatedAt');
  @override
  late final GeneratedColumn<int> operatedAt = GeneratedColumn<int>(
      'operated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _businessTypeMeta =
      const VerificationMeta('businessType');
  @override
  late final GeneratedColumn<String> businessType = GeneratedColumn<String>(
      'business_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operateTypeMeta =
      const VerificationMeta('operateType');
  @override
  late final GeneratedColumn<String> operateType = GeneratedColumn<String>(
      'operate_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operateDataMeta =
      const VerificationMeta('operateData');
  @override
  late final GeneratedColumn<String> operateData = GeneratedColumn<String>(
      'operate_data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncTimeMeta =
      const VerificationMeta('syncTime');
  @override
  late final GeneratedColumn<int> syncTime = GeneratedColumn<int>(
      'sync_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _syncErrorMeta =
      const VerificationMeta('syncError');
  @override
  late final GeneratedColumn<String> syncError = GeneratedColumn<String>(
      'sync_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        parentType,
        parentId,
        operatorId,
        operatedAt,
        businessType,
        operateType,
        businessId,
        operateData,
        syncState,
        syncTime,
        syncError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_sync_table';
  @override
  VerificationContext validateIntegrity(Insertable<LogSync> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_type')) {
      context.handle(
          _parentTypeMeta,
          parentType.isAcceptableOrUnknown(
              data['parent_type']!, _parentTypeMeta));
    } else if (isInserting) {
      context.missing(_parentTypeMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    if (data.containsKey('operator_id')) {
      context.handle(
          _operatorIdMeta,
          operatorId.isAcceptableOrUnknown(
              data['operator_id']!, _operatorIdMeta));
    } else if (isInserting) {
      context.missing(_operatorIdMeta);
    }
    if (data.containsKey('operated_at')) {
      context.handle(
          _operatedAtMeta,
          operatedAt.isAcceptableOrUnknown(
              data['operated_at']!, _operatedAtMeta));
    } else if (isInserting) {
      context.missing(_operatedAtMeta);
    }
    if (data.containsKey('business_type')) {
      context.handle(
          _businessTypeMeta,
          businessType.isAcceptableOrUnknown(
              data['business_type']!, _businessTypeMeta));
    } else if (isInserting) {
      context.missing(_businessTypeMeta);
    }
    if (data.containsKey('operate_type')) {
      context.handle(
          _operateTypeMeta,
          operateType.isAcceptableOrUnknown(
              data['operate_type']!, _operateTypeMeta));
    } else if (isInserting) {
      context.missing(_operateTypeMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('operate_data')) {
      context.handle(
          _operateDataMeta,
          operateData.isAcceptableOrUnknown(
              data['operate_data']!, _operateDataMeta));
    } else if (isInserting) {
      context.missing(_operateDataMeta);
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    } else if (isInserting) {
      context.missing(_syncStateMeta);
    }
    if (data.containsKey('sync_time')) {
      context.handle(_syncTimeMeta,
          syncTime.isAcceptableOrUnknown(data['sync_time']!, _syncTimeMeta));
    } else if (isInserting) {
      context.missing(_syncTimeMeta);
    }
    if (data.containsKey('sync_error')) {
      context.handle(_syncErrorMeta,
          syncError.isAcceptableOrUnknown(data['sync_error']!, _syncErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogSync map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogSync(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      parentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_type'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id'])!,
      operatorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator_id'])!,
      operatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}operated_at'])!,
      businessType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_type'])!,
      operateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operate_type'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
      operateData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operate_data'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      syncTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sync_time'])!,
      syncError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_error']),
    );
  }

  @override
  $LogSyncTableTable createAlias(String alias) {
    return $LogSyncTableTable(attachedDatabase, alias);
  }
}

class LogSync extends DataClass implements Insertable<LogSync> {
  final String id;

  /// 父级ID
  final String parentType;

  /// 父级ID
  final String parentId;

  /// 操作人
  final String operatorId;

  /// 操作时间戳
  final int operatedAt;

  /// 操作业务
  /// item-账目、book-账本、fund-账户、category-分类、shop-商家、symbol-标识、user-用户，attachment-附件
  final String businessType;

  /// 操作类型
  /// update-更新、create-创建、delete-删除
  /// batchUpdate-批量更新、batchCreate-批量创建、batchDelete-批量删除
  final String operateType;

  /// 操作数据主键
  final String businessId;

  /// 操作数据json
  final String operateData;

  /// 同步状态
  /// unsynced-未同步、synced-已同步、syncing-同步中、failed-同步失败
  final String syncState;

  /// 同步时间
  final int syncTime;

  /// 同步错误信息
  final String? syncError;
  const LogSync(
      {required this.id,
      required this.parentType,
      required this.parentId,
      required this.operatorId,
      required this.operatedAt,
      required this.businessType,
      required this.operateType,
      required this.businessId,
      required this.operateData,
      required this.syncState,
      required this.syncTime,
      this.syncError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['parent_type'] = Variable<String>(parentType);
    map['parent_id'] = Variable<String>(parentId);
    map['operator_id'] = Variable<String>(operatorId);
    map['operated_at'] = Variable<int>(operatedAt);
    map['business_type'] = Variable<String>(businessType);
    map['operate_type'] = Variable<String>(operateType);
    map['business_id'] = Variable<String>(businessId);
    map['operate_data'] = Variable<String>(operateData);
    map['sync_state'] = Variable<String>(syncState);
    map['sync_time'] = Variable<int>(syncTime);
    if (!nullToAbsent || syncError != null) {
      map['sync_error'] = Variable<String>(syncError);
    }
    return map;
  }

  LogSyncTableCompanion toCompanion(bool nullToAbsent) {
    return LogSyncTableCompanion(
      id: Value(id),
      parentType: Value(parentType),
      parentId: Value(parentId),
      operatorId: Value(operatorId),
      operatedAt: Value(operatedAt),
      businessType: Value(businessType),
      operateType: Value(operateType),
      businessId: Value(businessId),
      operateData: Value(operateData),
      syncState: Value(syncState),
      syncTime: Value(syncTime),
      syncError: syncError == null && nullToAbsent
          ? const Value.absent()
          : Value(syncError),
    );
  }

  factory LogSync.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogSync(
      id: serializer.fromJson<String>(json['id']),
      parentType: serializer.fromJson<String>(json['parentType']),
      parentId: serializer.fromJson<String>(json['parentId']),
      operatorId: serializer.fromJson<String>(json['operatorId']),
      operatedAt: serializer.fromJson<int>(json['operatedAt']),
      businessType: serializer.fromJson<String>(json['businessType']),
      operateType: serializer.fromJson<String>(json['operateType']),
      businessId: serializer.fromJson<String>(json['businessId']),
      operateData: serializer.fromJson<String>(json['operateData']),
      syncState: serializer.fromJson<String>(json['syncState']),
      syncTime: serializer.fromJson<int>(json['syncTime']),
      syncError: serializer.fromJson<String?>(json['syncError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentType': serializer.toJson<String>(parentType),
      'parentId': serializer.toJson<String>(parentId),
      'operatorId': serializer.toJson<String>(operatorId),
      'operatedAt': serializer.toJson<int>(operatedAt),
      'businessType': serializer.toJson<String>(businessType),
      'operateType': serializer.toJson<String>(operateType),
      'businessId': serializer.toJson<String>(businessId),
      'operateData': serializer.toJson<String>(operateData),
      'syncState': serializer.toJson<String>(syncState),
      'syncTime': serializer.toJson<int>(syncTime),
      'syncError': serializer.toJson<String?>(syncError),
    };
  }

  LogSync copyWith(
          {String? id,
          String? parentType,
          String? parentId,
          String? operatorId,
          int? operatedAt,
          String? businessType,
          String? operateType,
          String? businessId,
          String? operateData,
          String? syncState,
          int? syncTime,
          Value<String?> syncError = const Value.absent()}) =>
      LogSync(
        id: id ?? this.id,
        parentType: parentType ?? this.parentType,
        parentId: parentId ?? this.parentId,
        operatorId: operatorId ?? this.operatorId,
        operatedAt: operatedAt ?? this.operatedAt,
        businessType: businessType ?? this.businessType,
        operateType: operateType ?? this.operateType,
        businessId: businessId ?? this.businessId,
        operateData: operateData ?? this.operateData,
        syncState: syncState ?? this.syncState,
        syncTime: syncTime ?? this.syncTime,
        syncError: syncError.present ? syncError.value : this.syncError,
      );
  LogSync copyWithCompanion(LogSyncTableCompanion data) {
    return LogSync(
      id: data.id.present ? data.id.value : this.id,
      parentType:
          data.parentType.present ? data.parentType.value : this.parentType,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      operatorId:
          data.operatorId.present ? data.operatorId.value : this.operatorId,
      operatedAt:
          data.operatedAt.present ? data.operatedAt.value : this.operatedAt,
      businessType: data.businessType.present
          ? data.businessType.value
          : this.businessType,
      operateType:
          data.operateType.present ? data.operateType.value : this.operateType,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      operateData:
          data.operateData.present ? data.operateData.value : this.operateData,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      syncTime: data.syncTime.present ? data.syncTime.value : this.syncTime,
      syncError: data.syncError.present ? data.syncError.value : this.syncError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogSync(')
          ..write('id: $id, ')
          ..write('parentType: $parentType, ')
          ..write('parentId: $parentId, ')
          ..write('operatorId: $operatorId, ')
          ..write('operatedAt: $operatedAt, ')
          ..write('businessType: $businessType, ')
          ..write('operateType: $operateType, ')
          ..write('businessId: $businessId, ')
          ..write('operateData: $operateData, ')
          ..write('syncState: $syncState, ')
          ..write('syncTime: $syncTime, ')
          ..write('syncError: $syncError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      parentType,
      parentId,
      operatorId,
      operatedAt,
      businessType,
      operateType,
      businessId,
      operateData,
      syncState,
      syncTime,
      syncError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogSync &&
          other.id == this.id &&
          other.parentType == this.parentType &&
          other.parentId == this.parentId &&
          other.operatorId == this.operatorId &&
          other.operatedAt == this.operatedAt &&
          other.businessType == this.businessType &&
          other.operateType == this.operateType &&
          other.businessId == this.businessId &&
          other.operateData == this.operateData &&
          other.syncState == this.syncState &&
          other.syncTime == this.syncTime &&
          other.syncError == this.syncError);
}

class LogSyncTableCompanion extends UpdateCompanion<LogSync> {
  final Value<String> id;
  final Value<String> parentType;
  final Value<String> parentId;
  final Value<String> operatorId;
  final Value<int> operatedAt;
  final Value<String> businessType;
  final Value<String> operateType;
  final Value<String> businessId;
  final Value<String> operateData;
  final Value<String> syncState;
  final Value<int> syncTime;
  final Value<String?> syncError;
  final Value<int> rowid;
  const LogSyncTableCompanion({
    this.id = const Value.absent(),
    this.parentType = const Value.absent(),
    this.parentId = const Value.absent(),
    this.operatorId = const Value.absent(),
    this.operatedAt = const Value.absent(),
    this.businessType = const Value.absent(),
    this.operateType = const Value.absent(),
    this.businessId = const Value.absent(),
    this.operateData = const Value.absent(),
    this.syncState = const Value.absent(),
    this.syncTime = const Value.absent(),
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LogSyncTableCompanion.insert({
    required String id,
    required String parentType,
    required String parentId,
    required String operatorId,
    required int operatedAt,
    required String businessType,
    required String operateType,
    required String businessId,
    required String operateData,
    required String syncState,
    required int syncTime,
    this.syncError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        parentType = Value(parentType),
        parentId = Value(parentId),
        operatorId = Value(operatorId),
        operatedAt = Value(operatedAt),
        businessType = Value(businessType),
        operateType = Value(operateType),
        businessId = Value(businessId),
        operateData = Value(operateData),
        syncState = Value(syncState),
        syncTime = Value(syncTime);
  static Insertable<LogSync> custom({
    Expression<String>? id,
    Expression<String>? parentType,
    Expression<String>? parentId,
    Expression<String>? operatorId,
    Expression<int>? operatedAt,
    Expression<String>? businessType,
    Expression<String>? operateType,
    Expression<String>? businessId,
    Expression<String>? operateData,
    Expression<String>? syncState,
    Expression<int>? syncTime,
    Expression<String>? syncError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentType != null) 'parent_type': parentType,
      if (parentId != null) 'parent_id': parentId,
      if (operatorId != null) 'operator_id': operatorId,
      if (operatedAt != null) 'operated_at': operatedAt,
      if (businessType != null) 'business_type': businessType,
      if (operateType != null) 'operate_type': operateType,
      if (businessId != null) 'business_id': businessId,
      if (operateData != null) 'operate_data': operateData,
      if (syncState != null) 'sync_state': syncState,
      if (syncTime != null) 'sync_time': syncTime,
      if (syncError != null) 'sync_error': syncError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LogSyncTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? parentType,
      Value<String>? parentId,
      Value<String>? operatorId,
      Value<int>? operatedAt,
      Value<String>? businessType,
      Value<String>? operateType,
      Value<String>? businessId,
      Value<String>? operateData,
      Value<String>? syncState,
      Value<int>? syncTime,
      Value<String?>? syncError,
      Value<int>? rowid}) {
    return LogSyncTableCompanion(
      id: id ?? this.id,
      parentType: parentType ?? this.parentType,
      parentId: parentId ?? this.parentId,
      operatorId: operatorId ?? this.operatorId,
      operatedAt: operatedAt ?? this.operatedAt,
      businessType: businessType ?? this.businessType,
      operateType: operateType ?? this.operateType,
      businessId: businessId ?? this.businessId,
      operateData: operateData ?? this.operateData,
      syncState: syncState ?? this.syncState,
      syncTime: syncTime ?? this.syncTime,
      syncError: syncError ?? this.syncError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentType.present) {
      map['parent_type'] = Variable<String>(parentType.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (operatorId.present) {
      map['operator_id'] = Variable<String>(operatorId.value);
    }
    if (operatedAt.present) {
      map['operated_at'] = Variable<int>(operatedAt.value);
    }
    if (businessType.present) {
      map['business_type'] = Variable<String>(businessType.value);
    }
    if (operateType.present) {
      map['operate_type'] = Variable<String>(operateType.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (operateData.present) {
      map['operate_data'] = Variable<String>(operateData.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (syncTime.present) {
      map['sync_time'] = Variable<int>(syncTime.value);
    }
    if (syncError.present) {
      map['sync_error'] = Variable<String>(syncError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogSyncTableCompanion(')
          ..write('id: $id, ')
          ..write('parentType: $parentType, ')
          ..write('parentId: $parentId, ')
          ..write('operatorId: $operatorId, ')
          ..write('operatedAt: $operatedAt, ')
          ..write('businessType: $businessType, ')
          ..write('operateType: $operateType, ')
          ..write('businessId: $businessId, ')
          ..write('operateData: $operateData, ')
          ..write('syncState: $syncState, ')
          ..write('syncTime: $syncTime, ')
          ..write('syncError: $syncError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentTableTable extends AttachmentTable
    with TableInfo<$AttachmentTableTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _originNameMeta =
      const VerificationMeta('originName');
  @override
  late final GeneratedColumn<String> originName = GeneratedColumn<String>(
      'origin_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileLengthMeta =
      const VerificationMeta('fileLength');
  @override
  late final GeneratedColumn<int> fileLength = GeneratedColumn<int>(
      'file_length', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _extensionMeta =
      const VerificationMeta('extension');
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
      'extension', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentTypeMeta =
      const VerificationMeta('contentType');
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
      'content_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessCodeMeta =
      const VerificationMeta('businessCode');
  @override
  late final GeneratedColumn<String> businessCode = GeneratedColumn<String>(
      'business_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<String> businessId = GeneratedColumn<String>(
      'business_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        originName,
        fileLength,
        extension,
        contentType,
        businessCode,
        businessId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment_table';
  @override
  VerificationContext validateIntegrity(Insertable<Attachment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('origin_name')) {
      context.handle(
          _originNameMeta,
          originName.isAcceptableOrUnknown(
              data['origin_name']!, _originNameMeta));
    } else if (isInserting) {
      context.missing(_originNameMeta);
    }
    if (data.containsKey('file_length')) {
      context.handle(
          _fileLengthMeta,
          fileLength.isAcceptableOrUnknown(
              data['file_length']!, _fileLengthMeta));
    } else if (isInserting) {
      context.missing(_fileLengthMeta);
    }
    if (data.containsKey('extension')) {
      context.handle(_extensionMeta,
          extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta));
    } else if (isInserting) {
      context.missing(_extensionMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
          _contentTypeMeta,
          contentType.isAcceptableOrUnknown(
              data['content_type']!, _contentTypeMeta));
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('business_code')) {
      context.handle(
          _businessCodeMeta,
          businessCode.isAcceptableOrUnknown(
              data['business_code']!, _businessCodeMeta));
    } else if (isInserting) {
      context.missing(_businessCodeMeta);
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      originName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}origin_name'])!,
      fileLength: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_length'])!,
      extension: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extension'])!,
      contentType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_type'])!,
      businessCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_code'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_id'])!,
    );
  }

  @override
  $AttachmentTableTable createAlias(String alias) {
    return $AttachmentTableTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String originName;
  final int fileLength;
  final String extension;
  final String contentType;
  final String businessCode;
  final String businessId;
  const Attachment(
      {required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.originName,
      required this.fileLength,
      required this.extension,
      required this.contentType,
      required this.businessCode,
      required this.businessId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['origin_name'] = Variable<String>(originName);
    map['file_length'] = Variable<int>(fileLength);
    map['extension'] = Variable<String>(extension);
    map['content_type'] = Variable<String>(contentType);
    map['business_code'] = Variable<String>(businessCode);
    map['business_id'] = Variable<String>(businessId);
    return map;
  }

  AttachmentTableCompanion toCompanion(bool nullToAbsent) {
    return AttachmentTableCompanion(
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      originName: Value(originName),
      fileLength: Value(fileLength),
      extension: Value(extension),
      contentType: Value(contentType),
      businessCode: Value(businessCode),
      businessId: Value(businessId),
    );
  }

  factory Attachment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      originName: serializer.fromJson<String>(json['originName']),
      fileLength: serializer.fromJson<int>(json['fileLength']),
      extension: serializer.fromJson<String>(json['extension']),
      contentType: serializer.fromJson<String>(json['contentType']),
      businessCode: serializer.fromJson<String>(json['businessCode']),
      businessId: serializer.fromJson<String>(json['businessId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'originName': serializer.toJson<String>(originName),
      'fileLength': serializer.toJson<int>(fileLength),
      'extension': serializer.toJson<String>(extension),
      'contentType': serializer.toJson<String>(contentType),
      'businessCode': serializer.toJson<String>(businessCode),
      'businessId': serializer.toJson<String>(businessId),
    };
  }

  Attachment copyWith(
          {String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? originName,
          int? fileLength,
          String? extension,
          String? contentType,
          String? businessCode,
          String? businessId}) =>
      Attachment(
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        originName: originName ?? this.originName,
        fileLength: fileLength ?? this.fileLength,
        extension: extension ?? this.extension,
        contentType: contentType ?? this.contentType,
        businessCode: businessCode ?? this.businessCode,
        businessId: businessId ?? this.businessId,
      );
  Attachment copyWithCompanion(AttachmentTableCompanion data) {
    return Attachment(
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      originName:
          data.originName.present ? data.originName.value : this.originName,
      fileLength:
          data.fileLength.present ? data.fileLength.value : this.fileLength,
      extension: data.extension.present ? data.extension.value : this.extension,
      contentType:
          data.contentType.present ? data.contentType.value : this.contentType,
      businessCode: data.businessCode.present
          ? data.businessCode.value
          : this.businessCode,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('originName: $originName, ')
          ..write('fileLength: $fileLength, ')
          ..write('extension: $extension, ')
          ..write('contentType: $contentType, ')
          ..write('businessCode: $businessCode, ')
          ..write('businessId: $businessId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      createdBy,
      updatedBy,
      createdAt,
      updatedAt,
      id,
      originName,
      fileLength,
      extension,
      contentType,
      businessCode,
      businessId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.originName == this.originName &&
          other.fileLength == this.fileLength &&
          other.extension == this.extension &&
          other.contentType == this.contentType &&
          other.businessCode == this.businessCode &&
          other.businessId == this.businessId);
}

class AttachmentTableCompanion extends UpdateCompanion<Attachment> {
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> originName;
  final Value<int> fileLength;
  final Value<String> extension;
  final Value<String> contentType;
  final Value<String> businessCode;
  final Value<String> businessId;
  final Value<int> rowid;
  const AttachmentTableCompanion({
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.originName = const Value.absent(),
    this.fileLength = const Value.absent(),
    this.extension = const Value.absent(),
    this.contentType = const Value.absent(),
    this.businessCode = const Value.absent(),
    this.businessId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentTableCompanion.insert({
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String originName,
    required int fileLength,
    required String extension,
    required String contentType,
    required String businessCode,
    required String businessId,
    this.rowid = const Value.absent(),
  })  : createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        originName = Value(originName),
        fileLength = Value(fileLength),
        extension = Value(extension),
        contentType = Value(contentType),
        businessCode = Value(businessCode),
        businessId = Value(businessId);
  static Insertable<Attachment> custom({
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? originName,
    Expression<int>? fileLength,
    Expression<String>? extension,
    Expression<String>? contentType,
    Expression<String>? businessCode,
    Expression<String>? businessId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (originName != null) 'origin_name': originName,
      if (fileLength != null) 'file_length': fileLength,
      if (extension != null) 'extension': extension,
      if (contentType != null) 'content_type': contentType,
      if (businessCode != null) 'business_code': businessCode,
      if (businessId != null) 'business_id': businessId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentTableCompanion copyWith(
      {Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? originName,
      Value<int>? fileLength,
      Value<String>? extension,
      Value<String>? contentType,
      Value<String>? businessCode,
      Value<String>? businessId,
      Value<int>? rowid}) {
    return AttachmentTableCompanion(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      originName: originName ?? this.originName,
      fileLength: fileLength ?? this.fileLength,
      extension: extension ?? this.extension,
      contentType: contentType ?? this.contentType,
      businessCode: businessCode ?? this.businessCode,
      businessId: businessId ?? this.businessId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (originName.present) {
      map['origin_name'] = Variable<String>(originName.value);
    }
    if (fileLength.present) {
      map['file_length'] = Variable<int>(fileLength.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (businessCode.present) {
      map['business_code'] = Variable<String>(businessCode.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<String>(businessId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentTableCompanion(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('originName: $originName, ')
          ..write('fileLength: $fileLength, ')
          ..write('extension: $extension, ')
          ..write('contentType: $contentType, ')
          ..write('businessCode: $businessCode, ')
          ..write('businessId: $businessId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountNoteTableTable extends AccountNoteTable
    with TableInfo<$AccountNoteTableTable, AccountNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountNoteTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(maxTextLength: 4294967295),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _noteTypeMeta =
      const VerificationMeta('noteType');
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
      'note_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _plainContentMeta =
      const VerificationMeta('plainContent');
  @override
  late final GeneratedColumn<String> plainContent = GeneratedColumn<String>(
      'plain_content', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(maxTextLength: 4294967295),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _groupCodeMeta =
      const VerificationMeta('groupCode');
  @override
  late final GeneratedColumn<String> groupCode = GeneratedColumn<String>(
      'groupCode', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        title,
        content,
        noteType,
        plainContent,
        groupCode
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_note_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('note_type')) {
      context.handle(_noteTypeMeta,
          noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta));
    } else if (isInserting) {
      context.missing(_noteTypeMeta);
    }
    if (data.containsKey('plain_content')) {
      context.handle(
          _plainContentMeta,
          plainContent.isAcceptableOrUnknown(
              data['plain_content']!, _plainContentMeta));
    }
    if (data.containsKey('groupCode')) {
      context.handle(_groupCodeMeta,
          groupCode.isAcceptableOrUnknown(data['groupCode']!, _groupCodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountNote(
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      noteType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note_type'])!,
      plainContent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plain_content']),
      groupCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}groupCode']),
    );
  }

  @override
  $AccountNoteTableTable createAlias(String alias) {
    return $AccountNoteTableTable(attachedDatabase, alias);
  }
}

class AccountNote extends DataClass implements Insertable<AccountNote> {
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String? title;
  final String? content;
  final String noteType;
  final String? plainContent;
  final String? groupCode;
  const AccountNote(
      {required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      this.title,
      this.content,
      required this.noteType,
      this.plainContent,
      this.groupCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['note_type'] = Variable<String>(noteType);
    if (!nullToAbsent || plainContent != null) {
      map['plain_content'] = Variable<String>(plainContent);
    }
    if (!nullToAbsent || groupCode != null) {
      map['groupCode'] = Variable<String>(groupCode);
    }
    return map;
  }

  AccountNoteTableCompanion toCompanion(bool nullToAbsent) {
    return AccountNoteTableCompanion(
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      noteType: Value(noteType),
      plainContent: plainContent == null && nullToAbsent
          ? const Value.absent()
          : Value(plainContent),
      groupCode: groupCode == null && nullToAbsent
          ? const Value.absent()
          : Value(groupCode),
    );
  }

  factory AccountNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountNote(
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      noteType: serializer.fromJson<String>(json['noteType']),
      plainContent: serializer.fromJson<String?>(json['plainContent']),
      groupCode: serializer.fromJson<String?>(json['groupCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountBookId': serializer.toJson<String>(accountBookId),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'content': serializer.toJson<String?>(content),
      'noteType': serializer.toJson<String>(noteType),
      'plainContent': serializer.toJson<String?>(plainContent),
      'groupCode': serializer.toJson<String?>(groupCode),
    };
  }

  AccountNote copyWith(
          {String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          Value<String?> title = const Value.absent(),
          Value<String?> content = const Value.absent(),
          String? noteType,
          Value<String?> plainContent = const Value.absent(),
          Value<String?> groupCode = const Value.absent()}) =>
      AccountNote(
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        content: content.present ? content.value : this.content,
        noteType: noteType ?? this.noteType,
        plainContent:
            plainContent.present ? plainContent.value : this.plainContent,
        groupCode: groupCode.present ? groupCode.value : this.groupCode,
      );
  AccountNote copyWithCompanion(AccountNoteTableCompanion data) {
    return AccountNote(
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      noteType: data.noteType.present ? data.noteType.value : this.noteType,
      plainContent: data.plainContent.present
          ? data.plainContent.value
          : this.plainContent,
      groupCode: data.groupCode.present ? data.groupCode.value : this.groupCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountNote(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('noteType: $noteType, ')
          ..write('plainContent: $plainContent, ')
          ..write('groupCode: $groupCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      accountBookId,
      createdBy,
      updatedBy,
      createdAt,
      updatedAt,
      id,
      title,
      content,
      noteType,
      plainContent,
      groupCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountNote &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.title == this.title &&
          other.content == this.content &&
          other.noteType == this.noteType &&
          other.plainContent == this.plainContent &&
          other.groupCode == this.groupCode);
}

class AccountNoteTableCompanion extends UpdateCompanion<AccountNote> {
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String?> title;
  final Value<String?> content;
  final Value<String> noteType;
  final Value<String?> plainContent;
  final Value<String?> groupCode;
  final Value<int> rowid;
  const AccountNoteTableCompanion({
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.noteType = const Value.absent(),
    this.plainContent = const Value.absent(),
    this.groupCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountNoteTableCompanion.insert({
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    required String noteType,
    this.plainContent = const Value.absent(),
    this.groupCode = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        noteType = Value(noteType);
  static Insertable<AccountNote> custom({
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? noteType,
    Expression<String>? plainContent,
    Expression<String>? groupCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (noteType != null) 'note_type': noteType,
      if (plainContent != null) 'plain_content': plainContent,
      if (groupCode != null) 'groupCode': groupCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountNoteTableCompanion copyWith(
      {Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String?>? title,
      Value<String?>? content,
      Value<String>? noteType,
      Value<String?>? plainContent,
      Value<String?>? groupCode,
      Value<int>? rowid}) {
    return AccountNoteTableCompanion(
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      noteType: noteType ?? this.noteType,
      plainContent: plainContent ?? this.plainContent,
      groupCode: groupCode ?? this.groupCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (noteType.present) {
      map['note_type'] = Variable<String>(noteType.value);
    }
    if (plainContent.present) {
      map['plain_content'] = Variable<String>(plainContent.value);
    }
    if (groupCode.present) {
      map['groupCode'] = Variable<String>(groupCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountNoteTableCompanion(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('noteType: $noteType, ')
          ..write('plainContent: $plainContent, ')
          ..write('groupCode: $groupCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountDebtTableTable extends AccountDebtTable
    with TableInfo<$AccountDebtTableTable, AccountDebt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountDebtTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _debtTypeMeta =
      const VerificationMeta('debtType');
  @override
  late final GeneratedColumn<String> debtType = GeneratedColumn<String>(
      'debt_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _debtorMeta = const VerificationMeta('debtor');
  @override
  late final GeneratedColumn<String> debtor = GeneratedColumn<String>(
      'debtor', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _fundIdMeta = const VerificationMeta('fundId');
  @override
  late final GeneratedColumn<String> fundId = GeneratedColumn<String>(
      'fund_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _debtDateMeta =
      const VerificationMeta('debtDate');
  @override
  late final GeneratedColumn<String> debtDate = GeneratedColumn<String>(
      'debt_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clearDateMeta =
      const VerificationMeta('clearDate');
  @override
  late final GeneratedColumn<String> clearDate = GeneratedColumn<String>(
      'clear_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expectedClearDateMeta =
      const VerificationMeta('expectedClearDate');
  @override
  late final GeneratedColumn<String> expectedClearDate =
      GeneratedColumn<String>('expected_clear_date', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _clearStateMeta =
      const VerificationMeta('clearState');
  @override
  late final GeneratedColumn<String> clearState = GeneratedColumn<String>(
      'clear_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        debtType,
        debtor,
        amount,
        fundId,
        debtDate,
        clearDate,
        expectedClearDate,
        clearState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_debt_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountDebt> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    } else if (isInserting) {
      context.missing(_updatedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('debt_type')) {
      context.handle(_debtTypeMeta,
          debtType.isAcceptableOrUnknown(data['debt_type']!, _debtTypeMeta));
    } else if (isInserting) {
      context.missing(_debtTypeMeta);
    }
    if (data.containsKey('debtor')) {
      context.handle(_debtorMeta,
          debtor.isAcceptableOrUnknown(data['debtor']!, _debtorMeta));
    } else if (isInserting) {
      context.missing(_debtorMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('fund_id')) {
      context.handle(_fundIdMeta,
          fundId.isAcceptableOrUnknown(data['fund_id']!, _fundIdMeta));
    } else if (isInserting) {
      context.missing(_fundIdMeta);
    }
    if (data.containsKey('debt_date')) {
      context.handle(_debtDateMeta,
          debtDate.isAcceptableOrUnknown(data['debt_date']!, _debtDateMeta));
    } else if (isInserting) {
      context.missing(_debtDateMeta);
    }
    if (data.containsKey('clear_date')) {
      context.handle(_clearDateMeta,
          clearDate.isAcceptableOrUnknown(data['clear_date']!, _clearDateMeta));
    }
    if (data.containsKey('expected_clear_date')) {
      context.handle(
          _expectedClearDateMeta,
          expectedClearDate.isAcceptableOrUnknown(
              data['expected_clear_date']!, _expectedClearDateMeta));
    }
    if (data.containsKey('clear_state')) {
      context.handle(
          _clearStateMeta,
          clearState.isAcceptableOrUnknown(
              data['clear_state']!, _clearStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountDebt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountDebt(
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      debtType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}debt_type'])!,
      debtor: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}debtor'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      fundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fund_id'])!,
      debtDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}debt_date'])!,
      clearDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}clear_date']),
      expectedClearDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}expected_clear_date']),
      clearState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}clear_state'])!,
    );
  }

  @override
  $AccountDebtTableTable createAlias(String alias) {
    return $AccountDebtTableTable(attachedDatabase, alias);
  }
}

class AccountDebt extends DataClass implements Insertable<AccountDebt> {
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 债务类型（借入/借出）
  final String debtType;

  /// 债务人
  final String debtor;

  /// 金额
  final double amount;

  /// 账户ID
  final String fundId;

  /// 日期
  final String debtDate;

  /// 结清日期
  final String? clearDate;

  /// 预计结清日期
  final String? expectedClearDate;

  /// 结清状态
  final String clearState;
  const AccountDebt(
      {required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.debtType,
      required this.debtor,
      required this.amount,
      required this.fundId,
      required this.debtDate,
      this.clearDate,
      this.expectedClearDate,
      required this.clearState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['debt_type'] = Variable<String>(debtType);
    map['debtor'] = Variable<String>(debtor);
    map['amount'] = Variable<double>(amount);
    map['fund_id'] = Variable<String>(fundId);
    map['debt_date'] = Variable<String>(debtDate);
    if (!nullToAbsent || clearDate != null) {
      map['clear_date'] = Variable<String>(clearDate);
    }
    if (!nullToAbsent || expectedClearDate != null) {
      map['expected_clear_date'] = Variable<String>(expectedClearDate);
    }
    map['clear_state'] = Variable<String>(clearState);
    return map;
  }

  AccountDebtTableCompanion toCompanion(bool nullToAbsent) {
    return AccountDebtTableCompanion(
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      debtType: Value(debtType),
      debtor: Value(debtor),
      amount: Value(amount),
      fundId: Value(fundId),
      debtDate: Value(debtDate),
      clearDate: clearDate == null && nullToAbsent
          ? const Value.absent()
          : Value(clearDate),
      expectedClearDate: expectedClearDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedClearDate),
      clearState: Value(clearState),
    );
  }

  factory AccountDebt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountDebt(
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      debtType: serializer.fromJson<String>(json['debtType']),
      debtor: serializer.fromJson<String>(json['debtor']),
      amount: serializer.fromJson<double>(json['amount']),
      fundId: serializer.fromJson<String>(json['fundId']),
      debtDate: serializer.fromJson<String>(json['debtDate']),
      clearDate: serializer.fromJson<String?>(json['clearDate']),
      expectedClearDate:
          serializer.fromJson<String?>(json['expectedClearDate']),
      clearState: serializer.fromJson<String>(json['clearState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountBookId': serializer.toJson<String>(accountBookId),
      'createdBy': serializer.toJson<String>(createdBy),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'debtType': serializer.toJson<String>(debtType),
      'debtor': serializer.toJson<String>(debtor),
      'amount': serializer.toJson<double>(amount),
      'fundId': serializer.toJson<String>(fundId),
      'debtDate': serializer.toJson<String>(debtDate),
      'clearDate': serializer.toJson<String?>(clearDate),
      'expectedClearDate': serializer.toJson<String?>(expectedClearDate),
      'clearState': serializer.toJson<String>(clearState),
    };
  }

  AccountDebt copyWith(
          {String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? debtType,
          String? debtor,
          double? amount,
          String? fundId,
          String? debtDate,
          Value<String?> clearDate = const Value.absent(),
          Value<String?> expectedClearDate = const Value.absent(),
          String? clearState}) =>
      AccountDebt(
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        debtType: debtType ?? this.debtType,
        debtor: debtor ?? this.debtor,
        amount: amount ?? this.amount,
        fundId: fundId ?? this.fundId,
        debtDate: debtDate ?? this.debtDate,
        clearDate: clearDate.present ? clearDate.value : this.clearDate,
        expectedClearDate: expectedClearDate.present
            ? expectedClearDate.value
            : this.expectedClearDate,
        clearState: clearState ?? this.clearState,
      );
  AccountDebt copyWithCompanion(AccountDebtTableCompanion data) {
    return AccountDebt(
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      debtType: data.debtType.present ? data.debtType.value : this.debtType,
      debtor: data.debtor.present ? data.debtor.value : this.debtor,
      amount: data.amount.present ? data.amount.value : this.amount,
      fundId: data.fundId.present ? data.fundId.value : this.fundId,
      debtDate: data.debtDate.present ? data.debtDate.value : this.debtDate,
      clearDate: data.clearDate.present ? data.clearDate.value : this.clearDate,
      expectedClearDate: data.expectedClearDate.present
          ? data.expectedClearDate.value
          : this.expectedClearDate,
      clearState:
          data.clearState.present ? data.clearState.value : this.clearState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountDebt(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('debtType: $debtType, ')
          ..write('debtor: $debtor, ')
          ..write('amount: $amount, ')
          ..write('fundId: $fundId, ')
          ..write('debtDate: $debtDate, ')
          ..write('clearDate: $clearDate, ')
          ..write('expectedClearDate: $expectedClearDate, ')
          ..write('clearState: $clearState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      accountBookId,
      createdBy,
      updatedBy,
      createdAt,
      updatedAt,
      id,
      debtType,
      debtor,
      amount,
      fundId,
      debtDate,
      clearDate,
      expectedClearDate,
      clearState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountDebt &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.debtType == this.debtType &&
          other.debtor == this.debtor &&
          other.amount == this.amount &&
          other.fundId == this.fundId &&
          other.debtDate == this.debtDate &&
          other.clearDate == this.clearDate &&
          other.expectedClearDate == this.expectedClearDate &&
          other.clearState == this.clearState);
}

class AccountDebtTableCompanion extends UpdateCompanion<AccountDebt> {
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> debtType;
  final Value<String> debtor;
  final Value<double> amount;
  final Value<String> fundId;
  final Value<String> debtDate;
  final Value<String?> clearDate;
  final Value<String?> expectedClearDate;
  final Value<String> clearState;
  final Value<int> rowid;
  const AccountDebtTableCompanion({
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.debtType = const Value.absent(),
    this.debtor = const Value.absent(),
    this.amount = const Value.absent(),
    this.fundId = const Value.absent(),
    this.debtDate = const Value.absent(),
    this.clearDate = const Value.absent(),
    this.expectedClearDate = const Value.absent(),
    this.clearState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountDebtTableCompanion.insert({
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String debtType,
    required String debtor,
    required double amount,
    required String fundId,
    required String debtDate,
    this.clearDate = const Value.absent(),
    this.expectedClearDate = const Value.absent(),
    this.clearState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        debtType = Value(debtType),
        debtor = Value(debtor),
        amount = Value(amount),
        fundId = Value(fundId),
        debtDate = Value(debtDate);
  static Insertable<AccountDebt> custom({
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? debtType,
    Expression<String>? debtor,
    Expression<double>? amount,
    Expression<String>? fundId,
    Expression<String>? debtDate,
    Expression<String>? clearDate,
    Expression<String>? expectedClearDate,
    Expression<String>? clearState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (debtType != null) 'debt_type': debtType,
      if (debtor != null) 'debtor': debtor,
      if (amount != null) 'amount': amount,
      if (fundId != null) 'fund_id': fundId,
      if (debtDate != null) 'debt_date': debtDate,
      if (clearDate != null) 'clear_date': clearDate,
      if (expectedClearDate != null) 'expected_clear_date': expectedClearDate,
      if (clearState != null) 'clear_state': clearState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountDebtTableCompanion copyWith(
      {Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? debtType,
      Value<String>? debtor,
      Value<double>? amount,
      Value<String>? fundId,
      Value<String>? debtDate,
      Value<String?>? clearDate,
      Value<String?>? expectedClearDate,
      Value<String>? clearState,
      Value<int>? rowid}) {
    return AccountDebtTableCompanion(
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      debtType: debtType ?? this.debtType,
      debtor: debtor ?? this.debtor,
      amount: amount ?? this.amount,
      fundId: fundId ?? this.fundId,
      debtDate: debtDate ?? this.debtDate,
      clearDate: clearDate ?? this.clearDate,
      expectedClearDate: expectedClearDate ?? this.expectedClearDate,
      clearState: clearState ?? this.clearState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (debtType.present) {
      map['debt_type'] = Variable<String>(debtType.value);
    }
    if (debtor.present) {
      map['debtor'] = Variable<String>(debtor.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (fundId.present) {
      map['fund_id'] = Variable<String>(fundId.value);
    }
    if (debtDate.present) {
      map['debt_date'] = Variable<String>(debtDate.value);
    }
    if (clearDate.present) {
      map['clear_date'] = Variable<String>(clearDate.value);
    }
    if (expectedClearDate.present) {
      map['expected_clear_date'] = Variable<String>(expectedClearDate.value);
    }
    if (clearState.present) {
      map['clear_state'] = Variable<String>(clearState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountDebtTableCompanion(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('debtType: $debtType, ')
          ..write('debtor: $debtor, ')
          ..write('amount: $amount, ')
          ..write('fundId: $fundId, ')
          ..write('debtDate: $debtDate, ')
          ..write('clearDate: $clearDate, ')
          ..write('expectedClearDate: $expectedClearDate, ')
          ..write('clearState: $clearState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserTableTable userTable = $UserTableTable(this);
  late final $AccountBookTableTable accountBookTable =
      $AccountBookTableTable(this);
  late final $AccountItemTableTable accountItemTable =
      $AccountItemTableTable(this);
  late final $AccountCategoryTableTable accountCategoryTable =
      $AccountCategoryTableTable(this);
  late final $AccountFundTableTable accountFundTable =
      $AccountFundTableTable(this);
  late final $AccountShopTableTable accountShopTable =
      $AccountShopTableTable(this);
  late final $AccountSymbolTableTable accountSymbolTable =
      $AccountSymbolTableTable(this);
  late final $RelAccountbookUserTableTable relAccountbookUserTable =
      $RelAccountbookUserTableTable(this);
  late final $LogSyncTableTable logSyncTable = $LogSyncTableTable(this);
  late final $AttachmentTableTable attachmentTable =
      $AttachmentTableTable(this);
  late final $AccountNoteTableTable accountNoteTable =
      $AccountNoteTableTable(this);
  late final $AccountDebtTableTable accountDebtTable =
      $AccountDebtTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userTable,
        accountBookTable,
        accountItemTable,
        accountCategoryTable,
        accountFundTable,
        accountShopTable,
        accountSymbolTable,
        relAccountbookUserTable,
        logSyncTable,
        attachmentTable,
        accountNoteTable,
        accountDebtTable
      ];
}

typedef $$UserTableTableCreateCompanionBuilder = UserTableCompanion Function({
  required int createdAt,
  required int updatedAt,
  required String id,
  required String username,
  required String nickname,
  Value<String?> avatar,
  required String password,
  Value<String?> email,
  Value<String?> phone,
  required String inviteCode,
  Value<String> language,
  Value<String> timezone,
  Value<int> rowid,
});
typedef $$UserTableTableUpdateCompanionBuilder = UserTableCompanion Function({
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> username,
  Value<String> nickname,
  Value<String?> avatar,
  Value<String> password,
  Value<String?> email,
  Value<String?> phone,
  Value<String> inviteCode,
  Value<String> language,
  Value<String> timezone,
  Value<int> rowid,
});

class $$UserTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));
}

class $$UserTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nickname => $composableBuilder(
      column: $table.nickname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));
}

class $$UserTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserTableTable> {
  $$UserTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get inviteCode => $composableBuilder(
      column: $table.inviteCode, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);
}

class $$UserTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserTableTable,
    User,
    $$UserTableTableFilterComposer,
    $$UserTableTableOrderingComposer,
    $$UserTableTableAnnotationComposer,
    $$UserTableTableCreateCompanionBuilder,
    $$UserTableTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UserTableTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UserTableTableTableManager(_$AppDatabase db, $UserTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> nickname = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<String> password = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String> inviteCode = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTableCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            username: username,
            nickname: nickname,
            avatar: avatar,
            password: password,
            email: email,
            phone: phone,
            inviteCode: inviteCode,
            language: language,
            timezone: timezone,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int createdAt,
            required int updatedAt,
            required String id,
            required String username,
            required String nickname,
            Value<String?> avatar = const Value.absent(),
            required String password,
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            required String inviteCode,
            Value<String> language = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserTableCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            username: username,
            nickname: nickname,
            avatar: avatar,
            password: password,
            email: email,
            phone: phone,
            inviteCode: inviteCode,
            language: language,
            timezone: timezone,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserTableTable,
    User,
    $$UserTableTableFilterComposer,
    $$UserTableTableOrderingComposer,
    $$UserTableTableAnnotationComposer,
    $$UserTableTableCreateCompanionBuilder,
    $$UserTableTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UserTableTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$AccountBookTableTableCreateCompanionBuilder
    = AccountBookTableCompanion Function({
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  Value<String?> description,
  Value<String> currencySymbol,
  Value<String?> defaultFundId,
  Value<String?> icon,
  Value<int> rowid,
});
typedef $$AccountBookTableTableUpdateCompanionBuilder
    = AccountBookTableCompanion Function({
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> currencySymbol,
  Value<String?> defaultFundId,
  Value<String?> icon,
  Value<int> rowid,
});

class $$AccountBookTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountBookTableTable> {
  $$AccountBookTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultFundId => $composableBuilder(
      column: $table.defaultFundId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));
}

class $$AccountBookTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountBookTableTable> {
  $$AccountBookTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultFundId => $composableBuilder(
      column: $table.defaultFundId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));
}

class $$AccountBookTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountBookTableTable> {
  $$AccountBookTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get currencySymbol => $composableBuilder(
      column: $table.currencySymbol, builder: (column) => column);

  GeneratedColumn<String> get defaultFundId => $composableBuilder(
      column: $table.defaultFundId, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);
}

class $$AccountBookTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountBookTableTable,
    AccountBook,
    $$AccountBookTableTableFilterComposer,
    $$AccountBookTableTableOrderingComposer,
    $$AccountBookTableTableAnnotationComposer,
    $$AccountBookTableTableCreateCompanionBuilder,
    $$AccountBookTableTableUpdateCompanionBuilder,
    (
      AccountBook,
      BaseReferences<_$AppDatabase, $AccountBookTableTable, AccountBook>
    ),
    AccountBook,
    PrefetchHooks Function()> {
  $$AccountBookTableTableTableManager(
      _$AppDatabase db, $AccountBookTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountBookTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountBookTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountBookTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String?> defaultFundId = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountBookTableCompanion(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            defaultFundId: defaultFundId,
            icon: icon,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String> currencySymbol = const Value.absent(),
            Value<String?> defaultFundId = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountBookTableCompanion.insert(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            defaultFundId: defaultFundId,
            icon: icon,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountBookTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountBookTableTable,
    AccountBook,
    $$AccountBookTableTableFilterComposer,
    $$AccountBookTableTableOrderingComposer,
    $$AccountBookTableTableAnnotationComposer,
    $$AccountBookTableTableCreateCompanionBuilder,
    $$AccountBookTableTableUpdateCompanionBuilder,
    (
      AccountBook,
      BaseReferences<_$AppDatabase, $AccountBookTableTable, AccountBook>
    ),
    AccountBook,
    PrefetchHooks Function()>;
typedef $$AccountItemTableTableCreateCompanionBuilder
    = AccountItemTableCompanion Function({
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required double amount,
  Value<String?> description,
  required String type,
  Value<String?> categoryCode,
  required String accountDate,
  Value<String?> fundId,
  Value<String?> shopCode,
  Value<String?> tagCode,
  Value<String?> projectCode,
  Value<String?> source,
  Value<String?> sourceId,
  Value<int> rowid,
});
typedef $$AccountItemTableTableUpdateCompanionBuilder
    = AccountItemTableCompanion Function({
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<double> amount,
  Value<String?> description,
  Value<String> type,
  Value<String?> categoryCode,
  Value<String> accountDate,
  Value<String?> fundId,
  Value<String?> shopCode,
  Value<String?> tagCode,
  Value<String?> projectCode,
  Value<String?> source,
  Value<String?> sourceId,
  Value<int> rowid,
});

class $$AccountItemTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountItemTableTable> {
  $$AccountItemTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountDate => $composableBuilder(
      column: $table.accountDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fundId => $composableBuilder(
      column: $table.fundId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shopCode => $composableBuilder(
      column: $table.shopCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagCode => $composableBuilder(
      column: $table.tagCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));
}

class $$AccountItemTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountItemTableTable> {
  $$AccountItemTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountDate => $composableBuilder(
      column: $table.accountDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fundId => $composableBuilder(
      column: $table.fundId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shopCode => $composableBuilder(
      column: $table.shopCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagCode => $composableBuilder(
      column: $table.tagCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));
}

class $$AccountItemTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountItemTableTable> {
  $$AccountItemTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode, builder: (column) => column);

  GeneratedColumn<String> get accountDate => $composableBuilder(
      column: $table.accountDate, builder: (column) => column);

  GeneratedColumn<String> get fundId =>
      $composableBuilder(column: $table.fundId, builder: (column) => column);

  GeneratedColumn<String> get shopCode =>
      $composableBuilder(column: $table.shopCode, builder: (column) => column);

  GeneratedColumn<String> get tagCode =>
      $composableBuilder(column: $table.tagCode, builder: (column) => column);

  GeneratedColumn<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);
}

class $$AccountItemTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountItemTableTable,
    AccountItem,
    $$AccountItemTableTableFilterComposer,
    $$AccountItemTableTableOrderingComposer,
    $$AccountItemTableTableAnnotationComposer,
    $$AccountItemTableTableCreateCompanionBuilder,
    $$AccountItemTableTableUpdateCompanionBuilder,
    (
      AccountItem,
      BaseReferences<_$AppDatabase, $AccountItemTableTable, AccountItem>
    ),
    AccountItem,
    PrefetchHooks Function()> {
  $$AccountItemTableTableTableManager(
      _$AppDatabase db, $AccountItemTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountItemTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountItemTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountItemTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> categoryCode = const Value.absent(),
            Value<String> accountDate = const Value.absent(),
            Value<String?> fundId = const Value.absent(),
            Value<String?> shopCode = const Value.absent(),
            Value<String?> tagCode = const Value.absent(),
            Value<String?> projectCode = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountItemTableCompanion(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode,
            source: source,
            sourceId: sourceId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required double amount,
            Value<String?> description = const Value.absent(),
            required String type,
            Value<String?> categoryCode = const Value.absent(),
            required String accountDate,
            Value<String?> fundId = const Value.absent(),
            Value<String?> shopCode = const Value.absent(),
            Value<String?> tagCode = const Value.absent(),
            Value<String?> projectCode = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountItemTableCompanion.insert(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode,
            source: source,
            sourceId: sourceId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountItemTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountItemTableTable,
    AccountItem,
    $$AccountItemTableTableFilterComposer,
    $$AccountItemTableTableOrderingComposer,
    $$AccountItemTableTableAnnotationComposer,
    $$AccountItemTableTableCreateCompanionBuilder,
    $$AccountItemTableTableUpdateCompanionBuilder,
    (
      AccountItem,
      BaseReferences<_$AppDatabase, $AccountItemTableTable, AccountItem>
    ),
    AccountItem,
    PrefetchHooks Function()>;
typedef $$AccountCategoryTableTableCreateCompanionBuilder
    = AccountCategoryTableCompanion Function({
  Value<String?> lastAccountItemAt,
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  required String code,
  required String categoryType,
  Value<int> rowid,
});
typedef $$AccountCategoryTableTableUpdateCompanionBuilder
    = AccountCategoryTableCompanion Function({
  Value<String?> lastAccountItemAt,
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String> code,
  Value<String> categoryType,
  Value<int> rowid,
});

class $$AccountCategoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountCategoryTableTable> {
  $$AccountCategoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryType => $composableBuilder(
      column: $table.categoryType, builder: (column) => ColumnFilters(column));
}

class $$AccountCategoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountCategoryTableTable> {
  $$AccountCategoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryType => $composableBuilder(
      column: $table.categoryType,
      builder: (column) => ColumnOrderings(column));
}

class $$AccountCategoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountCategoryTableTable> {
  $$AccountCategoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt, builder: (column) => column);

  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get categoryType => $composableBuilder(
      column: $table.categoryType, builder: (column) => column);
}

class $$AccountCategoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountCategoryTableTable,
    AccountCategory,
    $$AccountCategoryTableTableFilterComposer,
    $$AccountCategoryTableTableOrderingComposer,
    $$AccountCategoryTableTableAnnotationComposer,
    $$AccountCategoryTableTableCreateCompanionBuilder,
    $$AccountCategoryTableTableUpdateCompanionBuilder,
    (
      AccountCategory,
      BaseReferences<_$AppDatabase, $AccountCategoryTableTable, AccountCategory>
    ),
    AccountCategory,
    PrefetchHooks Function()> {
  $$AccountCategoryTableTableTableManager(
      _$AppDatabase db, $AccountCategoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountCategoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountCategoryTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountCategoryTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> categoryType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountCategoryTableCompanion(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            code: code,
            categoryType: categoryType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String name,
            required String code,
            required String categoryType,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountCategoryTableCompanion.insert(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            code: code,
            categoryType: categoryType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountCategoryTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AccountCategoryTableTable,
        AccountCategory,
        $$AccountCategoryTableTableFilterComposer,
        $$AccountCategoryTableTableOrderingComposer,
        $$AccountCategoryTableTableAnnotationComposer,
        $$AccountCategoryTableTableCreateCompanionBuilder,
        $$AccountCategoryTableTableUpdateCompanionBuilder,
        (
          AccountCategory,
          BaseReferences<_$AppDatabase, $AccountCategoryTableTable,
              AccountCategory>
        ),
        AccountCategory,
        PrefetchHooks Function()>;
typedef $$AccountFundTableTableCreateCompanionBuilder
    = AccountFundTableCompanion Function({
  Value<String?> lastAccountItemAt,
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  required String fundType,
  Value<String?> fundRemark,
  Value<double> fundBalance,
  Value<bool?> isDefault,
  Value<int> rowid,
});
typedef $$AccountFundTableTableUpdateCompanionBuilder
    = AccountFundTableCompanion Function({
  Value<String?> lastAccountItemAt,
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String> fundType,
  Value<String?> fundRemark,
  Value<double> fundBalance,
  Value<bool?> isDefault,
  Value<int> rowid,
});

class $$AccountFundTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountFundTableTable> {
  $$AccountFundTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fundType => $composableBuilder(
      column: $table.fundType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fundRemark => $composableBuilder(
      column: $table.fundRemark, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fundBalance => $composableBuilder(
      column: $table.fundBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));
}

class $$AccountFundTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountFundTableTable> {
  $$AccountFundTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fundType => $composableBuilder(
      column: $table.fundType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fundRemark => $composableBuilder(
      column: $table.fundRemark, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fundBalance => $composableBuilder(
      column: $table.fundBalance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));
}

class $$AccountFundTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountFundTableTable> {
  $$AccountFundTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt, builder: (column) => column);

  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fundType =>
      $composableBuilder(column: $table.fundType, builder: (column) => column);

  GeneratedColumn<String> get fundRemark => $composableBuilder(
      column: $table.fundRemark, builder: (column) => column);

  GeneratedColumn<double> get fundBalance => $composableBuilder(
      column: $table.fundBalance, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$AccountFundTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountFundTableTable,
    AccountFund,
    $$AccountFundTableTableFilterComposer,
    $$AccountFundTableTableOrderingComposer,
    $$AccountFundTableTableAnnotationComposer,
    $$AccountFundTableTableCreateCompanionBuilder,
    $$AccountFundTableTableUpdateCompanionBuilder,
    (
      AccountFund,
      BaseReferences<_$AppDatabase, $AccountFundTableTable, AccountFund>
    ),
    AccountFund,
    PrefetchHooks Function()> {
  $$AccountFundTableTableTableManager(
      _$AppDatabase db, $AccountFundTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountFundTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountFundTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountFundTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> fundType = const Value.absent(),
            Value<String?> fundRemark = const Value.absent(),
            Value<double> fundBalance = const Value.absent(),
            Value<bool?> isDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountFundTableCompanion(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            fundType: fundType,
            fundRemark: fundRemark,
            fundBalance: fundBalance,
            isDefault: isDefault,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String name,
            required String fundType,
            Value<String?> fundRemark = const Value.absent(),
            Value<double> fundBalance = const Value.absent(),
            Value<bool?> isDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountFundTableCompanion.insert(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            fundType: fundType,
            fundRemark: fundRemark,
            fundBalance: fundBalance,
            isDefault: isDefault,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountFundTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountFundTableTable,
    AccountFund,
    $$AccountFundTableTableFilterComposer,
    $$AccountFundTableTableOrderingComposer,
    $$AccountFundTableTableAnnotationComposer,
    $$AccountFundTableTableCreateCompanionBuilder,
    $$AccountFundTableTableUpdateCompanionBuilder,
    (
      AccountFund,
      BaseReferences<_$AppDatabase, $AccountFundTableTable, AccountFund>
    ),
    AccountFund,
    PrefetchHooks Function()>;
typedef $$AccountShopTableTableCreateCompanionBuilder
    = AccountShopTableCompanion Function({
  Value<String?> lastAccountItemAt,
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  required String code,
  Value<int> rowid,
});
typedef $$AccountShopTableTableUpdateCompanionBuilder
    = AccountShopTableCompanion Function({
  Value<String?> lastAccountItemAt,
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String> code,
  Value<int> rowid,
});

class $$AccountShopTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountShopTableTable> {
  $$AccountShopTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));
}

class $$AccountShopTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountShopTableTable> {
  $$AccountShopTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));
}

class $$AccountShopTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountShopTableTable> {
  $$AccountShopTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt, builder: (column) => column);

  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);
}

class $$AccountShopTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountShopTableTable,
    AccountShop,
    $$AccountShopTableTableFilterComposer,
    $$AccountShopTableTableOrderingComposer,
    $$AccountShopTableTableAnnotationComposer,
    $$AccountShopTableTableCreateCompanionBuilder,
    $$AccountShopTableTableUpdateCompanionBuilder,
    (
      AccountShop,
      BaseReferences<_$AppDatabase, $AccountShopTableTable, AccountShop>
    ),
    AccountShop,
    PrefetchHooks Function()> {
  $$AccountShopTableTableTableManager(
      _$AppDatabase db, $AccountShopTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountShopTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountShopTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountShopTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountShopTableCompanion(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            code: code,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String name,
            required String code,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountShopTableCompanion.insert(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            code: code,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountShopTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountShopTableTable,
    AccountShop,
    $$AccountShopTableTableFilterComposer,
    $$AccountShopTableTableOrderingComposer,
    $$AccountShopTableTableAnnotationComposer,
    $$AccountShopTableTableCreateCompanionBuilder,
    $$AccountShopTableTableUpdateCompanionBuilder,
    (
      AccountShop,
      BaseReferences<_$AppDatabase, $AccountShopTableTable, AccountShop>
    ),
    AccountShop,
    PrefetchHooks Function()>;
typedef $$AccountSymbolTableTableCreateCompanionBuilder
    = AccountSymbolTableCompanion Function({
  Value<String?> lastAccountItemAt,
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  required String code,
  required String symbolType,
  Value<int> rowid,
});
typedef $$AccountSymbolTableTableUpdateCompanionBuilder
    = AccountSymbolTableCompanion Function({
  Value<String?> lastAccountItemAt,
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String> code,
  Value<String> symbolType,
  Value<int> rowid,
});

class $$AccountSymbolTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountSymbolTableTable> {
  $$AccountSymbolTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbolType => $composableBuilder(
      column: $table.symbolType, builder: (column) => ColumnFilters(column));
}

class $$AccountSymbolTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountSymbolTableTable> {
  $$AccountSymbolTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbolType => $composableBuilder(
      column: $table.symbolType, builder: (column) => ColumnOrderings(column));
}

class $$AccountSymbolTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountSymbolTableTable> {
  $$AccountSymbolTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lastAccountItemAt => $composableBuilder(
      column: $table.lastAccountItemAt, builder: (column) => column);

  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get symbolType => $composableBuilder(
      column: $table.symbolType, builder: (column) => column);
}

class $$AccountSymbolTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountSymbolTableTable,
    AccountSymbol,
    $$AccountSymbolTableTableFilterComposer,
    $$AccountSymbolTableTableOrderingComposer,
    $$AccountSymbolTableTableAnnotationComposer,
    $$AccountSymbolTableTableCreateCompanionBuilder,
    $$AccountSymbolTableTableUpdateCompanionBuilder,
    (
      AccountSymbol,
      BaseReferences<_$AppDatabase, $AccountSymbolTableTable, AccountSymbol>
    ),
    AccountSymbol,
    PrefetchHooks Function()> {
  $$AccountSymbolTableTableTableManager(
      _$AppDatabase db, $AccountSymbolTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountSymbolTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountSymbolTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountSymbolTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> symbolType = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountSymbolTableCompanion(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            code: code,
            symbolType: symbolType,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String?> lastAccountItemAt = const Value.absent(),
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String name,
            required String code,
            required String symbolType,
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountSymbolTableCompanion.insert(
            lastAccountItemAt: lastAccountItemAt,
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            code: code,
            symbolType: symbolType,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountSymbolTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountSymbolTableTable,
    AccountSymbol,
    $$AccountSymbolTableTableFilterComposer,
    $$AccountSymbolTableTableOrderingComposer,
    $$AccountSymbolTableTableAnnotationComposer,
    $$AccountSymbolTableTableCreateCompanionBuilder,
    $$AccountSymbolTableTableUpdateCompanionBuilder,
    (
      AccountSymbol,
      BaseReferences<_$AppDatabase, $AccountSymbolTableTable, AccountSymbol>
    ),
    AccountSymbol,
    PrefetchHooks Function()>;
typedef $$RelAccountbookUserTableTableCreateCompanionBuilder
    = RelAccountbookUserTableCompanion Function({
  required int createdAt,
  required int updatedAt,
  required String id,
  required String userId,
  required String accountBookId,
  Value<bool> canViewBook,
  Value<bool> canEditBook,
  Value<bool> canDeleteBook,
  Value<bool> canViewItem,
  Value<bool> canEditItem,
  Value<bool> canDeleteItem,
  Value<int> rowid,
});
typedef $$RelAccountbookUserTableTableUpdateCompanionBuilder
    = RelAccountbookUserTableCompanion Function({
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> userId,
  Value<String> accountBookId,
  Value<bool> canViewBook,
  Value<bool> canEditBook,
  Value<bool> canDeleteBook,
  Value<bool> canViewItem,
  Value<bool> canEditItem,
  Value<bool> canDeleteItem,
  Value<int> rowid,
});

class $$RelAccountbookUserTableTableFilterComposer
    extends Composer<_$AppDatabase, $RelAccountbookUserTableTable> {
  $$RelAccountbookUserTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canViewBook => $composableBuilder(
      column: $table.canViewBook, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canEditBook => $composableBuilder(
      column: $table.canEditBook, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canDeleteBook => $composableBuilder(
      column: $table.canDeleteBook, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canViewItem => $composableBuilder(
      column: $table.canViewItem, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canEditItem => $composableBuilder(
      column: $table.canEditItem, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canDeleteItem => $composableBuilder(
      column: $table.canDeleteItem, builder: (column) => ColumnFilters(column));
}

class $$RelAccountbookUserTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RelAccountbookUserTableTable> {
  $$RelAccountbookUserTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canViewBook => $composableBuilder(
      column: $table.canViewBook, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canEditBook => $composableBuilder(
      column: $table.canEditBook, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canDeleteBook => $composableBuilder(
      column: $table.canDeleteBook,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canViewItem => $composableBuilder(
      column: $table.canViewItem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canEditItem => $composableBuilder(
      column: $table.canEditItem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canDeleteItem => $composableBuilder(
      column: $table.canDeleteItem,
      builder: (column) => ColumnOrderings(column));
}

class $$RelAccountbookUserTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelAccountbookUserTableTable> {
  $$RelAccountbookUserTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<bool> get canViewBook => $composableBuilder(
      column: $table.canViewBook, builder: (column) => column);

  GeneratedColumn<bool> get canEditBook => $composableBuilder(
      column: $table.canEditBook, builder: (column) => column);

  GeneratedColumn<bool> get canDeleteBook => $composableBuilder(
      column: $table.canDeleteBook, builder: (column) => column);

  GeneratedColumn<bool> get canViewItem => $composableBuilder(
      column: $table.canViewItem, builder: (column) => column);

  GeneratedColumn<bool> get canEditItem => $composableBuilder(
      column: $table.canEditItem, builder: (column) => column);

  GeneratedColumn<bool> get canDeleteItem => $composableBuilder(
      column: $table.canDeleteItem, builder: (column) => column);
}

class $$RelAccountbookUserTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RelAccountbookUserTableTable,
    RelAccountbookUser,
    $$RelAccountbookUserTableTableFilterComposer,
    $$RelAccountbookUserTableTableOrderingComposer,
    $$RelAccountbookUserTableTableAnnotationComposer,
    $$RelAccountbookUserTableTableCreateCompanionBuilder,
    $$RelAccountbookUserTableTableUpdateCompanionBuilder,
    (
      RelAccountbookUser,
      BaseReferences<_$AppDatabase, $RelAccountbookUserTableTable,
          RelAccountbookUser>
    ),
    RelAccountbookUser,
    PrefetchHooks Function()> {
  $$RelAccountbookUserTableTableTableManager(
      _$AppDatabase db, $RelAccountbookUserTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelAccountbookUserTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RelAccountbookUserTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelAccountbookUserTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> accountBookId = const Value.absent(),
            Value<bool> canViewBook = const Value.absent(),
            Value<bool> canEditBook = const Value.absent(),
            Value<bool> canDeleteBook = const Value.absent(),
            Value<bool> canViewItem = const Value.absent(),
            Value<bool> canEditItem = const Value.absent(),
            Value<bool> canDeleteItem = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelAccountbookUserTableCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            userId: userId,
            accountBookId: accountBookId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int createdAt,
            required int updatedAt,
            required String id,
            required String userId,
            required String accountBookId,
            Value<bool> canViewBook = const Value.absent(),
            Value<bool> canEditBook = const Value.absent(),
            Value<bool> canDeleteBook = const Value.absent(),
            Value<bool> canViewItem = const Value.absent(),
            Value<bool> canEditItem = const Value.absent(),
            Value<bool> canDeleteItem = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelAccountbookUserTableCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            userId: userId,
            accountBookId: accountBookId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RelAccountbookUserTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RelAccountbookUserTableTable,
        RelAccountbookUser,
        $$RelAccountbookUserTableTableFilterComposer,
        $$RelAccountbookUserTableTableOrderingComposer,
        $$RelAccountbookUserTableTableAnnotationComposer,
        $$RelAccountbookUserTableTableCreateCompanionBuilder,
        $$RelAccountbookUserTableTableUpdateCompanionBuilder,
        (
          RelAccountbookUser,
          BaseReferences<_$AppDatabase, $RelAccountbookUserTableTable,
              RelAccountbookUser>
        ),
        RelAccountbookUser,
        PrefetchHooks Function()>;
typedef $$LogSyncTableTableCreateCompanionBuilder = LogSyncTableCompanion
    Function({
  required String id,
  required String parentType,
  required String parentId,
  required String operatorId,
  required int operatedAt,
  required String businessType,
  required String operateType,
  required String businessId,
  required String operateData,
  required String syncState,
  required int syncTime,
  Value<String?> syncError,
  Value<int> rowid,
});
typedef $$LogSyncTableTableUpdateCompanionBuilder = LogSyncTableCompanion
    Function({
  Value<String> id,
  Value<String> parentType,
  Value<String> parentId,
  Value<String> operatorId,
  Value<int> operatedAt,
  Value<String> businessType,
  Value<String> operateType,
  Value<String> businessId,
  Value<String> operateData,
  Value<String> syncState,
  Value<int> syncTime,
  Value<String?> syncError,
  Value<int> rowid,
});

class $$LogSyncTableTableFilterComposer
    extends Composer<_$AppDatabase, $LogSyncTableTable> {
  $$LogSyncTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentType => $composableBuilder(
      column: $table.parentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get operatedAt => $composableBuilder(
      column: $table.operatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessType => $composableBuilder(
      column: $table.businessType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operateType => $composableBuilder(
      column: $table.operateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operateData => $composableBuilder(
      column: $table.operateData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get syncTime => $composableBuilder(
      column: $table.syncTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnFilters(column));
}

class $$LogSyncTableTableOrderingComposer
    extends Composer<_$AppDatabase, $LogSyncTableTable> {
  $$LogSyncTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentType => $composableBuilder(
      column: $table.parentType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get operatedAt => $composableBuilder(
      column: $table.operatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessType => $composableBuilder(
      column: $table.businessType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operateType => $composableBuilder(
      column: $table.operateType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operateData => $composableBuilder(
      column: $table.operateData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get syncTime => $composableBuilder(
      column: $table.syncTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncError => $composableBuilder(
      column: $table.syncError, builder: (column) => ColumnOrderings(column));
}

class $$LogSyncTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogSyncTableTable> {
  $$LogSyncTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentType => $composableBuilder(
      column: $table.parentType, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get operatorId => $composableBuilder(
      column: $table.operatorId, builder: (column) => column);

  GeneratedColumn<int> get operatedAt => $composableBuilder(
      column: $table.operatedAt, builder: (column) => column);

  GeneratedColumn<String> get businessType => $composableBuilder(
      column: $table.businessType, builder: (column) => column);

  GeneratedColumn<String> get operateType => $composableBuilder(
      column: $table.operateType, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);

  GeneratedColumn<String> get operateData => $composableBuilder(
      column: $table.operateData, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<int> get syncTime =>
      $composableBuilder(column: $table.syncTime, builder: (column) => column);

  GeneratedColumn<String> get syncError =>
      $composableBuilder(column: $table.syncError, builder: (column) => column);
}

class $$LogSyncTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LogSyncTableTable,
    LogSync,
    $$LogSyncTableTableFilterComposer,
    $$LogSyncTableTableOrderingComposer,
    $$LogSyncTableTableAnnotationComposer,
    $$LogSyncTableTableCreateCompanionBuilder,
    $$LogSyncTableTableUpdateCompanionBuilder,
    (LogSync, BaseReferences<_$AppDatabase, $LogSyncTableTable, LogSync>),
    LogSync,
    PrefetchHooks Function()> {
  $$LogSyncTableTableTableManager(_$AppDatabase db, $LogSyncTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogSyncTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogSyncTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogSyncTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> parentType = const Value.absent(),
            Value<String> parentId = const Value.absent(),
            Value<String> operatorId = const Value.absent(),
            Value<int> operatedAt = const Value.absent(),
            Value<String> businessType = const Value.absent(),
            Value<String> operateType = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<String> operateData = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> syncTime = const Value.absent(),
            Value<String?> syncError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LogSyncTableCompanion(
            id: id,
            parentType: parentType,
            parentId: parentId,
            operatorId: operatorId,
            operatedAt: operatedAt,
            businessType: businessType,
            operateType: operateType,
            businessId: businessId,
            operateData: operateData,
            syncState: syncState,
            syncTime: syncTime,
            syncError: syncError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String parentType,
            required String parentId,
            required String operatorId,
            required int operatedAt,
            required String businessType,
            required String operateType,
            required String businessId,
            required String operateData,
            required String syncState,
            required int syncTime,
            Value<String?> syncError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LogSyncTableCompanion.insert(
            id: id,
            parentType: parentType,
            parentId: parentId,
            operatorId: operatorId,
            operatedAt: operatedAt,
            businessType: businessType,
            operateType: operateType,
            businessId: businessId,
            operateData: operateData,
            syncState: syncState,
            syncTime: syncTime,
            syncError: syncError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LogSyncTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LogSyncTableTable,
    LogSync,
    $$LogSyncTableTableFilterComposer,
    $$LogSyncTableTableOrderingComposer,
    $$LogSyncTableTableAnnotationComposer,
    $$LogSyncTableTableCreateCompanionBuilder,
    $$LogSyncTableTableUpdateCompanionBuilder,
    (LogSync, BaseReferences<_$AppDatabase, $LogSyncTableTable, LogSync>),
    LogSync,
    PrefetchHooks Function()>;
typedef $$AttachmentTableTableCreateCompanionBuilder = AttachmentTableCompanion
    Function({
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String originName,
  required int fileLength,
  required String extension,
  required String contentType,
  required String businessCode,
  required String businessId,
  Value<int> rowid,
});
typedef $$AttachmentTableTableUpdateCompanionBuilder = AttachmentTableCompanion
    Function({
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> originName,
  Value<int> fileLength,
  Value<String> extension,
  Value<String> contentType,
  Value<String> businessCode,
  Value<String> businessId,
  Value<int> rowid,
});

class $$AttachmentTableTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentTableTable> {
  $$AttachmentTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originName => $composableBuilder(
      column: $table.originName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileLength => $composableBuilder(
      column: $table.fileLength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extension => $composableBuilder(
      column: $table.extension, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentType => $composableBuilder(
      column: $table.contentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessCode => $composableBuilder(
      column: $table.businessCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnFilters(column));
}

class $$AttachmentTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentTableTable> {
  $$AttachmentTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originName => $composableBuilder(
      column: $table.originName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileLength => $composableBuilder(
      column: $table.fileLength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extension => $composableBuilder(
      column: $table.extension, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentType => $composableBuilder(
      column: $table.contentType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessCode => $composableBuilder(
      column: $table.businessCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => ColumnOrderings(column));
}

class $$AttachmentTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentTableTable> {
  $$AttachmentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originName => $composableBuilder(
      column: $table.originName, builder: (column) => column);

  GeneratedColumn<int> get fileLength => $composableBuilder(
      column: $table.fileLength, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
      column: $table.contentType, builder: (column) => column);

  GeneratedColumn<String> get businessCode => $composableBuilder(
      column: $table.businessCode, builder: (column) => column);

  GeneratedColumn<String> get businessId => $composableBuilder(
      column: $table.businessId, builder: (column) => column);
}

class $$AttachmentTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AttachmentTableTable,
    Attachment,
    $$AttachmentTableTableFilterComposer,
    $$AttachmentTableTableOrderingComposer,
    $$AttachmentTableTableAnnotationComposer,
    $$AttachmentTableTableCreateCompanionBuilder,
    $$AttachmentTableTableUpdateCompanionBuilder,
    (
      Attachment,
      BaseReferences<_$AppDatabase, $AttachmentTableTable, Attachment>
    ),
    Attachment,
    PrefetchHooks Function()> {
  $$AttachmentTableTableTableManager(
      _$AppDatabase db, $AttachmentTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> originName = const Value.absent(),
            Value<int> fileLength = const Value.absent(),
            Value<String> extension = const Value.absent(),
            Value<String> contentType = const Value.absent(),
            Value<String> businessCode = const Value.absent(),
            Value<String> businessId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentTableCompanion(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            originName: originName,
            fileLength: fileLength,
            extension: extension,
            contentType: contentType,
            businessCode: businessCode,
            businessId: businessId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String originName,
            required int fileLength,
            required String extension,
            required String contentType,
            required String businessCode,
            required String businessId,
            Value<int> rowid = const Value.absent(),
          }) =>
              AttachmentTableCompanion.insert(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            originName: originName,
            fileLength: fileLength,
            extension: extension,
            contentType: contentType,
            businessCode: businessCode,
            businessId: businessId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AttachmentTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AttachmentTableTable,
    Attachment,
    $$AttachmentTableTableFilterComposer,
    $$AttachmentTableTableOrderingComposer,
    $$AttachmentTableTableAnnotationComposer,
    $$AttachmentTableTableCreateCompanionBuilder,
    $$AttachmentTableTableUpdateCompanionBuilder,
    (
      Attachment,
      BaseReferences<_$AppDatabase, $AttachmentTableTable, Attachment>
    ),
    Attachment,
    PrefetchHooks Function()>;
typedef $$AccountNoteTableTableCreateCompanionBuilder
    = AccountNoteTableCompanion Function({
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  Value<String?> title,
  Value<String?> content,
  required String noteType,
  Value<String?> plainContent,
  Value<String?> groupCode,
  Value<int> rowid,
});
typedef $$AccountNoteTableTableUpdateCompanionBuilder
    = AccountNoteTableCompanion Function({
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String?> title,
  Value<String?> content,
  Value<String> noteType,
  Value<String?> plainContent,
  Value<String?> groupCode,
  Value<int> rowid,
});

class $$AccountNoteTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountNoteTableTable> {
  $$AccountNoteTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noteType => $composableBuilder(
      column: $table.noteType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plainContent => $composableBuilder(
      column: $table.plainContent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupCode => $composableBuilder(
      column: $table.groupCode, builder: (column) => ColumnFilters(column));
}

class $$AccountNoteTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountNoteTableTable> {
  $$AccountNoteTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noteType => $composableBuilder(
      column: $table.noteType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plainContent => $composableBuilder(
      column: $table.plainContent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupCode => $composableBuilder(
      column: $table.groupCode, builder: (column) => ColumnOrderings(column));
}

class $$AccountNoteTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountNoteTableTable> {
  $$AccountNoteTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get noteType =>
      $composableBuilder(column: $table.noteType, builder: (column) => column);

  GeneratedColumn<String> get plainContent => $composableBuilder(
      column: $table.plainContent, builder: (column) => column);

  GeneratedColumn<String> get groupCode =>
      $composableBuilder(column: $table.groupCode, builder: (column) => column);
}

class $$AccountNoteTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountNoteTableTable,
    AccountNote,
    $$AccountNoteTableTableFilterComposer,
    $$AccountNoteTableTableOrderingComposer,
    $$AccountNoteTableTableAnnotationComposer,
    $$AccountNoteTableTableCreateCompanionBuilder,
    $$AccountNoteTableTableUpdateCompanionBuilder,
    (
      AccountNote,
      BaseReferences<_$AppDatabase, $AccountNoteTableTable, AccountNote>
    ),
    AccountNote,
    PrefetchHooks Function()> {
  $$AccountNoteTableTableTableManager(
      _$AppDatabase db, $AccountNoteTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountNoteTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountNoteTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountNoteTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String> noteType = const Value.absent(),
            Value<String?> plainContent = const Value.absent(),
            Value<String?> groupCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountNoteTableCompanion(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            title: title,
            content: content,
            noteType: noteType,
            plainContent: plainContent,
            groupCode: groupCode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            Value<String?> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            required String noteType,
            Value<String?> plainContent = const Value.absent(),
            Value<String?> groupCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountNoteTableCompanion.insert(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            title: title,
            content: content,
            noteType: noteType,
            plainContent: plainContent,
            groupCode: groupCode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountNoteTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountNoteTableTable,
    AccountNote,
    $$AccountNoteTableTableFilterComposer,
    $$AccountNoteTableTableOrderingComposer,
    $$AccountNoteTableTableAnnotationComposer,
    $$AccountNoteTableTableCreateCompanionBuilder,
    $$AccountNoteTableTableUpdateCompanionBuilder,
    (
      AccountNote,
      BaseReferences<_$AppDatabase, $AccountNoteTableTable, AccountNote>
    ),
    AccountNote,
    PrefetchHooks Function()>;
typedef $$AccountDebtTableTableCreateCompanionBuilder
    = AccountDebtTableCompanion Function({
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String debtType,
  required String debtor,
  required double amount,
  required String fundId,
  required String debtDate,
  Value<String?> clearDate,
  Value<String?> expectedClearDate,
  Value<String> clearState,
  Value<int> rowid,
});
typedef $$AccountDebtTableTableUpdateCompanionBuilder
    = AccountDebtTableCompanion Function({
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> debtType,
  Value<String> debtor,
  Value<double> amount,
  Value<String> fundId,
  Value<String> debtDate,
  Value<String?> clearDate,
  Value<String?> expectedClearDate,
  Value<String> clearState,
  Value<int> rowid,
});

class $$AccountDebtTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountDebtTableTable> {
  $$AccountDebtTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get debtType => $composableBuilder(
      column: $table.debtType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get debtor => $composableBuilder(
      column: $table.debtor, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fundId => $composableBuilder(
      column: $table.fundId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get debtDate => $composableBuilder(
      column: $table.debtDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clearDate => $composableBuilder(
      column: $table.clearDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expectedClearDate => $composableBuilder(
      column: $table.expectedClearDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clearState => $composableBuilder(
      column: $table.clearState, builder: (column) => ColumnFilters(column));
}

class $$AccountDebtTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountDebtTableTable> {
  $$AccountDebtTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get debtType => $composableBuilder(
      column: $table.debtType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get debtor => $composableBuilder(
      column: $table.debtor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fundId => $composableBuilder(
      column: $table.fundId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get debtDate => $composableBuilder(
      column: $table.debtDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clearDate => $composableBuilder(
      column: $table.clearDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expectedClearDate => $composableBuilder(
      column: $table.expectedClearDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clearState => $composableBuilder(
      column: $table.clearState, builder: (column) => ColumnOrderings(column));
}

class $$AccountDebtTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountDebtTableTable> {
  $$AccountDebtTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get debtType =>
      $composableBuilder(column: $table.debtType, builder: (column) => column);

  GeneratedColumn<String> get debtor =>
      $composableBuilder(column: $table.debtor, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get fundId =>
      $composableBuilder(column: $table.fundId, builder: (column) => column);

  GeneratedColumn<String> get debtDate =>
      $composableBuilder(column: $table.debtDate, builder: (column) => column);

  GeneratedColumn<String> get clearDate =>
      $composableBuilder(column: $table.clearDate, builder: (column) => column);

  GeneratedColumn<String> get expectedClearDate => $composableBuilder(
      column: $table.expectedClearDate, builder: (column) => column);

  GeneratedColumn<String> get clearState => $composableBuilder(
      column: $table.clearState, builder: (column) => column);
}

class $$AccountDebtTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountDebtTableTable,
    AccountDebt,
    $$AccountDebtTableTableFilterComposer,
    $$AccountDebtTableTableOrderingComposer,
    $$AccountDebtTableTableAnnotationComposer,
    $$AccountDebtTableTableCreateCompanionBuilder,
    $$AccountDebtTableTableUpdateCompanionBuilder,
    (
      AccountDebt,
      BaseReferences<_$AppDatabase, $AccountDebtTableTable, AccountDebt>
    ),
    AccountDebt,
    PrefetchHooks Function()> {
  $$AccountDebtTableTableTableManager(
      _$AppDatabase db, $AccountDebtTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountDebtTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountDebtTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountDebtTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> debtType = const Value.absent(),
            Value<String> debtor = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> fundId = const Value.absent(),
            Value<String> debtDate = const Value.absent(),
            Value<String?> clearDate = const Value.absent(),
            Value<String?> expectedClearDate = const Value.absent(),
            Value<String> clearState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountDebtTableCompanion(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            debtType: debtType,
            debtor: debtor,
            amount: amount,
            fundId: fundId,
            debtDate: debtDate,
            clearDate: clearDate,
            expectedClearDate: expectedClearDate,
            clearState: clearState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String debtType,
            required String debtor,
            required double amount,
            required String fundId,
            required String debtDate,
            Value<String?> clearDate = const Value.absent(),
            Value<String?> expectedClearDate = const Value.absent(),
            Value<String> clearState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountDebtTableCompanion.insert(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            debtType: debtType,
            debtor: debtor,
            amount: amount,
            fundId: fundId,
            debtDate: debtDate,
            clearDate: clearDate,
            expectedClearDate: expectedClearDate,
            clearState: clearState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountDebtTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountDebtTableTable,
    AccountDebt,
    $$AccountDebtTableTableFilterComposer,
    $$AccountDebtTableTableOrderingComposer,
    $$AccountDebtTableTableAnnotationComposer,
    $$AccountDebtTableTableCreateCompanionBuilder,
    $$AccountDebtTableTableUpdateCompanionBuilder,
    (
      AccountDebt,
      BaseReferences<_$AppDatabase, $AccountDebtTableTable, AccountDebt>
    ),
    AccountDebt,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserTableTableTableManager get userTable =>
      $$UserTableTableTableManager(_db, _db.userTable);
  $$AccountBookTableTableTableManager get accountBookTable =>
      $$AccountBookTableTableTableManager(_db, _db.accountBookTable);
  $$AccountItemTableTableTableManager get accountItemTable =>
      $$AccountItemTableTableTableManager(_db, _db.accountItemTable);
  $$AccountCategoryTableTableTableManager get accountCategoryTable =>
      $$AccountCategoryTableTableTableManager(_db, _db.accountCategoryTable);
  $$AccountFundTableTableTableManager get accountFundTable =>
      $$AccountFundTableTableTableManager(_db, _db.accountFundTable);
  $$AccountShopTableTableTableManager get accountShopTable =>
      $$AccountShopTableTableTableManager(_db, _db.accountShopTable);
  $$AccountSymbolTableTableTableManager get accountSymbolTable =>
      $$AccountSymbolTableTableTableManager(_db, _db.accountSymbolTable);
  $$RelAccountbookUserTableTableTableManager get relAccountbookUserTable =>
      $$RelAccountbookUserTableTableTableManager(
          _db, _db.relAccountbookUserTable);
  $$LogSyncTableTableTableManager get logSyncTable =>
      $$LogSyncTableTableTableManager(_db, _db.logSyncTable);
  $$AttachmentTableTableTableManager get attachmentTable =>
      $$AttachmentTableTableTableManager(_db, _db.attachmentTable);
  $$AccountNoteTableTableTableManager get accountNoteTable =>
      $$AccountNoteTableTableTableManager(_db, _db.accountNoteTable);
  $$AccountDebtTableTableTableManager get accountDebtTable =>
      $$AccountDebtTableTableTableManager(_db, _db.accountDebtTable);
}
