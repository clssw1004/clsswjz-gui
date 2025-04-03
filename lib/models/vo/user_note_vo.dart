import '../../database/database.dart';

class UserNoteVO {
  /// ID
  final String id;

  /// 标题
  final String? title;

  /// 内容
  final String content;

  /// 纯文本内容
  final String plainContent;

  /// 账本ID
  final String accountBookId;

  /// 创建时间
  final int? createdAt;

  /// 更新时间
  final int? updatedAt;

  /// 创建人
  final String? createdBy;

  /// 更新人
  final String? updatedBy;

  const UserNoteVO({
    required this.id,
    this.title,
    required this.content,
    required this.plainContent,
    required this.accountBookId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  UserNoteVO copyWith({
    String? id,
    String? title,
    required String content,
    required String plainContent,
    String? accountBookId,
    int? createdAt,
    int? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return UserNoteVO(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content,
      plainContent: plainContent,
      accountBookId: accountBookId ?? this.accountBookId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  static UserNoteVO fromAccountNote(AccountNote note) {
    return UserNoteVO(
      id: note.id,
      title: note.title ?? '',
      content: note.content ?? '',
      plainContent: note.plainContent ?? '',
      accountBookId: note.accountBookId,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      createdBy: note.createdBy,
      updatedBy: note.updatedBy,
    );
  }
}
