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
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isBookkeepingSelectableMeta =
      const VerificationMeta('isBookkeepingSelectable');
  @override
  late final GeneratedColumn<bool> isBookkeepingSelectable =
      GeneratedColumn<bool>('is_bookkeeping_selectable', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("is_bookkeeping_selectable" IN (0, 1))'),
          defaultValue: const Constant(true));
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
        categoryType,
        parentId,
        sortOrder,
        isBookkeepingSelectable
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
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_bookkeeping_selectable')) {
      context.handle(
          _isBookkeepingSelectableMeta,
          isBookkeepingSelectable.isAcceptableOrUnknown(
              data['is_bookkeeping_selectable']!,
              _isBookkeepingSelectableMeta));
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
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isBookkeepingSelectable: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}is_bookkeeping_selectable'])!,
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
  final String? parentId;
  final int sortOrder;
  final bool isBookkeepingSelectable;
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
      required this.categoryType,
      this.parentId,
      required this.sortOrder,
      required this.isBookkeepingSelectable});
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
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_bookkeeping_selectable'] = Variable<bool>(isBookkeepingSelectable);
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
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: Value(sortOrder),
      isBookkeepingSelectable: Value(isBookkeepingSelectable),
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
      parentId: serializer.fromJson<String?>(json['parentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isBookkeepingSelectable:
          serializer.fromJson<bool>(json['isBookkeepingSelectable']),
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
      'parentId': serializer.toJson<String?>(parentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isBookkeepingSelectable':
          serializer.toJson<bool>(isBookkeepingSelectable),
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
          String? categoryType,
          Value<String?> parentId = const Value.absent(),
          int? sortOrder,
          bool? isBookkeepingSelectable}) =>
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
        parentId: parentId.present ? parentId.value : this.parentId,
        sortOrder: sortOrder ?? this.sortOrder,
        isBookkeepingSelectable:
            isBookkeepingSelectable ?? this.isBookkeepingSelectable,
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
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isBookkeepingSelectable: data.isBookkeepingSelectable.present
          ? data.isBookkeepingSelectable.value
          : this.isBookkeepingSelectable,
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
          ..write('categoryType: $categoryType, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBookkeepingSelectable: $isBookkeepingSelectable')
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
      code,
      categoryType,
      parentId,
      sortOrder,
      isBookkeepingSelectable);
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
          other.categoryType == this.categoryType &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder &&
          other.isBookkeepingSelectable == this.isBookkeepingSelectable);
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
  final Value<String?> parentId;
  final Value<int> sortOrder;
  final Value<bool> isBookkeepingSelectable;
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
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBookkeepingSelectable = const Value.absent(),
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
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBookkeepingSelectable = const Value.absent(),
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
    Expression<String>? parentId,
    Expression<int>? sortOrder,
    Expression<bool>? isBookkeepingSelectable,
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
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isBookkeepingSelectable != null)
        'is_bookkeeping_selectable': isBookkeepingSelectable,
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
      Value<String?>? parentId,
      Value<int>? sortOrder,
      Value<bool>? isBookkeepingSelectable,
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
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isBookkeepingSelectable:
          isBookkeepingSelectable ?? this.isBookkeepingSelectable,
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
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isBookkeepingSelectable.present) {
      map['is_bookkeeping_selectable'] =
          Variable<bool>(isBookkeepingSelectable.value);
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
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBookkeepingSelectable: $isBookkeepingSelectable, ')
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
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isBookkeepingSelectableMeta =
      const VerificationMeta('isBookkeepingSelectable');
  @override
  late final GeneratedColumn<bool> isBookkeepingSelectable =
      GeneratedColumn<bool>('is_bookkeeping_selectable', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("is_bookkeeping_selectable" IN (0, 1))'),
          defaultValue: const Constant(true));
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
        parentId,
        sortOrder,
        isBookkeepingSelectable
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
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_bookkeeping_selectable')) {
      context.handle(
          _isBookkeepingSelectableMeta,
          isBookkeepingSelectable.isAcceptableOrUnknown(
              data['is_bookkeeping_selectable']!,
              _isBookkeepingSelectableMeta));
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
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isBookkeepingSelectable: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}is_bookkeeping_selectable'])!,
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
  final String? parentId;
  final int sortOrder;
  final bool isBookkeepingSelectable;
  const AccountShop(
      {this.lastAccountItemAt,
      required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      required this.code,
      this.parentId,
      required this.sortOrder,
      required this.isBookkeepingSelectable});
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
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_bookkeeping_selectable'] = Variable<bool>(isBookkeepingSelectable);
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
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: Value(sortOrder),
      isBookkeepingSelectable: Value(isBookkeepingSelectable),
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
      parentId: serializer.fromJson<String?>(json['parentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isBookkeepingSelectable:
          serializer.fromJson<bool>(json['isBookkeepingSelectable']),
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
      'parentId': serializer.toJson<String?>(parentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isBookkeepingSelectable':
          serializer.toJson<bool>(isBookkeepingSelectable),
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
          String? code,
          Value<String?> parentId = const Value.absent(),
          int? sortOrder,
          bool? isBookkeepingSelectable}) =>
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
        parentId: parentId.present ? parentId.value : this.parentId,
        sortOrder: sortOrder ?? this.sortOrder,
        isBookkeepingSelectable:
            isBookkeepingSelectable ?? this.isBookkeepingSelectable,
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
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isBookkeepingSelectable: data.isBookkeepingSelectable.present
          ? data.isBookkeepingSelectable.value
          : this.isBookkeepingSelectable,
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
          ..write('code: $code, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBookkeepingSelectable: $isBookkeepingSelectable')
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
      code,
      parentId,
      sortOrder,
      isBookkeepingSelectable);
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
          other.code == this.code &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder &&
          other.isBookkeepingSelectable == this.isBookkeepingSelectable);
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
  final Value<String?> parentId;
  final Value<int> sortOrder;
  final Value<bool> isBookkeepingSelectable;
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
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBookkeepingSelectable = const Value.absent(),
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
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBookkeepingSelectable = const Value.absent(),
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
    Expression<String>? parentId,
    Expression<int>? sortOrder,
    Expression<bool>? isBookkeepingSelectable,
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
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isBookkeepingSelectable != null)
        'is_bookkeeping_selectable': isBookkeepingSelectable,
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
      Value<String?>? parentId,
      Value<int>? sortOrder,
      Value<bool>? isBookkeepingSelectable,
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
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isBookkeepingSelectable:
          isBookkeepingSelectable ?? this.isBookkeepingSelectable,
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
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isBookkeepingSelectable.present) {
      map['is_bookkeeping_selectable'] =
          Variable<bool>(isBookkeepingSelectable.value);
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
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBookkeepingSelectable: $isBookkeepingSelectable, ')
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
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('book'));
  static const VerificationMeta _templateMeta =
      const VerificationMeta('template');
  @override
  late final GeneratedColumn<String> template = GeneratedColumn<String>(
      'template', aliasedName, true,
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
        groupCode,
        scope,
        template
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
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    }
    if (data.containsKey('template')) {
      context.handle(_templateMeta,
          template.isAcceptableOrUnknown(data['template']!, _templateMeta));
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
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope'])!,
      template: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template']),
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
  final String scope;
  final String? template;
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
      this.groupCode,
      required this.scope,
      this.template});
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
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || template != null) {
      map['template'] = Variable<String>(template);
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
      scope: Value(scope),
      template: template == null && nullToAbsent
          ? const Value.absent()
          : Value(template),
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
      scope: serializer.fromJson<String>(json['scope']),
      template: serializer.fromJson<String?>(json['template']),
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
      'scope': serializer.toJson<String>(scope),
      'template': serializer.toJson<String?>(template),
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
          Value<String?> groupCode = const Value.absent(),
          String? scope,
          Value<String?> template = const Value.absent()}) =>
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
        scope: scope ?? this.scope,
        template: template.present ? template.value : this.template,
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
      scope: data.scope.present ? data.scope.value : this.scope,
      template: data.template.present ? data.template.value : this.template,
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
          ..write('groupCode: $groupCode, ')
          ..write('scope: $scope, ')
          ..write('template: $template')
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
      groupCode,
      scope,
      template);
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
          other.groupCode == this.groupCode &&
          other.scope == this.scope &&
          other.template == this.template);
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
  final Value<String> scope;
  final Value<String?> template;
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
    this.scope = const Value.absent(),
    this.template = const Value.absent(),
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
    this.scope = const Value.absent(),
    this.template = const Value.absent(),
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
    Expression<String>? scope,
    Expression<String>? template,
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
      if (scope != null) 'scope': scope,
      if (template != null) 'template': template,
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
      Value<String>? scope,
      Value<String?>? template,
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
      scope: scope ?? this.scope,
      template: template ?? this.template,
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
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (template.present) {
      map['template'] = Variable<String>(template.value);
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
          ..write('scope: $scope, ')
          ..write('template: $template, ')
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

class $GiftCardTableTable extends GiftCardTable
    with TableInfo<$GiftCardTableTable, GiftCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GiftCardTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fromUserIdMeta =
      const VerificationMeta('fromUserId');
  @override
  late final GeneratedColumn<String> fromUserId = GeneratedColumn<String>(
      'from_user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _toUserIdMeta =
      const VerificationMeta('toUserId');
  @override
  late final GeneratedColumn<String> toUserId = GeneratedColumn<String>(
      'to_user_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'gift_description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiredTimeMeta =
      const VerificationMeta('expiredTime');
  @override
  late final GeneratedColumn<int> expiredTime = GeneratedColumn<int>(
      'expired_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sentTimeMeta =
      const VerificationMeta('sentTime');
  @override
  late final GeneratedColumn<int> sentTime = GeneratedColumn<int>(
      'sent_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _receivedTimeMeta =
      const VerificationMeta('receivedTime');
  @override
  late final GeneratedColumn<int> receivedTime = GeneratedColumn<int>(
      'received_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  @override
  List<GeneratedColumn> get $columns => [
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        fromUserId,
        toUserId,
        description,
        expiredTime,
        sentTime,
        receivedTime,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gift_card_table';
  @override
  VerificationContext validateIntegrity(Insertable<GiftCard> instance,
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
    if (data.containsKey('from_user_id')) {
      context.handle(
          _fromUserIdMeta,
          fromUserId.isAcceptableOrUnknown(
              data['from_user_id']!, _fromUserIdMeta));
    } else if (isInserting) {
      context.missing(_fromUserIdMeta);
    }
    if (data.containsKey('to_user_id')) {
      context.handle(_toUserIdMeta,
          toUserId.isAcceptableOrUnknown(data['to_user_id']!, _toUserIdMeta));
    } else if (isInserting) {
      context.missing(_toUserIdMeta);
    }
    if (data.containsKey('gift_description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['gift_description']!, _descriptionMeta));
    }
    if (data.containsKey('expired_time')) {
      context.handle(
          _expiredTimeMeta,
          expiredTime.isAcceptableOrUnknown(
              data['expired_time']!, _expiredTimeMeta));
    }
    if (data.containsKey('sent_time')) {
      context.handle(_sentTimeMeta,
          sentTime.isAcceptableOrUnknown(data['sent_time']!, _sentTimeMeta));
    }
    if (data.containsKey('received_time')) {
      context.handle(
          _receivedTimeMeta,
          receivedTime.isAcceptableOrUnknown(
              data['received_time']!, _receivedTimeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GiftCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GiftCard(
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
      fromUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_user_id'])!,
      toUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_user_id'])!,
      description: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}gift_description']),
      expiredTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expired_time'])!,
      sentTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sent_time'])!,
      receivedTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}received_time'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $GiftCardTableTable createAlias(String alias) {
    return $GiftCardTableTable(attachedDatabase, alias);
  }
}

class GiftCard extends DataClass implements Insertable<GiftCard> {
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 赠送人用户ID
  final String fromUserId;

  /// 接收人用户ID
  final String toUserId;

  /// 礼品描述
  final String? description;

  /// 过期时间 (毫秒时间戳，0表示永久有效)
  final int expiredTime;

  /// 送出时间 (毫秒时间戳)
  final int sentTime;

  /// 接收时间 (毫秒时间戳)
  final int receivedTime;

  /// 状态: draft(草稿), sent(已送出), received(已接收), used(已使用), expired(已过期), voided(已作废)
  final String status;
  const GiftCard(
      {required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.fromUserId,
      required this.toUserId,
      this.description,
      required this.expiredTime,
      required this.sentTime,
      required this.receivedTime,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['from_user_id'] = Variable<String>(fromUserId);
    map['to_user_id'] = Variable<String>(toUserId);
    if (!nullToAbsent || description != null) {
      map['gift_description'] = Variable<String>(description);
    }
    map['expired_time'] = Variable<int>(expiredTime);
    map['sent_time'] = Variable<int>(sentTime);
    map['received_time'] = Variable<int>(receivedTime);
    map['status'] = Variable<String>(status);
    return map;
  }

  GiftCardTableCompanion toCompanion(bool nullToAbsent) {
    return GiftCardTableCompanion(
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      fromUserId: Value(fromUserId),
      toUserId: Value(toUserId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      expiredTime: Value(expiredTime),
      sentTime: Value(sentTime),
      receivedTime: Value(receivedTime),
      status: Value(status),
    );
  }

  factory GiftCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GiftCard(
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      fromUserId: serializer.fromJson<String>(json['fromUserId']),
      toUserId: serializer.fromJson<String>(json['toUserId']),
      description: serializer.fromJson<String?>(json['description']),
      expiredTime: serializer.fromJson<int>(json['expiredTime']),
      sentTime: serializer.fromJson<int>(json['sentTime']),
      receivedTime: serializer.fromJson<int>(json['receivedTime']),
      status: serializer.fromJson<String>(json['status']),
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
      'fromUserId': serializer.toJson<String>(fromUserId),
      'toUserId': serializer.toJson<String>(toUserId),
      'description': serializer.toJson<String?>(description),
      'expiredTime': serializer.toJson<int>(expiredTime),
      'sentTime': serializer.toJson<int>(sentTime),
      'receivedTime': serializer.toJson<int>(receivedTime),
      'status': serializer.toJson<String>(status),
    };
  }

  GiftCard copyWith(
          {String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? fromUserId,
          String? toUserId,
          Value<String?> description = const Value.absent(),
          int? expiredTime,
          int? sentTime,
          int? receivedTime,
          String? status}) =>
      GiftCard(
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        fromUserId: fromUserId ?? this.fromUserId,
        toUserId: toUserId ?? this.toUserId,
        description: description.present ? description.value : this.description,
        expiredTime: expiredTime ?? this.expiredTime,
        sentTime: sentTime ?? this.sentTime,
        receivedTime: receivedTime ?? this.receivedTime,
        status: status ?? this.status,
      );
  GiftCard copyWithCompanion(GiftCardTableCompanion data) {
    return GiftCard(
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      fromUserId:
          data.fromUserId.present ? data.fromUserId.value : this.fromUserId,
      toUserId: data.toUserId.present ? data.toUserId.value : this.toUserId,
      description:
          data.description.present ? data.description.value : this.description,
      expiredTime:
          data.expiredTime.present ? data.expiredTime.value : this.expiredTime,
      sentTime: data.sentTime.present ? data.sentTime.value : this.sentTime,
      receivedTime: data.receivedTime.present
          ? data.receivedTime.value
          : this.receivedTime,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GiftCard(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('toUserId: $toUserId, ')
          ..write('description: $description, ')
          ..write('expiredTime: $expiredTime, ')
          ..write('sentTime: $sentTime, ')
          ..write('receivedTime: $receivedTime, ')
          ..write('status: $status')
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
      fromUserId,
      toUserId,
      description,
      expiredTime,
      sentTime,
      receivedTime,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GiftCard &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.fromUserId == this.fromUserId &&
          other.toUserId == this.toUserId &&
          other.description == this.description &&
          other.expiredTime == this.expiredTime &&
          other.sentTime == this.sentTime &&
          other.receivedTime == this.receivedTime &&
          other.status == this.status);
}

class GiftCardTableCompanion extends UpdateCompanion<GiftCard> {
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> fromUserId;
  final Value<String> toUserId;
  final Value<String?> description;
  final Value<int> expiredTime;
  final Value<int> sentTime;
  final Value<int> receivedTime;
  final Value<String> status;
  final Value<int> rowid;
  const GiftCardTableCompanion({
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.fromUserId = const Value.absent(),
    this.toUserId = const Value.absent(),
    this.description = const Value.absent(),
    this.expiredTime = const Value.absent(),
    this.sentTime = const Value.absent(),
    this.receivedTime = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GiftCardTableCompanion.insert({
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String fromUserId,
    required String toUserId,
    this.description = const Value.absent(),
    this.expiredTime = const Value.absent(),
    this.sentTime = const Value.absent(),
    this.receivedTime = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        fromUserId = Value(fromUserId),
        toUserId = Value(toUserId);
  static Insertable<GiftCard> custom({
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? fromUserId,
    Expression<String>? toUserId,
    Expression<String>? description,
    Expression<int>? expiredTime,
    Expression<int>? sentTime,
    Expression<int>? receivedTime,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (fromUserId != null) 'from_user_id': fromUserId,
      if (toUserId != null) 'to_user_id': toUserId,
      if (description != null) 'gift_description': description,
      if (expiredTime != null) 'expired_time': expiredTime,
      if (sentTime != null) 'sent_time': sentTime,
      if (receivedTime != null) 'received_time': receivedTime,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GiftCardTableCompanion copyWith(
      {Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? fromUserId,
      Value<String>? toUserId,
      Value<String?>? description,
      Value<int>? expiredTime,
      Value<int>? sentTime,
      Value<int>? receivedTime,
      Value<String>? status,
      Value<int>? rowid}) {
    return GiftCardTableCompanion(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      description: description ?? this.description,
      expiredTime: expiredTime ?? this.expiredTime,
      sentTime: sentTime ?? this.sentTime,
      receivedTime: receivedTime ?? this.receivedTime,
      status: status ?? this.status,
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
    if (fromUserId.present) {
      map['from_user_id'] = Variable<String>(fromUserId.value);
    }
    if (toUserId.present) {
      map['to_user_id'] = Variable<String>(toUserId.value);
    }
    if (description.present) {
      map['gift_description'] = Variable<String>(description.value);
    }
    if (expiredTime.present) {
      map['expired_time'] = Variable<int>(expiredTime.value);
    }
    if (sentTime.present) {
      map['sent_time'] = Variable<int>(sentTime.value);
    }
    if (receivedTime.present) {
      map['received_time'] = Variable<int>(receivedTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GiftCardTableCompanion(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('fromUserId: $fromUserId, ')
          ..write('toUserId: $toUserId, ')
          ..write('description: $description, ')
          ..write('expiredTime: $expiredTime, ')
          ..write('sentTime: $sentTime, ')
          ..write('receivedTime: $receivedTime, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityDefinitionTableTable extends ActivityDefinitionTable
    with TableInfo<$ActivityDefinitionTableTable, ActivityDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityDefinitionTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxDailyCountMeta =
      const VerificationMeta('maxDailyCount');
  @override
  late final GeneratedColumn<int> maxDailyCount = GeneratedColumn<int>(
      'max_daily_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        name,
        emoji,
        color,
        sortOrder,
        maxDailyCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_definition_table';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityDefinition> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('max_daily_count')) {
      context.handle(
          _maxDailyCountMeta,
          maxDailyCount.isAcceptableOrUnknown(
              data['max_daily_count']!, _maxDailyCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityDefinition(
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
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      maxDailyCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_daily_count']),
    );
  }

  @override
  $ActivityDefinitionTableTable createAlias(String alias) {
    return $ActivityDefinitionTableTable(attachedDatabase, alias);
  }
}

class ActivityDefinition extends DataClass
    implements Insertable<ActivityDefinition> {
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 活动名称
  final String name;

  /// 活动图标
  final String emoji;

  /// 活动颜色
  final int color;

  /// 排序序号
  final int sortOrder;

  /// 每日最大打卡次数 (null=不限制)
  final int? maxDailyCount;
  const ActivityDefinition(
      {required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      required this.emoji,
      required this.color,
      required this.sortOrder,
      this.maxDailyCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['emoji'] = Variable<String>(emoji);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || maxDailyCount != null) {
      map['max_daily_count'] = Variable<int>(maxDailyCount);
    }
    return map;
  }

  ActivityDefinitionTableCompanion toCompanion(bool nullToAbsent) {
    return ActivityDefinitionTableCompanion(
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
      sortOrder: Value(sortOrder),
      maxDailyCount: maxDailyCount == null && nullToAbsent
          ? const Value.absent()
          : Value(maxDailyCount),
    );
  }

  factory ActivityDefinition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityDefinition(
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      emoji: serializer.fromJson<String>(json['emoji']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      maxDailyCount: serializer.fromJson<int?>(json['maxDailyCount']),
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
      'name': serializer.toJson<String>(name),
      'emoji': serializer.toJson<String>(emoji),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'maxDailyCount': serializer.toJson<int?>(maxDailyCount),
    };
  }

  ActivityDefinition copyWith(
          {String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? name,
          String? emoji,
          int? color,
          int? sortOrder,
          Value<int?> maxDailyCount = const Value.absent()}) =>
      ActivityDefinition(
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        maxDailyCount:
            maxDailyCount.present ? maxDailyCount.value : this.maxDailyCount,
      );
  ActivityDefinition copyWithCompanion(ActivityDefinitionTableCompanion data) {
    return ActivityDefinition(
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      maxDailyCount: data.maxDailyCount.present
          ? data.maxDailyCount.value
          : this.maxDailyCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityDefinition(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('maxDailyCount: $maxDailyCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(accountBookId, createdBy, updatedBy,
      createdAt, updatedAt, id, name, emoji, color, sortOrder, maxDailyCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityDefinition &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.emoji == this.emoji &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.maxDailyCount == this.maxDailyCount);
}

class ActivityDefinitionTableCompanion
    extends UpdateCompanion<ActivityDefinition> {
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<String> emoji;
  final Value<int> color;
  final Value<int> sortOrder;
  final Value<int?> maxDailyCount;
  final Value<int> rowid;
  const ActivityDefinitionTableCompanion({
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.emoji = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.maxDailyCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityDefinitionTableCompanion.insert({
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    required String emoji,
    required int color,
    this.sortOrder = const Value.absent(),
    this.maxDailyCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        name = Value(name),
        emoji = Value(emoji),
        color = Value(color);
  static Insertable<ActivityDefinition> custom({
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? emoji,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<int>? maxDailyCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (emoji != null) 'emoji': emoji,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (maxDailyCount != null) 'max_daily_count': maxDailyCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityDefinitionTableCompanion copyWith(
      {Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<String>? emoji,
      Value<int>? color,
      Value<int>? sortOrder,
      Value<int?>? maxDailyCount,
      Value<int>? rowid}) {
    return ActivityDefinitionTableCompanion(
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      maxDailyCount: maxDailyCount ?? this.maxDailyCount,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (maxDailyCount.present) {
      map['max_daily_count'] = Variable<int>(maxDailyCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityDefinitionTableCompanion(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('emoji: $emoji, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('maxDailyCount: $maxDailyCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityRecordTableTable extends ActivityRecordTable
    with TableInfo<$ActivityRecordTableTable, ActivityRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityRecordTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _activityNameMeta =
      const VerificationMeta('activityName');
  @override
  late final GeneratedColumn<String> activityName = GeneratedColumn<String>(
      'activity_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordDateMeta =
      const VerificationMeta('recordDate');
  @override
  late final GeneratedColumn<String> recordDate = GeneratedColumn<String>(
      'record_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activityDefIdMeta =
      const VerificationMeta('activityDefId');
  @override
  late final GeneratedColumn<String> activityDefId = GeneratedColumn<String>(
      'activity_def_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _maxDailyCountMeta =
      const VerificationMeta('maxDailyCount');
  @override
  late final GeneratedColumn<int> maxDailyCount = GeneratedColumn<int>(
      'max_daily_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        activityName,
        location,
        recordDate,
        activityDefId,
        maxDailyCount,
        remark
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_record_table';
  @override
  VerificationContext validateIntegrity(Insertable<ActivityRecord> instance,
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
    if (data.containsKey('activity_name')) {
      context.handle(
          _activityNameMeta,
          activityName.isAcceptableOrUnknown(
              data['activity_name']!, _activityNameMeta));
    } else if (isInserting) {
      context.missing(_activityNameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('record_date')) {
      context.handle(
          _recordDateMeta,
          recordDate.isAcceptableOrUnknown(
              data['record_date']!, _recordDateMeta));
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('activity_def_id')) {
      context.handle(
          _activityDefIdMeta,
          activityDefId.isAcceptableOrUnknown(
              data['activity_def_id']!, _activityDefIdMeta));
    }
    if (data.containsKey('max_daily_count')) {
      context.handle(
          _maxDailyCountMeta,
          maxDailyCount.isAcceptableOrUnknown(
              data['max_daily_count']!, _maxDailyCountMeta));
    }
    if (data.containsKey('remark')) {
      context.handle(_remarkMeta,
          remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityRecord(
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
      activityName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_name'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      recordDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_date'])!,
      activityDefId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_def_id']),
      maxDailyCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_daily_count']),
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
    );
  }

  @override
  $ActivityRecordTableTable createAlias(String alias) {
    return $ActivityRecordTableTable(attachedDatabase, alias);
  }
}

class ActivityRecord extends DataClass implements Insertable<ActivityRecord> {
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 活动名称 (如：跑步、看书)
  final String activityName;

  /// 地点 (可选)
  final String? location;

  /// 活动日期 (yyyy-MM-dd)
  final String recordDate;

  /// 关联的活动定义ID (可选)
  final String? activityDefId;

  /// 每日最大打卡次数 (null=不限制)
  final int? maxDailyCount;

  /// 备注 (可选)
  final String? remark;
  const ActivityRecord(
      {required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.activityName,
      this.location,
      required this.recordDate,
      this.activityDefId,
      this.maxDailyCount,
      this.remark});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['activity_name'] = Variable<String>(activityName);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['record_date'] = Variable<String>(recordDate);
    if (!nullToAbsent || activityDefId != null) {
      map['activity_def_id'] = Variable<String>(activityDefId);
    }
    if (!nullToAbsent || maxDailyCount != null) {
      map['max_daily_count'] = Variable<int>(maxDailyCount);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    return map;
  }

  ActivityRecordTableCompanion toCompanion(bool nullToAbsent) {
    return ActivityRecordTableCompanion(
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      activityName: Value(activityName),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      recordDate: Value(recordDate),
      activityDefId: activityDefId == null && nullToAbsent
          ? const Value.absent()
          : Value(activityDefId),
      maxDailyCount: maxDailyCount == null && nullToAbsent
          ? const Value.absent()
          : Value(maxDailyCount),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
    );
  }

  factory ActivityRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityRecord(
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      activityName: serializer.fromJson<String>(json['activityName']),
      location: serializer.fromJson<String?>(json['location']),
      recordDate: serializer.fromJson<String>(json['recordDate']),
      activityDefId: serializer.fromJson<String?>(json['activityDefId']),
      maxDailyCount: serializer.fromJson<int?>(json['maxDailyCount']),
      remark: serializer.fromJson<String?>(json['remark']),
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
      'activityName': serializer.toJson<String>(activityName),
      'location': serializer.toJson<String?>(location),
      'recordDate': serializer.toJson<String>(recordDate),
      'activityDefId': serializer.toJson<String?>(activityDefId),
      'maxDailyCount': serializer.toJson<int?>(maxDailyCount),
      'remark': serializer.toJson<String?>(remark),
    };
  }

  ActivityRecord copyWith(
          {String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? activityName,
          Value<String?> location = const Value.absent(),
          String? recordDate,
          Value<String?> activityDefId = const Value.absent(),
          Value<int?> maxDailyCount = const Value.absent(),
          Value<String?> remark = const Value.absent()}) =>
      ActivityRecord(
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        activityName: activityName ?? this.activityName,
        location: location.present ? location.value : this.location,
        recordDate: recordDate ?? this.recordDate,
        activityDefId:
            activityDefId.present ? activityDefId.value : this.activityDefId,
        maxDailyCount:
            maxDailyCount.present ? maxDailyCount.value : this.maxDailyCount,
        remark: remark.present ? remark.value : this.remark,
      );
  ActivityRecord copyWithCompanion(ActivityRecordTableCompanion data) {
    return ActivityRecord(
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      activityName: data.activityName.present
          ? data.activityName.value
          : this.activityName,
      location: data.location.present ? data.location.value : this.location,
      recordDate:
          data.recordDate.present ? data.recordDate.value : this.recordDate,
      activityDefId: data.activityDefId.present
          ? data.activityDefId.value
          : this.activityDefId,
      maxDailyCount: data.maxDailyCount.present
          ? data.maxDailyCount.value
          : this.maxDailyCount,
      remark: data.remark.present ? data.remark.value : this.remark,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRecord(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('activityName: $activityName, ')
          ..write('location: $location, ')
          ..write('recordDate: $recordDate, ')
          ..write('activityDefId: $activityDefId, ')
          ..write('maxDailyCount: $maxDailyCount, ')
          ..write('remark: $remark')
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
      activityName,
      location,
      recordDate,
      activityDefId,
      maxDailyCount,
      remark);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityRecord &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.activityName == this.activityName &&
          other.location == this.location &&
          other.recordDate == this.recordDate &&
          other.activityDefId == this.activityDefId &&
          other.maxDailyCount == this.maxDailyCount &&
          other.remark == this.remark);
}

class ActivityRecordTableCompanion extends UpdateCompanion<ActivityRecord> {
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> activityName;
  final Value<String?> location;
  final Value<String> recordDate;
  final Value<String?> activityDefId;
  final Value<int?> maxDailyCount;
  final Value<String?> remark;
  final Value<int> rowid;
  const ActivityRecordTableCompanion({
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.activityName = const Value.absent(),
    this.location = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.activityDefId = const Value.absent(),
    this.maxDailyCount = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityRecordTableCompanion.insert({
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String activityName,
    this.location = const Value.absent(),
    required String recordDate,
    this.activityDefId = const Value.absent(),
    this.maxDailyCount = const Value.absent(),
    this.remark = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        activityName = Value(activityName),
        recordDate = Value(recordDate);
  static Insertable<ActivityRecord> custom({
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? activityName,
    Expression<String>? location,
    Expression<String>? recordDate,
    Expression<String>? activityDefId,
    Expression<int>? maxDailyCount,
    Expression<String>? remark,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (activityName != null) 'activity_name': activityName,
      if (location != null) 'location': location,
      if (recordDate != null) 'record_date': recordDate,
      if (activityDefId != null) 'activity_def_id': activityDefId,
      if (maxDailyCount != null) 'max_daily_count': maxDailyCount,
      if (remark != null) 'remark': remark,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityRecordTableCompanion copyWith(
      {Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? activityName,
      Value<String?>? location,
      Value<String>? recordDate,
      Value<String?>? activityDefId,
      Value<int?>? maxDailyCount,
      Value<String?>? remark,
      Value<int>? rowid}) {
    return ActivityRecordTableCompanion(
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      activityName: activityName ?? this.activityName,
      location: location ?? this.location,
      recordDate: recordDate ?? this.recordDate,
      activityDefId: activityDefId ?? this.activityDefId,
      maxDailyCount: maxDailyCount ?? this.maxDailyCount,
      remark: remark ?? this.remark,
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
    if (activityName.present) {
      map['activity_name'] = Variable<String>(activityName.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<String>(recordDate.value);
    }
    if (activityDefId.present) {
      map['activity_def_id'] = Variable<String>(activityDefId.value);
    }
    if (maxDailyCount.present) {
      map['max_daily_count'] = Variable<int>(maxDailyCount.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityRecordTableCompanion(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('activityName: $activityName, ')
          ..write('location: $location, ')
          ..write('recordDate: $recordDate, ')
          ..write('activityDefId: $activityDefId, ')
          ..write('maxDailyCount: $maxDailyCount, ')
          ..write('remark: $remark, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehicleTableTable extends VehicleTable
    with TableInfo<$VehicleTableTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _plateNumberMeta =
      const VerificationMeta('plateNumber');
  @override
  late final GeneratedColumn<String> plateNumber = GeneratedColumn<String>(
      'plate_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
      'model', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultFuelGradeMeta =
      const VerificationMeta('defaultFuelGrade');
  @override
  late final GeneratedColumn<String> defaultFuelGrade = GeneratedColumn<String>(
      'default_fuel_grade', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('92'));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
      'is_active', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        plateNumber,
        brand,
        model,
        remark,
        defaultFuelGrade,
        isActive,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_table';
  @override
  VerificationContext validateIntegrity(Insertable<Vehicle> instance,
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
    if (data.containsKey('plate_number')) {
      context.handle(
          _plateNumberMeta,
          plateNumber.isAcceptableOrUnknown(
              data['plate_number']!, _plateNumberMeta));
    } else if (isInserting) {
      context.missing(_plateNumberMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
          _modelMeta, model.isAcceptableOrUnknown(data['model']!, _modelMeta));
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('remark')) {
      context.handle(_remarkMeta,
          remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta));
    }
    if (data.containsKey('default_fuel_grade')) {
      context.handle(
          _defaultFuelGradeMeta,
          defaultFuelGrade.isAcceptableOrUnknown(
              data['default_fuel_grade']!, _defaultFuelGradeMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
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
      plateNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plate_number'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      model: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model'])!,
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
      defaultFuelGrade: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_fuel_grade'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_active'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $VehicleTableTable createAlias(String alias) {
    return $VehicleTableTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 车牌号
  final String plateNumber;

  /// 品牌
  final String brand;

  /// 型号
  final String model;

  /// 备注
  final String? remark;

  /// 默认油号
  final String defaultFuelGrade;

  /// 是否启用 (1:启用, 0:停用)
  final int isActive;

  /// 排序号
  final int sortOrder;
  const Vehicle(
      {required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.plateNumber,
      required this.brand,
      required this.model,
      this.remark,
      required this.defaultFuelGrade,
      required this.isActive,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['plate_number'] = Variable<String>(plateNumber);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    map['default_fuel_grade'] = Variable<String>(defaultFuelGrade);
    map['is_active'] = Variable<int>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  VehicleTableCompanion toCompanion(bool nullToAbsent) {
    return VehicleTableCompanion(
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      plateNumber: Value(plateNumber),
      brand: Value(brand),
      model: Value(model),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
      defaultFuelGrade: Value(defaultFuelGrade),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      plateNumber: serializer.fromJson<String>(json['plateNumber']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      remark: serializer.fromJson<String?>(json['remark']),
      defaultFuelGrade: serializer.fromJson<String>(json['defaultFuelGrade']),
      isActive: serializer.fromJson<int>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
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
      'plateNumber': serializer.toJson<String>(plateNumber),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'remark': serializer.toJson<String?>(remark),
      'defaultFuelGrade': serializer.toJson<String>(defaultFuelGrade),
      'isActive': serializer.toJson<int>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Vehicle copyWith(
          {String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? plateNumber,
          String? brand,
          String? model,
          Value<String?> remark = const Value.absent(),
          String? defaultFuelGrade,
          int? isActive,
          int? sortOrder}) =>
      Vehicle(
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        plateNumber: plateNumber ?? this.plateNumber,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        remark: remark.present ? remark.value : this.remark,
        defaultFuelGrade: defaultFuelGrade ?? this.defaultFuelGrade,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Vehicle copyWithCompanion(VehicleTableCompanion data) {
    return Vehicle(
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      plateNumber:
          data.plateNumber.present ? data.plateNumber.value : this.plateNumber,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      remark: data.remark.present ? data.remark.value : this.remark,
      defaultFuelGrade: data.defaultFuelGrade.present
          ? data.defaultFuelGrade.value
          : this.defaultFuelGrade,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('plateNumber: $plateNumber, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('remark: $remark, ')
          ..write('defaultFuelGrade: $defaultFuelGrade, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
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
      plateNumber,
      brand,
      model,
      remark,
      defaultFuelGrade,
      isActive,
      sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.plateNumber == this.plateNumber &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.remark == this.remark &&
          other.defaultFuelGrade == this.defaultFuelGrade &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class VehicleTableCompanion extends UpdateCompanion<Vehicle> {
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> plateNumber;
  final Value<String> brand;
  final Value<String> model;
  final Value<String?> remark;
  final Value<String> defaultFuelGrade;
  final Value<int> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const VehicleTableCompanion({
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.plateNumber = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.remark = const Value.absent(),
    this.defaultFuelGrade = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleTableCompanion.insert({
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String plateNumber,
    required String brand,
    required String model,
    this.remark = const Value.absent(),
    this.defaultFuelGrade = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        plateNumber = Value(plateNumber),
        brand = Value(brand),
        model = Value(model);
  static Insertable<Vehicle> custom({
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? plateNumber,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? remark,
    Expression<String>? defaultFuelGrade,
    Expression<int>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (plateNumber != null) 'plate_number': plateNumber,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (remark != null) 'remark': remark,
      if (defaultFuelGrade != null) 'default_fuel_grade': defaultFuelGrade,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleTableCompanion copyWith(
      {Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? plateNumber,
      Value<String>? brand,
      Value<String>? model,
      Value<String?>? remark,
      Value<String>? defaultFuelGrade,
      Value<int>? isActive,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return VehicleTableCompanion(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      remark: remark ?? this.remark,
      defaultFuelGrade: defaultFuelGrade ?? this.defaultFuelGrade,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (plateNumber.present) {
      map['plate_number'] = Variable<String>(plateNumber.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (defaultFuelGrade.present) {
      map['default_fuel_grade'] = Variable<String>(defaultFuelGrade.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleTableCompanion(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('plateNumber: $plateNumber, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('remark: $remark, ')
          ..write('defaultFuelGrade: $defaultFuelGrade, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FuelRecordTableTable extends FuelRecordTable
    with TableInfo<$FuelRecordTableTable, FuelRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelRecordTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _vehicleIdMeta =
      const VerificationMeta('vehicleId');
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
      'vehicle_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mileageMeta =
      const VerificationMeta('mileage');
  @override
  late final GeneratedColumn<int> mileage = GeneratedColumn<int>(
      'mileage', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _energyTypeMeta =
      const VerificationMeta('energyType');
  @override
  late final GeneratedColumn<String> energyType = GeneratedColumn<String>(
      'energy_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('gasoline'));
  static const VerificationMeta _fuelGradeMeta =
      const VerificationMeta('fuelGrade');
  @override
  late final GeneratedColumn<String> fuelGrade = GeneratedColumn<String>(
      'fuel_grade', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('92'));
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<double> volume = GeneratedColumn<double>(
      'volume', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isFullTankMeta =
      const VerificationMeta('isFullTank');
  @override
  late final GeneratedColumn<int> isFullTank = GeneratedColumn<int>(
      'is_full_tank', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isFuelLightOnMeta =
      const VerificationMeta('isFuelLightOn');
  @override
  late final GeneratedColumn<int> isFuelLightOn = GeneratedColumn<int>(
      'is_fuel_light_on', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stationMeta =
      const VerificationMeta('station');
  @override
  late final GeneratedColumn<String> station = GeneratedColumn<String>(
      'station', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _remarkMeta = const VerificationMeta('remark');
  @override
  late final GeneratedColumn<String> remark = GeneratedColumn<String>(
      'remark', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refuelTimeMeta =
      const VerificationMeta('refuelTime');
  @override
  late final GeneratedColumn<int> refuelTime = GeneratedColumn<int>(
      'refuel_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _linkedBookIdMeta =
      const VerificationMeta('linkedBookId');
  @override
  late final GeneratedColumn<String> linkedBookId = GeneratedColumn<String>(
      'linked_book_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedItemIdMeta =
      const VerificationMeta('linkedItemId');
  @override
  late final GeneratedColumn<String> linkedItemId = GeneratedColumn<String>(
      'linked_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        vehicleId,
        mileage,
        energyType,
        fuelGrade,
        volume,
        unitPrice,
        totalAmount,
        isFullTank,
        isFuelLightOn,
        station,
        remark,
        refuelTime,
        linkedBookId,
        linkedItemId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_record_table';
  @override
  VerificationContext validateIntegrity(Insertable<FuelRecord> instance,
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
    if (data.containsKey('vehicle_id')) {
      context.handle(_vehicleIdMeta,
          vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta));
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('mileage')) {
      context.handle(_mileageMeta,
          mileage.isAcceptableOrUnknown(data['mileage']!, _mileageMeta));
    } else if (isInserting) {
      context.missing(_mileageMeta);
    }
    if (data.containsKey('energy_type')) {
      context.handle(
          _energyTypeMeta,
          energyType.isAcceptableOrUnknown(
              data['energy_type']!, _energyTypeMeta));
    }
    if (data.containsKey('fuel_grade')) {
      context.handle(_fuelGradeMeta,
          fuelGrade.isAcceptableOrUnknown(data['fuel_grade']!, _fuelGradeMeta));
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    } else if (isInserting) {
      context.missing(_volumeMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('is_full_tank')) {
      context.handle(
          _isFullTankMeta,
          isFullTank.isAcceptableOrUnknown(
              data['is_full_tank']!, _isFullTankMeta));
    }
    if (data.containsKey('is_fuel_light_on')) {
      context.handle(
          _isFuelLightOnMeta,
          isFuelLightOn.isAcceptableOrUnknown(
              data['is_fuel_light_on']!, _isFuelLightOnMeta));
    }
    if (data.containsKey('station')) {
      context.handle(_stationMeta,
          station.isAcceptableOrUnknown(data['station']!, _stationMeta));
    }
    if (data.containsKey('remark')) {
      context.handle(_remarkMeta,
          remark.isAcceptableOrUnknown(data['remark']!, _remarkMeta));
    }
    if (data.containsKey('refuel_time')) {
      context.handle(
          _refuelTimeMeta,
          refuelTime.isAcceptableOrUnknown(
              data['refuel_time']!, _refuelTimeMeta));
    } else if (isInserting) {
      context.missing(_refuelTimeMeta);
    }
    if (data.containsKey('linked_book_id')) {
      context.handle(
          _linkedBookIdMeta,
          linkedBookId.isAcceptableOrUnknown(
              data['linked_book_id']!, _linkedBookIdMeta));
    }
    if (data.containsKey('linked_item_id')) {
      context.handle(
          _linkedItemIdMeta,
          linkedItemId.isAcceptableOrUnknown(
              data['linked_item_id']!, _linkedItemIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuelRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelRecord(
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
      vehicleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vehicle_id'])!,
      mileage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mileage'])!,
      energyType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}energy_type'])!,
      fuelGrade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fuel_grade'])!,
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}volume'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      isFullTank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_full_tank'])!,
      isFuelLightOn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_fuel_light_on'])!,
      station: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}station']),
      remark: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remark']),
      refuelTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}refuel_time'])!,
      linkedBookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_book_id']),
      linkedItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linked_item_id']),
    );
  }

  @override
  $FuelRecordTableTable createAlias(String alias) {
    return $FuelRecordTableTable(attachedDatabase, alias);
  }
}

class FuelRecord extends DataClass implements Insertable<FuelRecord> {
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 车辆ID
  final String vehicleId;

  /// 里程数
  final int mileage;

  /// 能源类型 (gasoline: 汽油, diesel: 柴油)
  final String energyType;

  /// 油号
  final String fuelGrade;

  /// 加油量 (升)
  final double volume;

  /// 单价 (元/升)
  final double unitPrice;

  /// 总金额 (元)
  final double totalAmount;

  /// 是否跳枪 (1:跳枪, 0:未跳枪)
  final int isFullTank;

  /// 油灯是否亮起 (1:亮起, 0:未亮)
  final int isFuelLightOn;

  /// 加油站
  final String? station;

  /// 备注
  final String? remark;

  /// 加油时间 (毫秒时间戳)
  final int refuelTime;

  /// 关联账本ID
  final String? linkedBookId;

  /// 关联账目ID
  final String? linkedItemId;
  const FuelRecord(
      {required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.vehicleId,
      required this.mileage,
      required this.energyType,
      required this.fuelGrade,
      required this.volume,
      required this.unitPrice,
      required this.totalAmount,
      required this.isFullTank,
      required this.isFuelLightOn,
      this.station,
      this.remark,
      required this.refuelTime,
      this.linkedBookId,
      this.linkedItemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['mileage'] = Variable<int>(mileage);
    map['energy_type'] = Variable<String>(energyType);
    map['fuel_grade'] = Variable<String>(fuelGrade);
    map['volume'] = Variable<double>(volume);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_amount'] = Variable<double>(totalAmount);
    map['is_full_tank'] = Variable<int>(isFullTank);
    map['is_fuel_light_on'] = Variable<int>(isFuelLightOn);
    if (!nullToAbsent || station != null) {
      map['station'] = Variable<String>(station);
    }
    if (!nullToAbsent || remark != null) {
      map['remark'] = Variable<String>(remark);
    }
    map['refuel_time'] = Variable<int>(refuelTime);
    if (!nullToAbsent || linkedBookId != null) {
      map['linked_book_id'] = Variable<String>(linkedBookId);
    }
    if (!nullToAbsent || linkedItemId != null) {
      map['linked_item_id'] = Variable<String>(linkedItemId);
    }
    return map;
  }

  FuelRecordTableCompanion toCompanion(bool nullToAbsent) {
    return FuelRecordTableCompanion(
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      vehicleId: Value(vehicleId),
      mileage: Value(mileage),
      energyType: Value(energyType),
      fuelGrade: Value(fuelGrade),
      volume: Value(volume),
      unitPrice: Value(unitPrice),
      totalAmount: Value(totalAmount),
      isFullTank: Value(isFullTank),
      isFuelLightOn: Value(isFuelLightOn),
      station: station == null && nullToAbsent
          ? const Value.absent()
          : Value(station),
      remark:
          remark == null && nullToAbsent ? const Value.absent() : Value(remark),
      refuelTime: Value(refuelTime),
      linkedBookId: linkedBookId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedBookId),
      linkedItemId: linkedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedItemId),
    );
  }

  factory FuelRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelRecord(
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      mileage: serializer.fromJson<int>(json['mileage']),
      energyType: serializer.fromJson<String>(json['energyType']),
      fuelGrade: serializer.fromJson<String>(json['fuelGrade']),
      volume: serializer.fromJson<double>(json['volume']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      isFullTank: serializer.fromJson<int>(json['isFullTank']),
      isFuelLightOn: serializer.fromJson<int>(json['isFuelLightOn']),
      station: serializer.fromJson<String?>(json['station']),
      remark: serializer.fromJson<String?>(json['remark']),
      refuelTime: serializer.fromJson<int>(json['refuelTime']),
      linkedBookId: serializer.fromJson<String?>(json['linkedBookId']),
      linkedItemId: serializer.fromJson<String?>(json['linkedItemId']),
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
      'vehicleId': serializer.toJson<String>(vehicleId),
      'mileage': serializer.toJson<int>(mileage),
      'energyType': serializer.toJson<String>(energyType),
      'fuelGrade': serializer.toJson<String>(fuelGrade),
      'volume': serializer.toJson<double>(volume),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'isFullTank': serializer.toJson<int>(isFullTank),
      'isFuelLightOn': serializer.toJson<int>(isFuelLightOn),
      'station': serializer.toJson<String?>(station),
      'remark': serializer.toJson<String?>(remark),
      'refuelTime': serializer.toJson<int>(refuelTime),
      'linkedBookId': serializer.toJson<String?>(linkedBookId),
      'linkedItemId': serializer.toJson<String?>(linkedItemId),
    };
  }

  FuelRecord copyWith(
          {String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? vehicleId,
          int? mileage,
          String? energyType,
          String? fuelGrade,
          double? volume,
          double? unitPrice,
          double? totalAmount,
          int? isFullTank,
          int? isFuelLightOn,
          Value<String?> station = const Value.absent(),
          Value<String?> remark = const Value.absent(),
          int? refuelTime,
          Value<String?> linkedBookId = const Value.absent(),
          Value<String?> linkedItemId = const Value.absent()}) =>
      FuelRecord(
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        mileage: mileage ?? this.mileage,
        energyType: energyType ?? this.energyType,
        fuelGrade: fuelGrade ?? this.fuelGrade,
        volume: volume ?? this.volume,
        unitPrice: unitPrice ?? this.unitPrice,
        totalAmount: totalAmount ?? this.totalAmount,
        isFullTank: isFullTank ?? this.isFullTank,
        isFuelLightOn: isFuelLightOn ?? this.isFuelLightOn,
        station: station.present ? station.value : this.station,
        remark: remark.present ? remark.value : this.remark,
        refuelTime: refuelTime ?? this.refuelTime,
        linkedBookId:
            linkedBookId.present ? linkedBookId.value : this.linkedBookId,
        linkedItemId:
            linkedItemId.present ? linkedItemId.value : this.linkedItemId,
      );
  FuelRecord copyWithCompanion(FuelRecordTableCompanion data) {
    return FuelRecord(
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      mileage: data.mileage.present ? data.mileage.value : this.mileage,
      energyType:
          data.energyType.present ? data.energyType.value : this.energyType,
      fuelGrade: data.fuelGrade.present ? data.fuelGrade.value : this.fuelGrade,
      volume: data.volume.present ? data.volume.value : this.volume,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      isFullTank:
          data.isFullTank.present ? data.isFullTank.value : this.isFullTank,
      isFuelLightOn: data.isFuelLightOn.present
          ? data.isFuelLightOn.value
          : this.isFuelLightOn,
      station: data.station.present ? data.station.value : this.station,
      remark: data.remark.present ? data.remark.value : this.remark,
      refuelTime:
          data.refuelTime.present ? data.refuelTime.value : this.refuelTime,
      linkedBookId: data.linkedBookId.present
          ? data.linkedBookId.value
          : this.linkedBookId,
      linkedItemId: data.linkedItemId.present
          ? data.linkedItemId.value
          : this.linkedItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelRecord(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('mileage: $mileage, ')
          ..write('energyType: $energyType, ')
          ..write('fuelGrade: $fuelGrade, ')
          ..write('volume: $volume, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('isFuelLightOn: $isFuelLightOn, ')
          ..write('station: $station, ')
          ..write('remark: $remark, ')
          ..write('refuelTime: $refuelTime, ')
          ..write('linkedBookId: $linkedBookId, ')
          ..write('linkedItemId: $linkedItemId')
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
      vehicleId,
      mileage,
      energyType,
      fuelGrade,
      volume,
      unitPrice,
      totalAmount,
      isFullTank,
      isFuelLightOn,
      station,
      remark,
      refuelTime,
      linkedBookId,
      linkedItemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelRecord &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.mileage == this.mileage &&
          other.energyType == this.energyType &&
          other.fuelGrade == this.fuelGrade &&
          other.volume == this.volume &&
          other.unitPrice == this.unitPrice &&
          other.totalAmount == this.totalAmount &&
          other.isFullTank == this.isFullTank &&
          other.isFuelLightOn == this.isFuelLightOn &&
          other.station == this.station &&
          other.remark == this.remark &&
          other.refuelTime == this.refuelTime &&
          other.linkedBookId == this.linkedBookId &&
          other.linkedItemId == this.linkedItemId);
}

class FuelRecordTableCompanion extends UpdateCompanion<FuelRecord> {
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> vehicleId;
  final Value<int> mileage;
  final Value<String> energyType;
  final Value<String> fuelGrade;
  final Value<double> volume;
  final Value<double> unitPrice;
  final Value<double> totalAmount;
  final Value<int> isFullTank;
  final Value<int> isFuelLightOn;
  final Value<String?> station;
  final Value<String?> remark;
  final Value<int> refuelTime;
  final Value<String?> linkedBookId;
  final Value<String?> linkedItemId;
  final Value<int> rowid;
  const FuelRecordTableCompanion({
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.mileage = const Value.absent(),
    this.energyType = const Value.absent(),
    this.fuelGrade = const Value.absent(),
    this.volume = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.isFullTank = const Value.absent(),
    this.isFuelLightOn = const Value.absent(),
    this.station = const Value.absent(),
    this.remark = const Value.absent(),
    this.refuelTime = const Value.absent(),
    this.linkedBookId = const Value.absent(),
    this.linkedItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FuelRecordTableCompanion.insert({
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String vehicleId,
    required int mileage,
    this.energyType = const Value.absent(),
    this.fuelGrade = const Value.absent(),
    required double volume,
    required double unitPrice,
    required double totalAmount,
    this.isFullTank = const Value.absent(),
    this.isFuelLightOn = const Value.absent(),
    this.station = const Value.absent(),
    this.remark = const Value.absent(),
    required int refuelTime,
    this.linkedBookId = const Value.absent(),
    this.linkedItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        vehicleId = Value(vehicleId),
        mileage = Value(mileage),
        volume = Value(volume),
        unitPrice = Value(unitPrice),
        totalAmount = Value(totalAmount),
        refuelTime = Value(refuelTime);
  static Insertable<FuelRecord> custom({
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? vehicleId,
    Expression<int>? mileage,
    Expression<String>? energyType,
    Expression<String>? fuelGrade,
    Expression<double>? volume,
    Expression<double>? unitPrice,
    Expression<double>? totalAmount,
    Expression<int>? isFullTank,
    Expression<int>? isFuelLightOn,
    Expression<String>? station,
    Expression<String>? remark,
    Expression<int>? refuelTime,
    Expression<String>? linkedBookId,
    Expression<String>? linkedItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (mileage != null) 'mileage': mileage,
      if (energyType != null) 'energy_type': energyType,
      if (fuelGrade != null) 'fuel_grade': fuelGrade,
      if (volume != null) 'volume': volume,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (isFullTank != null) 'is_full_tank': isFullTank,
      if (isFuelLightOn != null) 'is_fuel_light_on': isFuelLightOn,
      if (station != null) 'station': station,
      if (remark != null) 'remark': remark,
      if (refuelTime != null) 'refuel_time': refuelTime,
      if (linkedBookId != null) 'linked_book_id': linkedBookId,
      if (linkedItemId != null) 'linked_item_id': linkedItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FuelRecordTableCompanion copyWith(
      {Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? vehicleId,
      Value<int>? mileage,
      Value<String>? energyType,
      Value<String>? fuelGrade,
      Value<double>? volume,
      Value<double>? unitPrice,
      Value<double>? totalAmount,
      Value<int>? isFullTank,
      Value<int>? isFuelLightOn,
      Value<String?>? station,
      Value<String?>? remark,
      Value<int>? refuelTime,
      Value<String?>? linkedBookId,
      Value<String?>? linkedItemId,
      Value<int>? rowid}) {
    return FuelRecordTableCompanion(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      mileage: mileage ?? this.mileage,
      energyType: energyType ?? this.energyType,
      fuelGrade: fuelGrade ?? this.fuelGrade,
      volume: volume ?? this.volume,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      isFullTank: isFullTank ?? this.isFullTank,
      isFuelLightOn: isFuelLightOn ?? this.isFuelLightOn,
      station: station ?? this.station,
      remark: remark ?? this.remark,
      refuelTime: refuelTime ?? this.refuelTime,
      linkedBookId: linkedBookId ?? this.linkedBookId,
      linkedItemId: linkedItemId ?? this.linkedItemId,
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
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (mileage.present) {
      map['mileage'] = Variable<int>(mileage.value);
    }
    if (energyType.present) {
      map['energy_type'] = Variable<String>(energyType.value);
    }
    if (fuelGrade.present) {
      map['fuel_grade'] = Variable<String>(fuelGrade.value);
    }
    if (volume.present) {
      map['volume'] = Variable<double>(volume.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (isFullTank.present) {
      map['is_full_tank'] = Variable<int>(isFullTank.value);
    }
    if (isFuelLightOn.present) {
      map['is_fuel_light_on'] = Variable<int>(isFuelLightOn.value);
    }
    if (station.present) {
      map['station'] = Variable<String>(station.value);
    }
    if (remark.present) {
      map['remark'] = Variable<String>(remark.value);
    }
    if (refuelTime.present) {
      map['refuel_time'] = Variable<int>(refuelTime.value);
    }
    if (linkedBookId.present) {
      map['linked_book_id'] = Variable<String>(linkedBookId.value);
    }
    if (linkedItemId.present) {
      map['linked_item_id'] = Variable<String>(linkedItemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelRecordTableCompanion(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('mileage: $mileage, ')
          ..write('energyType: $energyType, ')
          ..write('fuelGrade: $fuelGrade, ')
          ..write('volume: $volume, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('isFuelLightOn: $isFuelLightOn, ')
          ..write('station: $station, ')
          ..write('remark: $remark, ')
          ..write('refuelTime: $refuelTime, ')
          ..write('linkedBookId: $linkedBookId, ')
          ..write('linkedItemId: $linkedItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemRelationTableTable extends ItemRelationTable
    with TableInfo<$ItemRelationTableTable, ItemRelation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemRelationTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountBookIdMeta =
      const VerificationMeta('accountBookId');
  @override
  late final GeneratedColumn<String> accountBookId = GeneratedColumn<String>(
      'account_book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relationCodeMeta =
      const VerificationMeta('relationCode');
  @override
  late final GeneratedColumn<String> relationCode = GeneratedColumn<String>(
      'relation_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relationIdMeta =
      const VerificationMeta('relationId');
  @override
  late final GeneratedColumn<String> relationId = GeneratedColumn<String>(
      'relation_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        itemId,
        accountBookId,
        relationCode,
        relationId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_relation_table';
  @override
  VerificationContext validateIntegrity(Insertable<ItemRelation> instance,
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
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('account_book_id')) {
      context.handle(
          _accountBookIdMeta,
          accountBookId.isAcceptableOrUnknown(
              data['account_book_id']!, _accountBookIdMeta));
    } else if (isInserting) {
      context.missing(_accountBookIdMeta);
    }
    if (data.containsKey('relation_code')) {
      context.handle(
          _relationCodeMeta,
          relationCode.isAcceptableOrUnknown(
              data['relation_code']!, _relationCodeMeta));
    } else if (isInserting) {
      context.missing(_relationCodeMeta);
    }
    if (data.containsKey('relation_id')) {
      context.handle(
          _relationIdMeta,
          relationId.isAcceptableOrUnknown(
              data['relation_id']!, _relationIdMeta));
    } else if (isInserting) {
      context.missing(_relationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRelation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRelation(
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
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      accountBookId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}account_book_id'])!,
      relationCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relation_code'])!,
      relationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relation_id'])!,
    );
  }

  @override
  $ItemRelationTableTable createAlias(String alias) {
    return $ItemRelationTableTable(attachedDatabase, alias);
  }
}

class ItemRelation extends DataClass implements Insertable<ItemRelation> {
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;
  final String itemId;
  final String accountBookId;
  final String relationCode;
  final String relationId;
  const ItemRelation(
      {required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.itemId,
      required this.accountBookId,
      required this.relationCode,
      required this.relationId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['account_book_id'] = Variable<String>(accountBookId);
    map['relation_code'] = Variable<String>(relationCode);
    map['relation_id'] = Variable<String>(relationId);
    return map;
  }

  ItemRelationTableCompanion toCompanion(bool nullToAbsent) {
    return ItemRelationTableCompanion(
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      itemId: Value(itemId),
      accountBookId: Value(accountBookId),
      relationCode: Value(relationCode),
      relationId: Value(relationId),
    );
  }

  factory ItemRelation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRelation(
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      relationCode: serializer.fromJson<String>(json['relationCode']),
      relationId: serializer.fromJson<String>(json['relationId']),
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
      'itemId': serializer.toJson<String>(itemId),
      'accountBookId': serializer.toJson<String>(accountBookId),
      'relationCode': serializer.toJson<String>(relationCode),
      'relationId': serializer.toJson<String>(relationId),
    };
  }

  ItemRelation copyWith(
          {String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? itemId,
          String? accountBookId,
          String? relationCode,
          String? relationId}) =>
      ItemRelation(
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        accountBookId: accountBookId ?? this.accountBookId,
        relationCode: relationCode ?? this.relationCode,
        relationId: relationId ?? this.relationId,
      );
  ItemRelation copyWithCompanion(ItemRelationTableCompanion data) {
    return ItemRelation(
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      relationCode: data.relationCode.present
          ? data.relationCode.value
          : this.relationCode,
      relationId:
          data.relationId.present ? data.relationId.value : this.relationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRelation(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('relationCode: $relationCode, ')
          ..write('relationId: $relationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdBy, updatedBy, createdAt, updatedAt,
      id, itemId, accountBookId, relationCode, relationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRelation &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.accountBookId == this.accountBookId &&
          other.relationCode == this.relationCode &&
          other.relationId == this.relationId);
}

class ItemRelationTableCompanion extends UpdateCompanion<ItemRelation> {
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> accountBookId;
  final Value<String> relationCode;
  final Value<String> relationId;
  final Value<int> rowid;
  const ItemRelationTableCompanion({
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.accountBookId = const Value.absent(),
    this.relationCode = const Value.absent(),
    this.relationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemRelationTableCompanion.insert({
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
    this.rowid = const Value.absent(),
  })  : createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        itemId = Value(itemId),
        accountBookId = Value(accountBookId),
        relationCode = Value(relationCode),
        relationId = Value(relationId);
  static Insertable<ItemRelation> custom({
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? accountBookId,
    Expression<String>? relationCode,
    Expression<String>? relationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (relationCode != null) 'relation_code': relationCode,
      if (relationId != null) 'relation_id': relationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemRelationTableCompanion copyWith(
      {Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? itemId,
      Value<String>? accountBookId,
      Value<String>? relationCode,
      Value<String>? relationId,
      Value<int>? rowid}) {
    return ItemRelationTableCompanion(
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      accountBookId: accountBookId ?? this.accountBookId,
      relationCode: relationCode ?? this.relationCode,
      relationId: relationId ?? this.relationId,
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (accountBookId.present) {
      map['account_book_id'] = Variable<String>(accountBookId.value);
    }
    if (relationCode.present) {
      map['relation_code'] = Variable<String>(relationCode.value);
    }
    if (relationId.present) {
      map['relation_id'] = Variable<String>(relationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemRelationTableCompanion(')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('accountBookId: $accountBookId, ')
          ..write('relationCode: $relationCode, ')
          ..write('relationId: $relationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserShareTableTable extends UserShareTable
    with TableInfo<$UserShareTableTable, UserShare> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserShareTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _ownerUserIdMeta =
      const VerificationMeta('ownerUserId');
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
      'owner_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetUserIdMeta =
      const VerificationMeta('targetUserId');
  @override
  late final GeneratedColumn<String> targetUserId = GeneratedColumn<String>(
      'target_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessTypeMeta =
      const VerificationMeta('businessType');
  @override
  late final GeneratedColumn<String> businessType = GeneratedColumn<String>(
      'business_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isEnabledMeta =
      const VerificationMeta('isEnabled');
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
      'is_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        createdAt,
        updatedAt,
        id,
        ownerUserId,
        targetUserId,
        businessType,
        isEnabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_share_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserShare> instance,
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
    if (data.containsKey('owner_user_id')) {
      context.handle(
          _ownerUserIdMeta,
          ownerUserId.isAcceptableOrUnknown(
              data['owner_user_id']!, _ownerUserIdMeta));
    } else if (isInserting) {
      context.missing(_ownerUserIdMeta);
    }
    if (data.containsKey('target_user_id')) {
      context.handle(
          _targetUserIdMeta,
          targetUserId.isAcceptableOrUnknown(
              data['target_user_id']!, _targetUserIdMeta));
    } else if (isInserting) {
      context.missing(_targetUserIdMeta);
    }
    if (data.containsKey('business_type')) {
      context.handle(
          _businessTypeMeta,
          businessType.isAcceptableOrUnknown(
              data['business_type']!, _businessTypeMeta));
    } else if (isInserting) {
      context.missing(_businessTypeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(_isEnabledMeta,
          isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {ownerUserId, targetUserId, businessType},
      ];
  @override
  UserShare map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserShare(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_user_id'])!,
      targetUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_user_id'])!,
      businessType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_type'])!,
      isEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_enabled'])!,
    );
  }

  @override
  $UserShareTableTable createAlias(String alias) {
    return $UserShareTableTable(attachedDatabase, alias);
  }
}

class UserShare extends DataClass implements Insertable<UserShare> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String ownerUserId;
  final String targetUserId;
  final String businessType;
  final bool isEnabled;
  const UserShare(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.ownerUserId,
      required this.targetUserId,
      required this.businessType,
      required this.isEnabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['owner_user_id'] = Variable<String>(ownerUserId);
    map['target_user_id'] = Variable<String>(targetUserId);
    map['business_type'] = Variable<String>(businessType);
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  UserShareTableCompanion toCompanion(bool nullToAbsent) {
    return UserShareTableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      ownerUserId: Value(ownerUserId),
      targetUserId: Value(targetUserId),
      businessType: Value(businessType),
      isEnabled: Value(isEnabled),
    );
  }

  factory UserShare.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserShare(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      ownerUserId: serializer.fromJson<String>(json['ownerUserId']),
      targetUserId: serializer.fromJson<String>(json['targetUserId']),
      businessType: serializer.fromJson<String>(json['businessType']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'ownerUserId': serializer.toJson<String>(ownerUserId),
      'targetUserId': serializer.toJson<String>(targetUserId),
      'businessType': serializer.toJson<String>(businessType),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  UserShare copyWith(
          {int? createdAt,
          int? updatedAt,
          String? id,
          String? ownerUserId,
          String? targetUserId,
          String? businessType,
          bool? isEnabled}) =>
      UserShare(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        ownerUserId: ownerUserId ?? this.ownerUserId,
        targetUserId: targetUserId ?? this.targetUserId,
        businessType: businessType ?? this.businessType,
        isEnabled: isEnabled ?? this.isEnabled,
      );
  UserShare copyWithCompanion(UserShareTableCompanion data) {
    return UserShare(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      ownerUserId:
          data.ownerUserId.present ? data.ownerUserId.value : this.ownerUserId,
      targetUserId: data.targetUserId.present
          ? data.targetUserId.value
          : this.targetUserId,
      businessType: data.businessType.present
          ? data.businessType.value
          : this.businessType,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserShare(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('businessType: $businessType, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(createdAt, updatedAt, id, ownerUserId,
      targetUserId, businessType, isEnabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserShare &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.ownerUserId == this.ownerUserId &&
          other.targetUserId == this.targetUserId &&
          other.businessType == this.businessType &&
          other.isEnabled == this.isEnabled);
}

class UserShareTableCompanion extends UpdateCompanion<UserShare> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> ownerUserId;
  final Value<String> targetUserId;
  final Value<String> businessType;
  final Value<bool> isEnabled;
  final Value<int> rowid;
  const UserShareTableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.targetUserId = const Value.absent(),
    this.businessType = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserShareTableCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String ownerUserId,
    required String targetUserId,
    required String businessType,
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        ownerUserId = Value(ownerUserId),
        targetUserId = Value(targetUserId),
        businessType = Value(businessType);
  static Insertable<UserShare> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? ownerUserId,
    Expression<String>? targetUserId,
    Expression<String>? businessType,
    Expression<bool>? isEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (targetUserId != null) 'target_user_id': targetUserId,
      if (businessType != null) 'business_type': businessType,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserShareTableCompanion copyWith(
      {Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? ownerUserId,
      Value<String>? targetUserId,
      Value<String>? businessType,
      Value<bool>? isEnabled,
      Value<int>? rowid}) {
    return UserShareTableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      businessType: businessType ?? this.businessType,
      isEnabled: isEnabled ?? this.isEnabled,
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
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (targetUserId.present) {
      map['target_user_id'] = Variable<String>(targetUserId.value);
    }
    if (businessType.present) {
      map['business_type'] = Variable<String>(businessType.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserShareTableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('targetUserId: $targetUserId, ')
          ..write('businessType: $businessType, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringConfigTableTable extends RecurringConfigTable
    with TableInfo<$RecurringConfigTableTable, RecurringConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringConfigTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 16),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
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
  static const VerificationMeta _categoryCodeMeta =
      const VerificationMeta('categoryCode');
  @override
  late final GeneratedColumn<String> categoryCode = GeneratedColumn<String>(
      'category_code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _fundIdMeta = const VerificationMeta('fundId');
  @override
  late final GeneratedColumn<String> fundId = GeneratedColumn<String>(
      'fund_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
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
  static const VerificationMeta _frequencyTypeMeta =
      const VerificationMeta('frequencyType');
  @override
  late final GeneratedColumn<String> frequencyType = GeneratedColumn<String>(
      'frequency_type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 16),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _frequencyValueMeta =
      const VerificationMeta('frequencyValue');
  @override
  late final GeneratedColumn<String> frequencyValue = GeneratedColumn<String>(
      'frequency_value', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 16),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _endTypeMeta =
      const VerificationMeta('endType');
  @override
  late final GeneratedColumn<String> endType = GeneratedColumn<String>(
      'end_type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 16),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'end_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endCountMeta =
      const VerificationMeta('endCount');
  @override
  late final GeneratedColumn<int> endCount = GeneratedColumn<int>(
      'end_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _generatedCountMeta =
      const VerificationMeta('generatedCount');
  @override
  late final GeneratedColumn<int> generatedCount = GeneratedColumn<int>(
      'generated_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastGeneratedAtMeta =
      const VerificationMeta('lastGeneratedAt');
  @override
  late final GeneratedColumn<String> lastGeneratedAt = GeneratedColumn<String>(
      'last_generated_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        type,
        amount,
        description,
        categoryCode,
        fundId,
        shopCode,
        tagCode,
        projectCode,
        frequencyType,
        frequencyValue,
        startDate,
        endType,
        endDate,
        endCount,
        generatedCount,
        lastGeneratedAt,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_config_table';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringConfig> instance,
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
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
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
    if (data.containsKey('category_code')) {
      context.handle(
          _categoryCodeMeta,
          categoryCode.isAcceptableOrUnknown(
              data['category_code']!, _categoryCodeMeta));
    } else if (isInserting) {
      context.missing(_categoryCodeMeta);
    }
    if (data.containsKey('fund_id')) {
      context.handle(_fundIdMeta,
          fundId.isAcceptableOrUnknown(data['fund_id']!, _fundIdMeta));
    } else if (isInserting) {
      context.missing(_fundIdMeta);
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
    if (data.containsKey('frequency_type')) {
      context.handle(
          _frequencyTypeMeta,
          frequencyType.isAcceptableOrUnknown(
              data['frequency_type']!, _frequencyTypeMeta));
    } else if (isInserting) {
      context.missing(_frequencyTypeMeta);
    }
    if (data.containsKey('frequency_value')) {
      context.handle(
          _frequencyValueMeta,
          frequencyValue.isAcceptableOrUnknown(
              data['frequency_value']!, _frequencyValueMeta));
    } else if (isInserting) {
      context.missing(_frequencyValueMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_type')) {
      context.handle(_endTypeMeta,
          endType.isAcceptableOrUnknown(data['end_type']!, _endTypeMeta));
    } else if (isInserting) {
      context.missing(_endTypeMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('end_count')) {
      context.handle(_endCountMeta,
          endCount.isAcceptableOrUnknown(data['end_count']!, _endCountMeta));
    }
    if (data.containsKey('generated_count')) {
      context.handle(
          _generatedCountMeta,
          generatedCount.isAcceptableOrUnknown(
              data['generated_count']!, _generatedCountMeta));
    }
    if (data.containsKey('last_generated_at')) {
      context.handle(
          _lastGeneratedAtMeta,
          lastGeneratedAt.isAcceptableOrUnknown(
              data['last_generated_at']!, _lastGeneratedAtMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringConfig(
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
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      categoryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_code'])!,
      fundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fund_id'])!,
      shopCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shop_code']),
      tagCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_code']),
      projectCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_code']),
      frequencyType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency_type'])!,
      frequencyValue: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}frequency_value'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      endType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_type'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      endCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_count']),
      generatedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}generated_count'])!,
      lastGeneratedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_generated_at']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $RecurringConfigTableTable createAlias(String alias) {
    return $RecurringConfigTableTable(attachedDatabase, alias);
  }
}

class RecurringConfig extends DataClass implements Insertable<RecurringConfig> {
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 类型: INCOME / EXPENSE
  final String type;

  /// 金额
  final double amount;

  /// 备注
  final String? description;

  /// 分类code
  final String categoryCode;

  /// 账户ID
  final String fundId;

  /// 商户code
  final String? shopCode;

  /// 标签code
  final String? tagCode;

  /// 项目code
  final String? projectCode;

  /// 频率类型: weekly / monthly
  final String frequencyType;

  /// 频率值: weekly用"1,3,5"(星期), monthly用"1,15"(日期)
  final String frequencyValue;

  /// 开始日期 yyyy-MM-dd
  final String startDate;

  /// 结束条件类型: infinite / date / count
  final String endType;

  /// 结束日期(endType=date时)
  final String? endDate;

  /// 总次数(endType=count时)
  final int? endCount;

  /// 已生成次数
  final int generatedCount;

  /// 上次生成时间 yyyy-MM-dd HH:mm:ss
  final String? lastGeneratedAt;

  /// 启用状态
  final bool isActive;
  const RecurringConfig(
      {required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.type,
      required this.amount,
      this.description,
      required this.categoryCode,
      required this.fundId,
      this.shopCode,
      this.tagCode,
      this.projectCode,
      required this.frequencyType,
      required this.frequencyValue,
      required this.startDate,
      required this.endType,
      this.endDate,
      this.endCount,
      required this.generatedCount,
      this.lastGeneratedAt,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['category_code'] = Variable<String>(categoryCode);
    map['fund_id'] = Variable<String>(fundId);
    if (!nullToAbsent || shopCode != null) {
      map['shop_code'] = Variable<String>(shopCode);
    }
    if (!nullToAbsent || tagCode != null) {
      map['tag_code'] = Variable<String>(tagCode);
    }
    if (!nullToAbsent || projectCode != null) {
      map['project_code'] = Variable<String>(projectCode);
    }
    map['frequency_type'] = Variable<String>(frequencyType);
    map['frequency_value'] = Variable<String>(frequencyValue);
    map['start_date'] = Variable<String>(startDate);
    map['end_type'] = Variable<String>(endType);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || endCount != null) {
      map['end_count'] = Variable<int>(endCount);
    }
    map['generated_count'] = Variable<int>(generatedCount);
    if (!nullToAbsent || lastGeneratedAt != null) {
      map['last_generated_at'] = Variable<String>(lastGeneratedAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  RecurringConfigTableCompanion toCompanion(bool nullToAbsent) {
    return RecurringConfigTableCompanion(
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      categoryCode: Value(categoryCode),
      fundId: Value(fundId),
      shopCode: shopCode == null && nullToAbsent
          ? const Value.absent()
          : Value(shopCode),
      tagCode: tagCode == null && nullToAbsent
          ? const Value.absent()
          : Value(tagCode),
      projectCode: projectCode == null && nullToAbsent
          ? const Value.absent()
          : Value(projectCode),
      frequencyType: Value(frequencyType),
      frequencyValue: Value(frequencyValue),
      startDate: Value(startDate),
      endType: Value(endType),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      endCount: endCount == null && nullToAbsent
          ? const Value.absent()
          : Value(endCount),
      generatedCount: Value(generatedCount),
      lastGeneratedAt: lastGeneratedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedAt),
      isActive: Value(isActive),
    );
  }

  factory RecurringConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringConfig(
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      description: serializer.fromJson<String?>(json['description']),
      categoryCode: serializer.fromJson<String>(json['categoryCode']),
      fundId: serializer.fromJson<String>(json['fundId']),
      shopCode: serializer.fromJson<String?>(json['shopCode']),
      tagCode: serializer.fromJson<String?>(json['tagCode']),
      projectCode: serializer.fromJson<String?>(json['projectCode']),
      frequencyType: serializer.fromJson<String>(json['frequencyType']),
      frequencyValue: serializer.fromJson<String>(json['frequencyValue']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endType: serializer.fromJson<String>(json['endType']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      endCount: serializer.fromJson<int?>(json['endCount']),
      generatedCount: serializer.fromJson<int>(json['generatedCount']),
      lastGeneratedAt: serializer.fromJson<String?>(json['lastGeneratedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
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
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'description': serializer.toJson<String?>(description),
      'categoryCode': serializer.toJson<String>(categoryCode),
      'fundId': serializer.toJson<String>(fundId),
      'shopCode': serializer.toJson<String?>(shopCode),
      'tagCode': serializer.toJson<String?>(tagCode),
      'projectCode': serializer.toJson<String?>(projectCode),
      'frequencyType': serializer.toJson<String>(frequencyType),
      'frequencyValue': serializer.toJson<String>(frequencyValue),
      'startDate': serializer.toJson<String>(startDate),
      'endType': serializer.toJson<String>(endType),
      'endDate': serializer.toJson<String?>(endDate),
      'endCount': serializer.toJson<int?>(endCount),
      'generatedCount': serializer.toJson<int>(generatedCount),
      'lastGeneratedAt': serializer.toJson<String?>(lastGeneratedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  RecurringConfig copyWith(
          {String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? type,
          double? amount,
          Value<String?> description = const Value.absent(),
          String? categoryCode,
          String? fundId,
          Value<String?> shopCode = const Value.absent(),
          Value<String?> tagCode = const Value.absent(),
          Value<String?> projectCode = const Value.absent(),
          String? frequencyType,
          String? frequencyValue,
          String? startDate,
          String? endType,
          Value<String?> endDate = const Value.absent(),
          Value<int?> endCount = const Value.absent(),
          int? generatedCount,
          Value<String?> lastGeneratedAt = const Value.absent(),
          bool? isActive}) =>
      RecurringConfig(
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        description: description.present ? description.value : this.description,
        categoryCode: categoryCode ?? this.categoryCode,
        fundId: fundId ?? this.fundId,
        shopCode: shopCode.present ? shopCode.value : this.shopCode,
        tagCode: tagCode.present ? tagCode.value : this.tagCode,
        projectCode: projectCode.present ? projectCode.value : this.projectCode,
        frequencyType: frequencyType ?? this.frequencyType,
        frequencyValue: frequencyValue ?? this.frequencyValue,
        startDate: startDate ?? this.startDate,
        endType: endType ?? this.endType,
        endDate: endDate.present ? endDate.value : this.endDate,
        endCount: endCount.present ? endCount.value : this.endCount,
        generatedCount: generatedCount ?? this.generatedCount,
        lastGeneratedAt: lastGeneratedAt.present
            ? lastGeneratedAt.value
            : this.lastGeneratedAt,
        isActive: isActive ?? this.isActive,
      );
  RecurringConfig copyWithCompanion(RecurringConfigTableCompanion data) {
    return RecurringConfig(
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      description:
          data.description.present ? data.description.value : this.description,
      categoryCode: data.categoryCode.present
          ? data.categoryCode.value
          : this.categoryCode,
      fundId: data.fundId.present ? data.fundId.value : this.fundId,
      shopCode: data.shopCode.present ? data.shopCode.value : this.shopCode,
      tagCode: data.tagCode.present ? data.tagCode.value : this.tagCode,
      projectCode:
          data.projectCode.present ? data.projectCode.value : this.projectCode,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      frequencyValue: data.frequencyValue.present
          ? data.frequencyValue.value
          : this.frequencyValue,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endType: data.endType.present ? data.endType.value : this.endType,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      endCount: data.endCount.present ? data.endCount.value : this.endCount,
      generatedCount: data.generatedCount.present
          ? data.generatedCount.value
          : this.generatedCount,
      lastGeneratedAt: data.lastGeneratedAt.present
          ? data.lastGeneratedAt.value
          : this.lastGeneratedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringConfig(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('fundId: $fundId, ')
          ..write('shopCode: $shopCode, ')
          ..write('tagCode: $tagCode, ')
          ..write('projectCode: $projectCode, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('frequencyValue: $frequencyValue, ')
          ..write('startDate: $startDate, ')
          ..write('endType: $endType, ')
          ..write('endDate: $endDate, ')
          ..write('endCount: $endCount, ')
          ..write('generatedCount: $generatedCount, ')
          ..write('lastGeneratedAt: $lastGeneratedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        type,
        amount,
        description,
        categoryCode,
        fundId,
        shopCode,
        tagCode,
        projectCode,
        frequencyType,
        frequencyValue,
        startDate,
        endType,
        endDate,
        endCount,
        generatedCount,
        lastGeneratedAt,
        isActive
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringConfig &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.description == this.description &&
          other.categoryCode == this.categoryCode &&
          other.fundId == this.fundId &&
          other.shopCode == this.shopCode &&
          other.tagCode == this.tagCode &&
          other.projectCode == this.projectCode &&
          other.frequencyType == this.frequencyType &&
          other.frequencyValue == this.frequencyValue &&
          other.startDate == this.startDate &&
          other.endType == this.endType &&
          other.endDate == this.endDate &&
          other.endCount == this.endCount &&
          other.generatedCount == this.generatedCount &&
          other.lastGeneratedAt == this.lastGeneratedAt &&
          other.isActive == this.isActive);
}

class RecurringConfigTableCompanion extends UpdateCompanion<RecurringConfig> {
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> type;
  final Value<double> amount;
  final Value<String?> description;
  final Value<String> categoryCode;
  final Value<String> fundId;
  final Value<String?> shopCode;
  final Value<String?> tagCode;
  final Value<String?> projectCode;
  final Value<String> frequencyType;
  final Value<String> frequencyValue;
  final Value<String> startDate;
  final Value<String> endType;
  final Value<String?> endDate;
  final Value<int?> endCount;
  final Value<int> generatedCount;
  final Value<String?> lastGeneratedAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const RecurringConfigTableCompanion({
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryCode = const Value.absent(),
    this.fundId = const Value.absent(),
    this.shopCode = const Value.absent(),
    this.tagCode = const Value.absent(),
    this.projectCode = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.frequencyValue = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endType = const Value.absent(),
    this.endDate = const Value.absent(),
    this.endCount = const Value.absent(),
    this.generatedCount = const Value.absent(),
    this.lastGeneratedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringConfigTableCompanion.insert({
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String type,
    required double amount,
    this.description = const Value.absent(),
    required String categoryCode,
    required String fundId,
    this.shopCode = const Value.absent(),
    this.tagCode = const Value.absent(),
    this.projectCode = const Value.absent(),
    required String frequencyType,
    required String frequencyValue,
    required String startDate,
    required String endType,
    this.endDate = const Value.absent(),
    this.endCount = const Value.absent(),
    this.generatedCount = const Value.absent(),
    this.lastGeneratedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        type = Value(type),
        amount = Value(amount),
        categoryCode = Value(categoryCode),
        fundId = Value(fundId),
        frequencyType = Value(frequencyType),
        frequencyValue = Value(frequencyValue),
        startDate = Value(startDate),
        endType = Value(endType);
  static Insertable<RecurringConfig> custom({
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? description,
    Expression<String>? categoryCode,
    Expression<String>? fundId,
    Expression<String>? shopCode,
    Expression<String>? tagCode,
    Expression<String>? projectCode,
    Expression<String>? frequencyType,
    Expression<String>? frequencyValue,
    Expression<String>? startDate,
    Expression<String>? endType,
    Expression<String>? endDate,
    Expression<int>? endCount,
    Expression<int>? generatedCount,
    Expression<String>? lastGeneratedAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (description != null) 'description': description,
      if (categoryCode != null) 'category_code': categoryCode,
      if (fundId != null) 'fund_id': fundId,
      if (shopCode != null) 'shop_code': shopCode,
      if (tagCode != null) 'tag_code': tagCode,
      if (projectCode != null) 'project_code': projectCode,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (frequencyValue != null) 'frequency_value': frequencyValue,
      if (startDate != null) 'start_date': startDate,
      if (endType != null) 'end_type': endType,
      if (endDate != null) 'end_date': endDate,
      if (endCount != null) 'end_count': endCount,
      if (generatedCount != null) 'generated_count': generatedCount,
      if (lastGeneratedAt != null) 'last_generated_at': lastGeneratedAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringConfigTableCompanion copyWith(
      {Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? type,
      Value<double>? amount,
      Value<String?>? description,
      Value<String>? categoryCode,
      Value<String>? fundId,
      Value<String?>? shopCode,
      Value<String?>? tagCode,
      Value<String?>? projectCode,
      Value<String>? frequencyType,
      Value<String>? frequencyValue,
      Value<String>? startDate,
      Value<String>? endType,
      Value<String?>? endDate,
      Value<int?>? endCount,
      Value<int>? generatedCount,
      Value<String?>? lastGeneratedAt,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return RecurringConfigTableCompanion(
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryCode: categoryCode ?? this.categoryCode,
      fundId: fundId ?? this.fundId,
      shopCode: shopCode ?? this.shopCode,
      tagCode: tagCode ?? this.tagCode,
      projectCode: projectCode ?? this.projectCode,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      startDate: startDate ?? this.startDate,
      endType: endType ?? this.endType,
      endDate: endDate ?? this.endDate,
      endCount: endCount ?? this.endCount,
      generatedCount: generatedCount ?? this.generatedCount,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      isActive: isActive ?? this.isActive,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryCode.present) {
      map['category_code'] = Variable<String>(categoryCode.value);
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
    if (frequencyType.present) {
      map['frequency_type'] = Variable<String>(frequencyType.value);
    }
    if (frequencyValue.present) {
      map['frequency_value'] = Variable<String>(frequencyValue.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endType.present) {
      map['end_type'] = Variable<String>(endType.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (endCount.present) {
      map['end_count'] = Variable<int>(endCount.value);
    }
    if (generatedCount.present) {
      map['generated_count'] = Variable<int>(generatedCount.value);
    }
    if (lastGeneratedAt.present) {
      map['last_generated_at'] = Variable<String>(lastGeneratedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringConfigTableCompanion(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('description: $description, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('fundId: $fundId, ')
          ..write('shopCode: $shopCode, ')
          ..write('tagCode: $tagCode, ')
          ..write('projectCode: $projectCode, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('frequencyValue: $frequencyValue, ')
          ..write('startDate: $startDate, ')
          ..write('endType: $endType, ')
          ..write('endDate: $endDate, ')
          ..write('endCount: $endCount, ')
          ..write('generatedCount: $generatedCount, ')
          ..write('lastGeneratedAt: $lastGeneratedAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookkeepingRuleTableTable extends BookkeepingRuleTable
    with TableInfo<$BookkeepingRuleTableTable, BookkeepingRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookkeepingRuleTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _conditionsJsonMeta =
      const VerificationMeta('conditionsJson');
  @override
  late final GeneratedColumn<String> conditionsJson = GeneratedColumn<String>(
      'conditions_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionsJsonMeta =
      const VerificationMeta('actionsJson');
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
      'actions_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        accountBookId,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        id,
        name,
        isActive,
        priority,
        conditionsJson,
        actionsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookkeeping_rule_table';
  @override
  VerificationContext validateIntegrity(Insertable<BookkeepingRule> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('conditions_json')) {
      context.handle(
          _conditionsJsonMeta,
          conditionsJson.isAcceptableOrUnknown(
              data['conditions_json']!, _conditionsJsonMeta));
    } else if (isInserting) {
      context.missing(_conditionsJsonMeta);
    }
    if (data.containsKey('actions_json')) {
      context.handle(
          _actionsJsonMeta,
          actionsJson.isAcceptableOrUnknown(
              data['actions_json']!, _actionsJsonMeta));
    } else if (isInserting) {
      context.missing(_actionsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookkeepingRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookkeepingRule(
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
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      conditionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conditions_json'])!,
      actionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actions_json'])!,
    );
  }

  @override
  $BookkeepingRuleTableTable createAlias(String alias) {
    return $BookkeepingRuleTableTable(attachedDatabase, alias);
  }
}

class BookkeepingRule extends DataClass implements Insertable<BookkeepingRule> {
  final String accountBookId;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  final String id;

  /// 规则名称
  final String name;

  /// 启用开关
  final bool isActive;

  /// 优先级（数值越大约优先）
  final int priority;

  /// 树形递归条件 JSON
  final String conditionsJson;

  /// 扁平操作 JSON
  final String actionsJson;
  const BookkeepingRule(
      {required this.accountBookId,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.name,
      required this.isActive,
      required this.priority,
      required this.conditionsJson,
      required this.actionsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_book_id'] = Variable<String>(accountBookId);
    map['created_by'] = Variable<String>(createdBy);
    map['updated_by'] = Variable<String>(updatedBy);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['priority'] = Variable<int>(priority);
    map['conditions_json'] = Variable<String>(conditionsJson);
    map['actions_json'] = Variable<String>(actionsJson);
    return map;
  }

  BookkeepingRuleTableCompanion toCompanion(bool nullToAbsent) {
    return BookkeepingRuleTableCompanion(
      accountBookId: Value(accountBookId),
      createdBy: Value(createdBy),
      updatedBy: Value(updatedBy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      priority: Value(priority),
      conditionsJson: Value(conditionsJson),
      actionsJson: Value(actionsJson),
    );
  }

  factory BookkeepingRule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookkeepingRule(
      accountBookId: serializer.fromJson<String>(json['accountBookId']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      priority: serializer.fromJson<int>(json['priority']),
      conditionsJson: serializer.fromJson<String>(json['conditionsJson']),
      actionsJson: serializer.fromJson<String>(json['actionsJson']),
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
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'priority': serializer.toJson<int>(priority),
      'conditionsJson': serializer.toJson<String>(conditionsJson),
      'actionsJson': serializer.toJson<String>(actionsJson),
    };
  }

  BookkeepingRule copyWith(
          {String? accountBookId,
          String? createdBy,
          String? updatedBy,
          int? createdAt,
          int? updatedAt,
          String? id,
          String? name,
          bool? isActive,
          int? priority,
          String? conditionsJson,
          String? actionsJson}) =>
      BookkeepingRule(
        accountBookId: accountBookId ?? this.accountBookId,
        createdBy: createdBy ?? this.createdBy,
        updatedBy: updatedBy ?? this.updatedBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        name: name ?? this.name,
        isActive: isActive ?? this.isActive,
        priority: priority ?? this.priority,
        conditionsJson: conditionsJson ?? this.conditionsJson,
        actionsJson: actionsJson ?? this.actionsJson,
      );
  BookkeepingRule copyWithCompanion(BookkeepingRuleTableCompanion data) {
    return BookkeepingRule(
      accountBookId: data.accountBookId.present
          ? data.accountBookId.value
          : this.accountBookId,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      priority: data.priority.present ? data.priority.value : this.priority,
      conditionsJson: data.conditionsJson.present
          ? data.conditionsJson.value
          : this.conditionsJson,
      actionsJson:
          data.actionsJson.present ? data.actionsJson.value : this.actionsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookkeepingRule(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('priority: $priority, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('actionsJson: $actionsJson')
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
      name,
      isActive,
      priority,
      conditionsJson,
      actionsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookkeepingRule &&
          other.accountBookId == this.accountBookId &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.priority == this.priority &&
          other.conditionsJson == this.conditionsJson &&
          other.actionsJson == this.actionsJson);
}

class BookkeepingRuleTableCompanion extends UpdateCompanion<BookkeepingRule> {
  final Value<String> accountBookId;
  final Value<String> createdBy;
  final Value<String> updatedBy;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<int> priority;
  final Value<String> conditionsJson;
  final Value<String> actionsJson;
  final Value<int> rowid;
  const BookkeepingRuleTableCompanion({
    this.accountBookId = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.priority = const Value.absent(),
    this.conditionsJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookkeepingRuleTableCompanion.insert({
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    required int createdAt,
    required int updatedAt,
    required String id,
    required String name,
    this.isActive = const Value.absent(),
    this.priority = const Value.absent(),
    required String conditionsJson,
    required String actionsJson,
    this.rowid = const Value.absent(),
  })  : accountBookId = Value(accountBookId),
        createdBy = Value(createdBy),
        updatedBy = Value(updatedBy),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        name = Value(name),
        conditionsJson = Value(conditionsJson),
        actionsJson = Value(actionsJson);
  static Insertable<BookkeepingRule> custom({
    Expression<String>? accountBookId,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<int>? priority,
    Expression<String>? conditionsJson,
    Expression<String>? actionsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountBookId != null) 'account_book_id': accountBookId,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (priority != null) 'priority': priority,
      if (conditionsJson != null) 'conditions_json': conditionsJson,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookkeepingRuleTableCompanion copyWith(
      {Value<String>? accountBookId,
      Value<String>? createdBy,
      Value<String>? updatedBy,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? name,
      Value<bool>? isActive,
      Value<int>? priority,
      Value<String>? conditionsJson,
      Value<String>? actionsJson,
      Value<int>? rowid}) {
    return BookkeepingRuleTableCompanion(
      accountBookId: accountBookId ?? this.accountBookId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      conditionsJson: conditionsJson ?? this.conditionsJson,
      actionsJson: actionsJson ?? this.actionsJson,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (conditionsJson.present) {
      map['conditions_json'] = Variable<String>(conditionsJson.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookkeepingRuleTableCompanion(')
          ..write('accountBookId: $accountBookId, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('priority: $priority, ')
          ..write('conditionsJson: $conditionsJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemRelFieldTableTable extends ItemRelFieldTable
    with TableInfo<$ItemRelFieldTableTable, ItemRelField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemRelFieldTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldCodeMeta =
      const VerificationMeta('fieldCode');
  @override
  late final GeneratedColumn<String> fieldCode = GeneratedColumn<String>(
      'field_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fieldValueMeta =
      const VerificationMeta('fieldValue');
  @override
  late final GeneratedColumn<String> fieldValue = GeneratedColumn<String>(
      'field_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [createdAt, updatedAt, id, itemId, fieldCode, fieldValue, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_rel_field_table';
  @override
  VerificationContext validateIntegrity(Insertable<ItemRelField> instance,
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
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('field_code')) {
      context.handle(_fieldCodeMeta,
          fieldCode.isAcceptableOrUnknown(data['field_code']!, _fieldCodeMeta));
    } else if (isInserting) {
      context.missing(_fieldCodeMeta);
    }
    if (data.containsKey('field_value')) {
      context.handle(
          _fieldValueMeta,
          fieldValue.isAcceptableOrUnknown(
              data['field_value']!, _fieldValueMeta));
    } else if (isInserting) {
      context.missing(_fieldValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, fieldCode, fieldValue};
  @override
  ItemRelField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRelField(
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id'])!,
      fieldCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_code'])!,
      fieldValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}field_value'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order']),
    );
  }

  @override
  $ItemRelFieldTableTable createAlias(String alias) {
    return $ItemRelFieldTableTable(attachedDatabase, alias);
  }
}

class ItemRelField extends DataClass implements Insertable<ItemRelField> {
  final int createdAt;
  final int updatedAt;
  final String id;
  final String itemId;
  final String fieldCode;
  final String fieldValue;
  final int? sortOrder;
  const ItemRelField(
      {required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.itemId,
      required this.fieldCode,
      required this.fieldValue,
      this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['field_code'] = Variable<String>(fieldCode);
    map['field_value'] = Variable<String>(fieldValue);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  ItemRelFieldTableCompanion toCompanion(bool nullToAbsent) {
    return ItemRelFieldTableCompanion(
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      itemId: Value(itemId),
      fieldCode: Value(fieldCode),
      fieldValue: Value(fieldValue),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory ItemRelField.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRelField(
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      fieldCode: serializer.fromJson<String>(json['fieldCode']),
      fieldValue: serializer.fromJson<String>(json['fieldValue']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'fieldCode': serializer.toJson<String>(fieldCode),
      'fieldValue': serializer.toJson<String>(fieldValue),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  ItemRelField copyWith(
          {int? createdAt,
          int? updatedAt,
          String? id,
          String? itemId,
          String? fieldCode,
          String? fieldValue,
          Value<int?> sortOrder = const Value.absent()}) =>
      ItemRelField(
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        id: id ?? this.id,
        itemId: itemId ?? this.itemId,
        fieldCode: fieldCode ?? this.fieldCode,
        fieldValue: fieldValue ?? this.fieldValue,
        sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
      );
  ItemRelField copyWithCompanion(ItemRelFieldTableCompanion data) {
    return ItemRelField(
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      fieldCode: data.fieldCode.present ? data.fieldCode.value : this.fieldCode,
      fieldValue:
          data.fieldValue.present ? data.fieldValue.value : this.fieldValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRelField(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fieldCode: $fieldCode, ')
          ..write('fieldValue: $fieldValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      createdAt, updatedAt, id, itemId, fieldCode, fieldValue, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRelField &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.fieldCode == this.fieldCode &&
          other.fieldValue == this.fieldValue &&
          other.sortOrder == this.sortOrder);
}

class ItemRelFieldTableCompanion extends UpdateCompanion<ItemRelField> {
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> fieldCode;
  final Value<String> fieldValue;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const ItemRelFieldTableCompanion({
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.fieldCode = const Value.absent(),
    this.fieldValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemRelFieldTableCompanion.insert({
    required int createdAt,
    required int updatedAt,
    required String id,
    required String itemId,
    required String fieldCode,
    required String fieldValue,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        id = Value(id),
        itemId = Value(itemId),
        fieldCode = Value(fieldCode),
        fieldValue = Value(fieldValue);
  static Insertable<ItemRelField> custom({
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? fieldCode,
    Expression<String>? fieldValue,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (fieldCode != null) 'field_code': fieldCode,
      if (fieldValue != null) 'field_value': fieldValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemRelFieldTableCompanion copyWith(
      {Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<String>? id,
      Value<String>? itemId,
      Value<String>? fieldCode,
      Value<String>? fieldValue,
      Value<int?>? sortOrder,
      Value<int>? rowid}) {
    return ItemRelFieldTableCompanion(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      fieldCode: fieldCode ?? this.fieldCode,
      fieldValue: fieldValue ?? this.fieldValue,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (fieldCode.present) {
      map['field_code'] = Variable<String>(fieldCode.value);
    }
    if (fieldValue.present) {
      map['field_value'] = Variable<String>(fieldValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemRelFieldTableCompanion(')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('fieldCode: $fieldCode, ')
          ..write('fieldValue: $fieldValue, ')
          ..write('sortOrder: $sortOrder, ')
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
  late final $GiftCardTableTable giftCardTable = $GiftCardTableTable(this);
  late final $ActivityDefinitionTableTable activityDefinitionTable =
      $ActivityDefinitionTableTable(this);
  late final $ActivityRecordTableTable activityRecordTable =
      $ActivityRecordTableTable(this);
  late final $VehicleTableTable vehicleTable = $VehicleTableTable(this);
  late final $FuelRecordTableTable fuelRecordTable =
      $FuelRecordTableTable(this);
  late final $ItemRelationTableTable itemRelationTable =
      $ItemRelationTableTable(this);
  late final $UserShareTableTable userShareTable = $UserShareTableTable(this);
  late final $RecurringConfigTableTable recurringConfigTable =
      $RecurringConfigTableTable(this);
  late final $BookkeepingRuleTableTable bookkeepingRuleTable =
      $BookkeepingRuleTableTable(this);
  late final $ItemRelFieldTableTable itemRelFieldTable =
      $ItemRelFieldTableTable(this);
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
        accountDebtTable,
        giftCardTable,
        activityDefinitionTable,
        activityRecordTable,
        vehicleTable,
        fuelRecordTable,
        itemRelationTable,
        userShareTable,
        recurringConfigTable,
        bookkeepingRuleTable,
        itemRelFieldTable
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
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<bool> isBookkeepingSelectable,
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
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<bool> isBookkeepingSelectable,
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

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBookkeepingSelectable => $composableBuilder(
      column: $table.isBookkeepingSelectable,
      builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBookkeepingSelectable => $composableBuilder(
      column: $table.isBookkeepingSelectable,
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

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isBookkeepingSelectable => $composableBuilder(
      column: $table.isBookkeepingSelectable, builder: (column) => column);
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
            Value<String?> parentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isBookkeepingSelectable = const Value.absent(),
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
            parentId: parentId,
            sortOrder: sortOrder,
            isBookkeepingSelectable: isBookkeepingSelectable,
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
            Value<String?> parentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isBookkeepingSelectable = const Value.absent(),
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
            parentId: parentId,
            sortOrder: sortOrder,
            isBookkeepingSelectable: isBookkeepingSelectable,
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
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<bool> isBookkeepingSelectable,
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
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<bool> isBookkeepingSelectable,
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

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBookkeepingSelectable => $composableBuilder(
      column: $table.isBookkeepingSelectable,
      builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBookkeepingSelectable => $composableBuilder(
      column: $table.isBookkeepingSelectable,
      builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isBookkeepingSelectable => $composableBuilder(
      column: $table.isBookkeepingSelectable, builder: (column) => column);
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
            Value<String?> parentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isBookkeepingSelectable = const Value.absent(),
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
            parentId: parentId,
            sortOrder: sortOrder,
            isBookkeepingSelectable: isBookkeepingSelectable,
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
            Value<String?> parentId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isBookkeepingSelectable = const Value.absent(),
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
            parentId: parentId,
            sortOrder: sortOrder,
            isBookkeepingSelectable: isBookkeepingSelectable,
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
  Value<String> scope,
  Value<String?> template,
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
  Value<String> scope,
  Value<String?> template,
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

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get template => $composableBuilder(
      column: $table.template, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get template => $composableBuilder(
      column: $table.template, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get template =>
      $composableBuilder(column: $table.template, builder: (column) => column);
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
            Value<String> scope = const Value.absent(),
            Value<String?> template = const Value.absent(),
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
            scope: scope,
            template: template,
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
            Value<String> scope = const Value.absent(),
            Value<String?> template = const Value.absent(),
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
            scope: scope,
            template: template,
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
typedef $$GiftCardTableTableCreateCompanionBuilder = GiftCardTableCompanion
    Function({
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String fromUserId,
  required String toUserId,
  Value<String?> description,
  Value<int> expiredTime,
  Value<int> sentTime,
  Value<int> receivedTime,
  Value<String> status,
  Value<int> rowid,
});
typedef $$GiftCardTableTableUpdateCompanionBuilder = GiftCardTableCompanion
    Function({
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> fromUserId,
  Value<String> toUserId,
  Value<String?> description,
  Value<int> expiredTime,
  Value<int> sentTime,
  Value<int> receivedTime,
  Value<String> status,
  Value<int> rowid,
});

class $$GiftCardTableTableFilterComposer
    extends Composer<_$AppDatabase, $GiftCardTableTable> {
  $$GiftCardTableTableFilterComposer({
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

  ColumnFilters<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toUserId => $composableBuilder(
      column: $table.toUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expiredTime => $composableBuilder(
      column: $table.expiredTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sentTime => $composableBuilder(
      column: $table.sentTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get receivedTime => $composableBuilder(
      column: $table.receivedTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$GiftCardTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GiftCardTableTable> {
  $$GiftCardTableTableOrderingComposer({
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

  ColumnOrderings<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toUserId => $composableBuilder(
      column: $table.toUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expiredTime => $composableBuilder(
      column: $table.expiredTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sentTime => $composableBuilder(
      column: $table.sentTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get receivedTime => $composableBuilder(
      column: $table.receivedTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$GiftCardTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GiftCardTableTable> {
  $$GiftCardTableTableAnnotationComposer({
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

  GeneratedColumn<String> get fromUserId => $composableBuilder(
      column: $table.fromUserId, builder: (column) => column);

  GeneratedColumn<String> get toUserId =>
      $composableBuilder(column: $table.toUserId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get expiredTime => $composableBuilder(
      column: $table.expiredTime, builder: (column) => column);

  GeneratedColumn<int> get sentTime =>
      $composableBuilder(column: $table.sentTime, builder: (column) => column);

  GeneratedColumn<int> get receivedTime => $composableBuilder(
      column: $table.receivedTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$GiftCardTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GiftCardTableTable,
    GiftCard,
    $$GiftCardTableTableFilterComposer,
    $$GiftCardTableTableOrderingComposer,
    $$GiftCardTableTableAnnotationComposer,
    $$GiftCardTableTableCreateCompanionBuilder,
    $$GiftCardTableTableUpdateCompanionBuilder,
    (GiftCard, BaseReferences<_$AppDatabase, $GiftCardTableTable, GiftCard>),
    GiftCard,
    PrefetchHooks Function()> {
  $$GiftCardTableTableTableManager(_$AppDatabase db, $GiftCardTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GiftCardTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GiftCardTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GiftCardTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> fromUserId = const Value.absent(),
            Value<String> toUserId = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> expiredTime = const Value.absent(),
            Value<int> sentTime = const Value.absent(),
            Value<int> receivedTime = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GiftCardTableCompanion(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            fromUserId: fromUserId,
            toUserId: toUserId,
            description: description,
            expiredTime: expiredTime,
            sentTime: sentTime,
            receivedTime: receivedTime,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String fromUserId,
            required String toUserId,
            Value<String?> description = const Value.absent(),
            Value<int> expiredTime = const Value.absent(),
            Value<int> sentTime = const Value.absent(),
            Value<int> receivedTime = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GiftCardTableCompanion.insert(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            fromUserId: fromUserId,
            toUserId: toUserId,
            description: description,
            expiredTime: expiredTime,
            sentTime: sentTime,
            receivedTime: receivedTime,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GiftCardTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GiftCardTableTable,
    GiftCard,
    $$GiftCardTableTableFilterComposer,
    $$GiftCardTableTableOrderingComposer,
    $$GiftCardTableTableAnnotationComposer,
    $$GiftCardTableTableCreateCompanionBuilder,
    $$GiftCardTableTableUpdateCompanionBuilder,
    (GiftCard, BaseReferences<_$AppDatabase, $GiftCardTableTable, GiftCard>),
    GiftCard,
    PrefetchHooks Function()>;
typedef $$ActivityDefinitionTableTableCreateCompanionBuilder
    = ActivityDefinitionTableCompanion Function({
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  required String emoji,
  required int color,
  Value<int> sortOrder,
  Value<int?> maxDailyCount,
  Value<int> rowid,
});
typedef $$ActivityDefinitionTableTableUpdateCompanionBuilder
    = ActivityDefinitionTableCompanion Function({
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<String> emoji,
  Value<int> color,
  Value<int> sortOrder,
  Value<int?> maxDailyCount,
  Value<int> rowid,
});

class $$ActivityDefinitionTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityDefinitionTableTable> {
  $$ActivityDefinitionTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxDailyCount => $composableBuilder(
      column: $table.maxDailyCount, builder: (column) => ColumnFilters(column));
}

class $$ActivityDefinitionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityDefinitionTableTable> {
  $$ActivityDefinitionTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxDailyCount => $composableBuilder(
      column: $table.maxDailyCount,
      builder: (column) => ColumnOrderings(column));
}

class $$ActivityDefinitionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityDefinitionTableTable> {
  $$ActivityDefinitionTableTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get maxDailyCount => $composableBuilder(
      column: $table.maxDailyCount, builder: (column) => column);
}

class $$ActivityDefinitionTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityDefinitionTableTable,
    ActivityDefinition,
    $$ActivityDefinitionTableTableFilterComposer,
    $$ActivityDefinitionTableTableOrderingComposer,
    $$ActivityDefinitionTableTableAnnotationComposer,
    $$ActivityDefinitionTableTableCreateCompanionBuilder,
    $$ActivityDefinitionTableTableUpdateCompanionBuilder,
    (
      ActivityDefinition,
      BaseReferences<_$AppDatabase, $ActivityDefinitionTableTable,
          ActivityDefinition>
    ),
    ActivityDefinition,
    PrefetchHooks Function()> {
  $$ActivityDefinitionTableTableTableManager(
      _$AppDatabase db, $ActivityDefinitionTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityDefinitionTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityDefinitionTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityDefinitionTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int?> maxDailyCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityDefinitionTableCompanion(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            sortOrder: sortOrder,
            maxDailyCount: maxDailyCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String name,
            required String emoji,
            required int color,
            Value<int> sortOrder = const Value.absent(),
            Value<int?> maxDailyCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityDefinitionTableCompanion.insert(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            sortOrder: sortOrder,
            maxDailyCount: maxDailyCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityDefinitionTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ActivityDefinitionTableTable,
        ActivityDefinition,
        $$ActivityDefinitionTableTableFilterComposer,
        $$ActivityDefinitionTableTableOrderingComposer,
        $$ActivityDefinitionTableTableAnnotationComposer,
        $$ActivityDefinitionTableTableCreateCompanionBuilder,
        $$ActivityDefinitionTableTableUpdateCompanionBuilder,
        (
          ActivityDefinition,
          BaseReferences<_$AppDatabase, $ActivityDefinitionTableTable,
              ActivityDefinition>
        ),
        ActivityDefinition,
        PrefetchHooks Function()>;
typedef $$ActivityRecordTableTableCreateCompanionBuilder
    = ActivityRecordTableCompanion Function({
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String activityName,
  Value<String?> location,
  required String recordDate,
  Value<String?> activityDefId,
  Value<int?> maxDailyCount,
  Value<String?> remark,
  Value<int> rowid,
});
typedef $$ActivityRecordTableTableUpdateCompanionBuilder
    = ActivityRecordTableCompanion Function({
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> activityName,
  Value<String?> location,
  Value<String> recordDate,
  Value<String?> activityDefId,
  Value<int?> maxDailyCount,
  Value<String?> remark,
  Value<int> rowid,
});

class $$ActivityRecordTableTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityRecordTableTable> {
  $$ActivityRecordTableTableFilterComposer({
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

  ColumnFilters<String> get activityName => $composableBuilder(
      column: $table.activityName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityDefId => $composableBuilder(
      column: $table.activityDefId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxDailyCount => $composableBuilder(
      column: $table.maxDailyCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnFilters(column));
}

class $$ActivityRecordTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityRecordTableTable> {
  $$ActivityRecordTableTableOrderingComposer({
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

  ColumnOrderings<String> get activityName => $composableBuilder(
      column: $table.activityName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityDefId => $composableBuilder(
      column: $table.activityDefId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxDailyCount => $composableBuilder(
      column: $table.maxDailyCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnOrderings(column));
}

class $$ActivityRecordTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityRecordTableTable> {
  $$ActivityRecordTableTableAnnotationComposer({
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

  GeneratedColumn<String> get activityName => $composableBuilder(
      column: $table.activityName, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get recordDate => $composableBuilder(
      column: $table.recordDate, builder: (column) => column);

  GeneratedColumn<String> get activityDefId => $composableBuilder(
      column: $table.activityDefId, builder: (column) => column);

  GeneratedColumn<int> get maxDailyCount => $composableBuilder(
      column: $table.maxDailyCount, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);
}

class $$ActivityRecordTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ActivityRecordTableTable,
    ActivityRecord,
    $$ActivityRecordTableTableFilterComposer,
    $$ActivityRecordTableTableOrderingComposer,
    $$ActivityRecordTableTableAnnotationComposer,
    $$ActivityRecordTableTableCreateCompanionBuilder,
    $$ActivityRecordTableTableUpdateCompanionBuilder,
    (
      ActivityRecord,
      BaseReferences<_$AppDatabase, $ActivityRecordTableTable, ActivityRecord>
    ),
    ActivityRecord,
    PrefetchHooks Function()> {
  $$ActivityRecordTableTableTableManager(
      _$AppDatabase db, $ActivityRecordTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityRecordTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityRecordTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityRecordTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> activityName = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String> recordDate = const Value.absent(),
            Value<String?> activityDefId = const Value.absent(),
            Value<int?> maxDailyCount = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityRecordTableCompanion(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            activityName: activityName,
            location: location,
            recordDate: recordDate,
            activityDefId: activityDefId,
            maxDailyCount: maxDailyCount,
            remark: remark,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String activityName,
            Value<String?> location = const Value.absent(),
            required String recordDate,
            Value<String?> activityDefId = const Value.absent(),
            Value<int?> maxDailyCount = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ActivityRecordTableCompanion.insert(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            activityName: activityName,
            location: location,
            recordDate: recordDate,
            activityDefId: activityDefId,
            maxDailyCount: maxDailyCount,
            remark: remark,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ActivityRecordTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ActivityRecordTableTable,
    ActivityRecord,
    $$ActivityRecordTableTableFilterComposer,
    $$ActivityRecordTableTableOrderingComposer,
    $$ActivityRecordTableTableAnnotationComposer,
    $$ActivityRecordTableTableCreateCompanionBuilder,
    $$ActivityRecordTableTableUpdateCompanionBuilder,
    (
      ActivityRecord,
      BaseReferences<_$AppDatabase, $ActivityRecordTableTable, ActivityRecord>
    ),
    ActivityRecord,
    PrefetchHooks Function()>;
typedef $$VehicleTableTableCreateCompanionBuilder = VehicleTableCompanion
    Function({
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String plateNumber,
  required String brand,
  required String model,
  Value<String?> remark,
  Value<String> defaultFuelGrade,
  Value<int> isActive,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$VehicleTableTableUpdateCompanionBuilder = VehicleTableCompanion
    Function({
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> plateNumber,
  Value<String> brand,
  Value<String> model,
  Value<String?> remark,
  Value<String> defaultFuelGrade,
  Value<int> isActive,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$VehicleTableTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleTableTable> {
  $$VehicleTableTableFilterComposer({
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

  ColumnFilters<String> get plateNumber => $composableBuilder(
      column: $table.plateNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultFuelGrade => $composableBuilder(
      column: $table.defaultFuelGrade,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$VehicleTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleTableTable> {
  $$VehicleTableTableOrderingComposer({
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

  ColumnOrderings<String> get plateNumber => $composableBuilder(
      column: $table.plateNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get model => $composableBuilder(
      column: $table.model, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultFuelGrade => $composableBuilder(
      column: $table.defaultFuelGrade,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$VehicleTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleTableTable> {
  $$VehicleTableTableAnnotationComposer({
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

  GeneratedColumn<String> get plateNumber => $composableBuilder(
      column: $table.plateNumber, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<String> get defaultFuelGrade => $composableBuilder(
      column: $table.defaultFuelGrade, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$VehicleTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VehicleTableTable,
    Vehicle,
    $$VehicleTableTableFilterComposer,
    $$VehicleTableTableOrderingComposer,
    $$VehicleTableTableAnnotationComposer,
    $$VehicleTableTableCreateCompanionBuilder,
    $$VehicleTableTableUpdateCompanionBuilder,
    (Vehicle, BaseReferences<_$AppDatabase, $VehicleTableTable, Vehicle>),
    Vehicle,
    PrefetchHooks Function()> {
  $$VehicleTableTableTableManager(_$AppDatabase db, $VehicleTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> plateNumber = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> model = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<String> defaultFuelGrade = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VehicleTableCompanion(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            plateNumber: plateNumber,
            brand: brand,
            model: model,
            remark: remark,
            defaultFuelGrade: defaultFuelGrade,
            isActive: isActive,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String plateNumber,
            required String brand,
            required String model,
            Value<String?> remark = const Value.absent(),
            Value<String> defaultFuelGrade = const Value.absent(),
            Value<int> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VehicleTableCompanion.insert(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            plateNumber: plateNumber,
            brand: brand,
            model: model,
            remark: remark,
            defaultFuelGrade: defaultFuelGrade,
            isActive: isActive,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VehicleTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VehicleTableTable,
    Vehicle,
    $$VehicleTableTableFilterComposer,
    $$VehicleTableTableOrderingComposer,
    $$VehicleTableTableAnnotationComposer,
    $$VehicleTableTableCreateCompanionBuilder,
    $$VehicleTableTableUpdateCompanionBuilder,
    (Vehicle, BaseReferences<_$AppDatabase, $VehicleTableTable, Vehicle>),
    Vehicle,
    PrefetchHooks Function()>;
typedef $$FuelRecordTableTableCreateCompanionBuilder = FuelRecordTableCompanion
    Function({
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String vehicleId,
  required int mileage,
  Value<String> energyType,
  Value<String> fuelGrade,
  required double volume,
  required double unitPrice,
  required double totalAmount,
  Value<int> isFullTank,
  Value<int> isFuelLightOn,
  Value<String?> station,
  Value<String?> remark,
  required int refuelTime,
  Value<String?> linkedBookId,
  Value<String?> linkedItemId,
  Value<int> rowid,
});
typedef $$FuelRecordTableTableUpdateCompanionBuilder = FuelRecordTableCompanion
    Function({
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> vehicleId,
  Value<int> mileage,
  Value<String> energyType,
  Value<String> fuelGrade,
  Value<double> volume,
  Value<double> unitPrice,
  Value<double> totalAmount,
  Value<int> isFullTank,
  Value<int> isFuelLightOn,
  Value<String?> station,
  Value<String?> remark,
  Value<int> refuelTime,
  Value<String?> linkedBookId,
  Value<String?> linkedItemId,
  Value<int> rowid,
});

class $$FuelRecordTableTableFilterComposer
    extends Composer<_$AppDatabase, $FuelRecordTableTable> {
  $$FuelRecordTableTableFilterComposer({
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

  ColumnFilters<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mileage => $composableBuilder(
      column: $table.mileage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fuelGrade => $composableBuilder(
      column: $table.fuelGrade, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isFullTank => $composableBuilder(
      column: $table.isFullTank, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isFuelLightOn => $composableBuilder(
      column: $table.isFuelLightOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get station => $composableBuilder(
      column: $table.station, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get refuelTime => $composableBuilder(
      column: $table.refuelTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedBookId => $composableBuilder(
      column: $table.linkedBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedItemId => $composableBuilder(
      column: $table.linkedItemId, builder: (column) => ColumnFilters(column));
}

class $$FuelRecordTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelRecordTableTable> {
  $$FuelRecordTableTableOrderingComposer({
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

  ColumnOrderings<String> get vehicleId => $composableBuilder(
      column: $table.vehicleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mileage => $composableBuilder(
      column: $table.mileage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fuelGrade => $composableBuilder(
      column: $table.fuelGrade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isFullTank => $composableBuilder(
      column: $table.isFullTank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isFuelLightOn => $composableBuilder(
      column: $table.isFuelLightOn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get station => $composableBuilder(
      column: $table.station, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remark => $composableBuilder(
      column: $table.remark, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get refuelTime => $composableBuilder(
      column: $table.refuelTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedBookId => $composableBuilder(
      column: $table.linkedBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedItemId => $composableBuilder(
      column: $table.linkedItemId,
      builder: (column) => ColumnOrderings(column));
}

class $$FuelRecordTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelRecordTableTable> {
  $$FuelRecordTableTableAnnotationComposer({
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

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<int> get mileage =>
      $composableBuilder(column: $table.mileage, builder: (column) => column);

  GeneratedColumn<String> get energyType => $composableBuilder(
      column: $table.energyType, builder: (column) => column);

  GeneratedColumn<String> get fuelGrade =>
      $composableBuilder(column: $table.fuelGrade, builder: (column) => column);

  GeneratedColumn<double> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<int> get isFullTank => $composableBuilder(
      column: $table.isFullTank, builder: (column) => column);

  GeneratedColumn<int> get isFuelLightOn => $composableBuilder(
      column: $table.isFuelLightOn, builder: (column) => column);

  GeneratedColumn<String> get station =>
      $composableBuilder(column: $table.station, builder: (column) => column);

  GeneratedColumn<String> get remark =>
      $composableBuilder(column: $table.remark, builder: (column) => column);

  GeneratedColumn<int> get refuelTime => $composableBuilder(
      column: $table.refuelTime, builder: (column) => column);

  GeneratedColumn<String> get linkedBookId => $composableBuilder(
      column: $table.linkedBookId, builder: (column) => column);

  GeneratedColumn<String> get linkedItemId => $composableBuilder(
      column: $table.linkedItemId, builder: (column) => column);
}

class $$FuelRecordTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FuelRecordTableTable,
    FuelRecord,
    $$FuelRecordTableTableFilterComposer,
    $$FuelRecordTableTableOrderingComposer,
    $$FuelRecordTableTableAnnotationComposer,
    $$FuelRecordTableTableCreateCompanionBuilder,
    $$FuelRecordTableTableUpdateCompanionBuilder,
    (
      FuelRecord,
      BaseReferences<_$AppDatabase, $FuelRecordTableTable, FuelRecord>
    ),
    FuelRecord,
    PrefetchHooks Function()> {
  $$FuelRecordTableTableTableManager(
      _$AppDatabase db, $FuelRecordTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelRecordTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelRecordTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelRecordTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> vehicleId = const Value.absent(),
            Value<int> mileage = const Value.absent(),
            Value<String> energyType = const Value.absent(),
            Value<String> fuelGrade = const Value.absent(),
            Value<double> volume = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<int> isFullTank = const Value.absent(),
            Value<int> isFuelLightOn = const Value.absent(),
            Value<String?> station = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            Value<int> refuelTime = const Value.absent(),
            Value<String?> linkedBookId = const Value.absent(),
            Value<String?> linkedItemId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FuelRecordTableCompanion(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            vehicleId: vehicleId,
            mileage: mileage,
            energyType: energyType,
            fuelGrade: fuelGrade,
            volume: volume,
            unitPrice: unitPrice,
            totalAmount: totalAmount,
            isFullTank: isFullTank,
            isFuelLightOn: isFuelLightOn,
            station: station,
            remark: remark,
            refuelTime: refuelTime,
            linkedBookId: linkedBookId,
            linkedItemId: linkedItemId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String vehicleId,
            required int mileage,
            Value<String> energyType = const Value.absent(),
            Value<String> fuelGrade = const Value.absent(),
            required double volume,
            required double unitPrice,
            required double totalAmount,
            Value<int> isFullTank = const Value.absent(),
            Value<int> isFuelLightOn = const Value.absent(),
            Value<String?> station = const Value.absent(),
            Value<String?> remark = const Value.absent(),
            required int refuelTime,
            Value<String?> linkedBookId = const Value.absent(),
            Value<String?> linkedItemId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FuelRecordTableCompanion.insert(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            vehicleId: vehicleId,
            mileage: mileage,
            energyType: energyType,
            fuelGrade: fuelGrade,
            volume: volume,
            unitPrice: unitPrice,
            totalAmount: totalAmount,
            isFullTank: isFullTank,
            isFuelLightOn: isFuelLightOn,
            station: station,
            remark: remark,
            refuelTime: refuelTime,
            linkedBookId: linkedBookId,
            linkedItemId: linkedItemId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FuelRecordTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FuelRecordTableTable,
    FuelRecord,
    $$FuelRecordTableTableFilterComposer,
    $$FuelRecordTableTableOrderingComposer,
    $$FuelRecordTableTableAnnotationComposer,
    $$FuelRecordTableTableCreateCompanionBuilder,
    $$FuelRecordTableTableUpdateCompanionBuilder,
    (
      FuelRecord,
      BaseReferences<_$AppDatabase, $FuelRecordTableTable, FuelRecord>
    ),
    FuelRecord,
    PrefetchHooks Function()>;
typedef $$ItemRelationTableTableCreateCompanionBuilder
    = ItemRelationTableCompanion Function({
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String itemId,
  required String accountBookId,
  required String relationCode,
  required String relationId,
  Value<int> rowid,
});
typedef $$ItemRelationTableTableUpdateCompanionBuilder
    = ItemRelationTableCompanion Function({
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> itemId,
  Value<String> accountBookId,
  Value<String> relationCode,
  Value<String> relationId,
  Value<int> rowid,
});

class $$ItemRelationTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItemRelationTableTable> {
  $$ItemRelationTableTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationCode => $composableBuilder(
      column: $table.relationCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationId => $composableBuilder(
      column: $table.relationId, builder: (column) => ColumnFilters(column));
}

class $$ItemRelationTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemRelationTableTable> {
  $$ItemRelationTableTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationCode => $composableBuilder(
      column: $table.relationCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationId => $composableBuilder(
      column: $table.relationId, builder: (column) => ColumnOrderings(column));
}

class $$ItemRelationTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemRelationTableTable> {
  $$ItemRelationTableTableAnnotationComposer({
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

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get accountBookId => $composableBuilder(
      column: $table.accountBookId, builder: (column) => column);

  GeneratedColumn<String> get relationCode => $composableBuilder(
      column: $table.relationCode, builder: (column) => column);

  GeneratedColumn<String> get relationId => $composableBuilder(
      column: $table.relationId, builder: (column) => column);
}

class $$ItemRelationTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemRelationTableTable,
    ItemRelation,
    $$ItemRelationTableTableFilterComposer,
    $$ItemRelationTableTableOrderingComposer,
    $$ItemRelationTableTableAnnotationComposer,
    $$ItemRelationTableTableCreateCompanionBuilder,
    $$ItemRelationTableTableUpdateCompanionBuilder,
    (
      ItemRelation,
      BaseReferences<_$AppDatabase, $ItemRelationTableTable, ItemRelation>
    ),
    ItemRelation,
    PrefetchHooks Function()> {
  $$ItemRelationTableTableTableManager(
      _$AppDatabase db, $ItemRelationTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemRelationTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemRelationTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemRelationTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> accountBookId = const Value.absent(),
            Value<String> relationCode = const Value.absent(),
            Value<String> relationId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemRelationTableCompanion(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            itemId: itemId,
            accountBookId: accountBookId,
            relationCode: relationCode,
            relationId: relationId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String itemId,
            required String accountBookId,
            required String relationCode,
            required String relationId,
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemRelationTableCompanion.insert(
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            itemId: itemId,
            accountBookId: accountBookId,
            relationCode: relationCode,
            relationId: relationId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemRelationTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemRelationTableTable,
    ItemRelation,
    $$ItemRelationTableTableFilterComposer,
    $$ItemRelationTableTableOrderingComposer,
    $$ItemRelationTableTableAnnotationComposer,
    $$ItemRelationTableTableCreateCompanionBuilder,
    $$ItemRelationTableTableUpdateCompanionBuilder,
    (
      ItemRelation,
      BaseReferences<_$AppDatabase, $ItemRelationTableTable, ItemRelation>
    ),
    ItemRelation,
    PrefetchHooks Function()>;
typedef $$UserShareTableTableCreateCompanionBuilder = UserShareTableCompanion
    Function({
  required int createdAt,
  required int updatedAt,
  required String id,
  required String ownerUserId,
  required String targetUserId,
  required String businessType,
  Value<bool> isEnabled,
  Value<int> rowid,
});
typedef $$UserShareTableTableUpdateCompanionBuilder = UserShareTableCompanion
    Function({
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> ownerUserId,
  Value<String> targetUserId,
  Value<String> businessType,
  Value<bool> isEnabled,
  Value<int> rowid,
});

class $$UserShareTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserShareTableTable> {
  $$UserShareTableTableFilterComposer({
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

  ColumnFilters<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetUserId => $composableBuilder(
      column: $table.targetUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessType => $composableBuilder(
      column: $table.businessType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnFilters(column));
}

class $$UserShareTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserShareTableTable> {
  $$UserShareTableTableOrderingComposer({
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

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetUserId => $composableBuilder(
      column: $table.targetUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessType => $composableBuilder(
      column: $table.businessType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
      column: $table.isEnabled, builder: (column) => ColumnOrderings(column));
}

class $$UserShareTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserShareTableTable> {
  $$UserShareTableTableAnnotationComposer({
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

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
      column: $table.ownerUserId, builder: (column) => column);

  GeneratedColumn<String> get targetUserId => $composableBuilder(
      column: $table.targetUserId, builder: (column) => column);

  GeneratedColumn<String> get businessType => $composableBuilder(
      column: $table.businessType, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);
}

class $$UserShareTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserShareTableTable,
    UserShare,
    $$UserShareTableTableFilterComposer,
    $$UserShareTableTableOrderingComposer,
    $$UserShareTableTableAnnotationComposer,
    $$UserShareTableTableCreateCompanionBuilder,
    $$UserShareTableTableUpdateCompanionBuilder,
    (UserShare, BaseReferences<_$AppDatabase, $UserShareTableTable, UserShare>),
    UserShare,
    PrefetchHooks Function()> {
  $$UserShareTableTableTableManager(
      _$AppDatabase db, $UserShareTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserShareTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserShareTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserShareTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> ownerUserId = const Value.absent(),
            Value<String> targetUserId = const Value.absent(),
            Value<String> businessType = const Value.absent(),
            Value<bool> isEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserShareTableCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            ownerUserId: ownerUserId,
            targetUserId: targetUserId,
            businessType: businessType,
            isEnabled: isEnabled,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int createdAt,
            required int updatedAt,
            required String id,
            required String ownerUserId,
            required String targetUserId,
            required String businessType,
            Value<bool> isEnabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserShareTableCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            ownerUserId: ownerUserId,
            targetUserId: targetUserId,
            businessType: businessType,
            isEnabled: isEnabled,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserShareTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserShareTableTable,
    UserShare,
    $$UserShareTableTableFilterComposer,
    $$UserShareTableTableOrderingComposer,
    $$UserShareTableTableAnnotationComposer,
    $$UserShareTableTableCreateCompanionBuilder,
    $$UserShareTableTableUpdateCompanionBuilder,
    (UserShare, BaseReferences<_$AppDatabase, $UserShareTableTable, UserShare>),
    UserShare,
    PrefetchHooks Function()>;
typedef $$RecurringConfigTableTableCreateCompanionBuilder
    = RecurringConfigTableCompanion Function({
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String type,
  required double amount,
  Value<String?> description,
  required String categoryCode,
  required String fundId,
  Value<String?> shopCode,
  Value<String?> tagCode,
  Value<String?> projectCode,
  required String frequencyType,
  required String frequencyValue,
  required String startDate,
  required String endType,
  Value<String?> endDate,
  Value<int?> endCount,
  Value<int> generatedCount,
  Value<String?> lastGeneratedAt,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$RecurringConfigTableTableUpdateCompanionBuilder
    = RecurringConfigTableCompanion Function({
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> type,
  Value<double> amount,
  Value<String?> description,
  Value<String> categoryCode,
  Value<String> fundId,
  Value<String?> shopCode,
  Value<String?> tagCode,
  Value<String?> projectCode,
  Value<String> frequencyType,
  Value<String> frequencyValue,
  Value<String> startDate,
  Value<String> endType,
  Value<String?> endDate,
  Value<int?> endCount,
  Value<int> generatedCount,
  Value<String?> lastGeneratedAt,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$RecurringConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringConfigTableTable> {
  $$RecurringConfigTableTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fundId => $composableBuilder(
      column: $table.fundId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shopCode => $composableBuilder(
      column: $table.shopCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagCode => $composableBuilder(
      column: $table.tagCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequencyType => $composableBuilder(
      column: $table.frequencyType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequencyValue => $composableBuilder(
      column: $table.frequencyValue,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endType => $composableBuilder(
      column: $table.endType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endCount => $composableBuilder(
      column: $table.endCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get generatedCount => $composableBuilder(
      column: $table.generatedCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastGeneratedAt => $composableBuilder(
      column: $table.lastGeneratedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$RecurringConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringConfigTableTable> {
  $$RecurringConfigTableTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fundId => $composableBuilder(
      column: $table.fundId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shopCode => $composableBuilder(
      column: $table.shopCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagCode => $composableBuilder(
      column: $table.tagCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequencyType => $composableBuilder(
      column: $table.frequencyType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequencyValue => $composableBuilder(
      column: $table.frequencyValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endType => $composableBuilder(
      column: $table.endType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endCount => $composableBuilder(
      column: $table.endCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get generatedCount => $composableBuilder(
      column: $table.generatedCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastGeneratedAt => $composableBuilder(
      column: $table.lastGeneratedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$RecurringConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringConfigTableTable> {
  $$RecurringConfigTableTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode, builder: (column) => column);

  GeneratedColumn<String> get fundId =>
      $composableBuilder(column: $table.fundId, builder: (column) => column);

  GeneratedColumn<String> get shopCode =>
      $composableBuilder(column: $table.shopCode, builder: (column) => column);

  GeneratedColumn<String> get tagCode =>
      $composableBuilder(column: $table.tagCode, builder: (column) => column);

  GeneratedColumn<String> get projectCode => $composableBuilder(
      column: $table.projectCode, builder: (column) => column);

  GeneratedColumn<String> get frequencyType => $composableBuilder(
      column: $table.frequencyType, builder: (column) => column);

  GeneratedColumn<String> get frequencyValue => $composableBuilder(
      column: $table.frequencyValue, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endType =>
      $composableBuilder(column: $table.endType, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get endCount =>
      $composableBuilder(column: $table.endCount, builder: (column) => column);

  GeneratedColumn<int> get generatedCount => $composableBuilder(
      column: $table.generatedCount, builder: (column) => column);

  GeneratedColumn<String> get lastGeneratedAt => $composableBuilder(
      column: $table.lastGeneratedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$RecurringConfigTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringConfigTableTable,
    RecurringConfig,
    $$RecurringConfigTableTableFilterComposer,
    $$RecurringConfigTableTableOrderingComposer,
    $$RecurringConfigTableTableAnnotationComposer,
    $$RecurringConfigTableTableCreateCompanionBuilder,
    $$RecurringConfigTableTableUpdateCompanionBuilder,
    (
      RecurringConfig,
      BaseReferences<_$AppDatabase, $RecurringConfigTableTable, RecurringConfig>
    ),
    RecurringConfig,
    PrefetchHooks Function()> {
  $$RecurringConfigTableTableTableManager(
      _$AppDatabase db, $RecurringConfigTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringConfigTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringConfigTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringConfigTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> categoryCode = const Value.absent(),
            Value<String> fundId = const Value.absent(),
            Value<String?> shopCode = const Value.absent(),
            Value<String?> tagCode = const Value.absent(),
            Value<String?> projectCode = const Value.absent(),
            Value<String> frequencyType = const Value.absent(),
            Value<String> frequencyValue = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String> endType = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<int?> endCount = const Value.absent(),
            Value<int> generatedCount = const Value.absent(),
            Value<String?> lastGeneratedAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringConfigTableCompanion(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            amount: amount,
            description: description,
            categoryCode: categoryCode,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            startDate: startDate,
            endType: endType,
            endDate: endDate,
            endCount: endCount,
            generatedCount: generatedCount,
            lastGeneratedAt: lastGeneratedAt,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String type,
            required double amount,
            Value<String?> description = const Value.absent(),
            required String categoryCode,
            required String fundId,
            Value<String?> shopCode = const Value.absent(),
            Value<String?> tagCode = const Value.absent(),
            Value<String?> projectCode = const Value.absent(),
            required String frequencyType,
            required String frequencyValue,
            required String startDate,
            required String endType,
            Value<String?> endDate = const Value.absent(),
            Value<int?> endCount = const Value.absent(),
            Value<int> generatedCount = const Value.absent(),
            Value<String?> lastGeneratedAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringConfigTableCompanion.insert(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            type: type,
            amount: amount,
            description: description,
            categoryCode: categoryCode,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            startDate: startDate,
            endType: endType,
            endDate: endDate,
            endCount: endCount,
            generatedCount: generatedCount,
            lastGeneratedAt: lastGeneratedAt,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecurringConfigTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RecurringConfigTableTable,
        RecurringConfig,
        $$RecurringConfigTableTableFilterComposer,
        $$RecurringConfigTableTableOrderingComposer,
        $$RecurringConfigTableTableAnnotationComposer,
        $$RecurringConfigTableTableCreateCompanionBuilder,
        $$RecurringConfigTableTableUpdateCompanionBuilder,
        (
          RecurringConfig,
          BaseReferences<_$AppDatabase, $RecurringConfigTableTable,
              RecurringConfig>
        ),
        RecurringConfig,
        PrefetchHooks Function()>;
typedef $$BookkeepingRuleTableTableCreateCompanionBuilder
    = BookkeepingRuleTableCompanion Function({
  required String accountBookId,
  required String createdBy,
  required String updatedBy,
  required int createdAt,
  required int updatedAt,
  required String id,
  required String name,
  Value<bool> isActive,
  Value<int> priority,
  required String conditionsJson,
  required String actionsJson,
  Value<int> rowid,
});
typedef $$BookkeepingRuleTableTableUpdateCompanionBuilder
    = BookkeepingRuleTableCompanion Function({
  Value<String> accountBookId,
  Value<String> createdBy,
  Value<String> updatedBy,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> name,
  Value<bool> isActive,
  Value<int> priority,
  Value<String> conditionsJson,
  Value<String> actionsJson,
  Value<int> rowid,
});

class $$BookkeepingRuleTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookkeepingRuleTableTable> {
  $$BookkeepingRuleTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnFilters(column));
}

class $$BookkeepingRuleTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookkeepingRuleTableTable> {
  $$BookkeepingRuleTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnOrderings(column));
}

class $$BookkeepingRuleTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookkeepingRuleTableTable> {
  $$BookkeepingRuleTableTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get conditionsJson => $composableBuilder(
      column: $table.conditionsJson, builder: (column) => column);

  GeneratedColumn<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => column);
}

class $$BookkeepingRuleTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookkeepingRuleTableTable,
    BookkeepingRule,
    $$BookkeepingRuleTableTableFilterComposer,
    $$BookkeepingRuleTableTableOrderingComposer,
    $$BookkeepingRuleTableTableAnnotationComposer,
    $$BookkeepingRuleTableTableCreateCompanionBuilder,
    $$BookkeepingRuleTableTableUpdateCompanionBuilder,
    (
      BookkeepingRule,
      BaseReferences<_$AppDatabase, $BookkeepingRuleTableTable, BookkeepingRule>
    ),
    BookkeepingRule,
    PrefetchHooks Function()> {
  $$BookkeepingRuleTableTableTableManager(
      _$AppDatabase db, $BookkeepingRuleTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookkeepingRuleTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookkeepingRuleTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookkeepingRuleTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> accountBookId = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<String> updatedBy = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> conditionsJson = const Value.absent(),
            Value<String> actionsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookkeepingRuleTableCompanion(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            isActive: isActive,
            priority: priority,
            conditionsJson: conditionsJson,
            actionsJson: actionsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String accountBookId,
            required String createdBy,
            required String updatedBy,
            required int createdAt,
            required int updatedAt,
            required String id,
            required String name,
            Value<bool> isActive = const Value.absent(),
            Value<int> priority = const Value.absent(),
            required String conditionsJson,
            required String actionsJson,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookkeepingRuleTableCompanion.insert(
            accountBookId: accountBookId,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            name: name,
            isActive: isActive,
            priority: priority,
            conditionsJson: conditionsJson,
            actionsJson: actionsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookkeepingRuleTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $BookkeepingRuleTableTable,
        BookkeepingRule,
        $$BookkeepingRuleTableTableFilterComposer,
        $$BookkeepingRuleTableTableOrderingComposer,
        $$BookkeepingRuleTableTableAnnotationComposer,
        $$BookkeepingRuleTableTableCreateCompanionBuilder,
        $$BookkeepingRuleTableTableUpdateCompanionBuilder,
        (
          BookkeepingRule,
          BaseReferences<_$AppDatabase, $BookkeepingRuleTableTable,
              BookkeepingRule>
        ),
        BookkeepingRule,
        PrefetchHooks Function()>;
typedef $$ItemRelFieldTableTableCreateCompanionBuilder
    = ItemRelFieldTableCompanion Function({
  required int createdAt,
  required int updatedAt,
  required String id,
  required String itemId,
  required String fieldCode,
  required String fieldValue,
  Value<int?> sortOrder,
  Value<int> rowid,
});
typedef $$ItemRelFieldTableTableUpdateCompanionBuilder
    = ItemRelFieldTableCompanion Function({
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<String> id,
  Value<String> itemId,
  Value<String> fieldCode,
  Value<String> fieldValue,
  Value<int?> sortOrder,
  Value<int> rowid,
});

class $$ItemRelFieldTableTableFilterComposer
    extends Composer<_$AppDatabase, $ItemRelFieldTableTable> {
  $$ItemRelFieldTableTableFilterComposer({
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

  ColumnFilters<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldCode => $composableBuilder(
      column: $table.fieldCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fieldValue => $composableBuilder(
      column: $table.fieldValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$ItemRelFieldTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemRelFieldTableTable> {
  $$ItemRelFieldTableTableOrderingComposer({
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

  ColumnOrderings<String> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldCode => $composableBuilder(
      column: $table.fieldCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fieldValue => $composableBuilder(
      column: $table.fieldValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$ItemRelFieldTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemRelFieldTableTable> {
  $$ItemRelFieldTableTableAnnotationComposer({
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

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get fieldCode =>
      $composableBuilder(column: $table.fieldCode, builder: (column) => column);

  GeneratedColumn<String> get fieldValue => $composableBuilder(
      column: $table.fieldValue, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ItemRelFieldTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ItemRelFieldTableTable,
    ItemRelField,
    $$ItemRelFieldTableTableFilterComposer,
    $$ItemRelFieldTableTableOrderingComposer,
    $$ItemRelFieldTableTableAnnotationComposer,
    $$ItemRelFieldTableTableCreateCompanionBuilder,
    $$ItemRelFieldTableTableUpdateCompanionBuilder,
    (
      ItemRelField,
      BaseReferences<_$AppDatabase, $ItemRelFieldTableTable, ItemRelField>
    ),
    ItemRelField,
    PrefetchHooks Function()> {
  $$ItemRelFieldTableTableTableManager(
      _$AppDatabase db, $ItemRelFieldTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemRelFieldTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemRelFieldTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemRelFieldTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<String> id = const Value.absent(),
            Value<String> itemId = const Value.absent(),
            Value<String> fieldCode = const Value.absent(),
            Value<String> fieldValue = const Value.absent(),
            Value<int?> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemRelFieldTableCompanion(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            itemId: itemId,
            fieldCode: fieldCode,
            fieldValue: fieldValue,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int createdAt,
            required int updatedAt,
            required String id,
            required String itemId,
            required String fieldCode,
            required String fieldValue,
            Value<int?> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemRelFieldTableCompanion.insert(
            createdAt: createdAt,
            updatedAt: updatedAt,
            id: id,
            itemId: itemId,
            fieldCode: fieldCode,
            fieldValue: fieldValue,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ItemRelFieldTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ItemRelFieldTableTable,
    ItemRelField,
    $$ItemRelFieldTableTableFilterComposer,
    $$ItemRelFieldTableTableOrderingComposer,
    $$ItemRelFieldTableTableAnnotationComposer,
    $$ItemRelFieldTableTableCreateCompanionBuilder,
    $$ItemRelFieldTableTableUpdateCompanionBuilder,
    (
      ItemRelField,
      BaseReferences<_$AppDatabase, $ItemRelFieldTableTable, ItemRelField>
    ),
    ItemRelField,
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
  $$GiftCardTableTableTableManager get giftCardTable =>
      $$GiftCardTableTableTableManager(_db, _db.giftCardTable);
  $$ActivityDefinitionTableTableTableManager get activityDefinitionTable =>
      $$ActivityDefinitionTableTableTableManager(
          _db, _db.activityDefinitionTable);
  $$ActivityRecordTableTableTableManager get activityRecordTable =>
      $$ActivityRecordTableTableTableManager(_db, _db.activityRecordTable);
  $$VehicleTableTableTableManager get vehicleTable =>
      $$VehicleTableTableTableManager(_db, _db.vehicleTable);
  $$FuelRecordTableTableTableManager get fuelRecordTable =>
      $$FuelRecordTableTableTableManager(_db, _db.fuelRecordTable);
  $$ItemRelationTableTableTableManager get itemRelationTable =>
      $$ItemRelationTableTableTableManager(_db, _db.itemRelationTable);
  $$UserShareTableTableTableManager get userShareTable =>
      $$UserShareTableTableTableManager(_db, _db.userShareTable);
  $$RecurringConfigTableTableTableManager get recurringConfigTable =>
      $$RecurringConfigTableTableTableManager(_db, _db.recurringConfigTable);
  $$BookkeepingRuleTableTableTableManager get bookkeepingRuleTable =>
      $$BookkeepingRuleTableTableTableManager(_db, _db.bookkeepingRuleTable);
  $$ItemRelFieldTableTableTableManager get itemRelFieldTable =>
      $$ItemRelFieldTableTableTableManager(_db, _db.itemRelFieldTable);
}
