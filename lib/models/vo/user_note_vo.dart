import '../../database/database.dart';

class UserNoteVO {
  /// ID
  final String id;

  /// 标题
  final String? title;

  /// 内容
  final String content;

  /// 笔记日期
  final String noteDate;

  /// 账本ID
  final String accountBookId;

  const UserNoteVO({
    required this.id,
    this.title,
    required this.content,
    required this.noteDate,
    required this.accountBookId,
  });

  UserNoteVO copyWith({
    String? id,
    String? title,
    required String content,
    String? noteDate,
    String? accountBookId,
  }) {
    return UserNoteVO(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content,
      noteDate: noteDate ?? this.noteDate,
      accountBookId: accountBookId ?? this.accountBookId,
    );
  }

  static UserNoteVO fromAccountNote(AccountNote note) {
    return UserNoteVO(
      id: note.id,
      title: note.title ?? '',
      content: note.content ?? '',
      noteDate: note.noteDate,
      accountBookId: note.accountBookId,
    );
  }
}
