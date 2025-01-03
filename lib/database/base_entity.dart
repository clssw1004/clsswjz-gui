import 'package:clsswjz/utils/date_util.dart';
import 'package:clsswjz/utils/id_util.dart';
import 'package:drift/drift.dart';

class StringIdEntity {
  final String id;

  StringIdEntity({
    required this.id,
  });

  StringIdEntity.gen() : id = IdUtils.genId();
}

class DateEntity extends StringIdEntity {
  final int createdAt;
  int updatedAt;

  DateEntity({
    required super.id,
    required this.createdAt,
    required this.updatedAt,
  });

  DateEntity.update(String id, int createdAt)
      : this(id: id, createdAt: createdAt, updatedAt: DateUtil.now());

  DateEntity.now()
      : createdAt = DateUtil.now(),
        updatedAt = DateUtil.now(),
        super.gen();
}

class BaseEntity extends DateEntity {
  final String createdBy;
  final String updatedBy;

  BaseEntity({
    required this.createdBy,
    required this.updatedBy,
    required super.id,
    required super.createdAt,
    required super.updatedAt,
  });

  BaseEntity.withUser(String userId)
      : createdBy = userId,
        updatedBy = userId,
        super.now();
}

Value<T> nullIfAbsent<T>(T? value) =>
    value == null ? const Value.absent() : Value(value);
