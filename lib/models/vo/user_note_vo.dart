import '../../database/database.dart';

class UserNoteVO {
  final String id;
  final String content;
  final String noteDate;
  final String accountBookId;

  UserNoteVO({
    required this.id,
    required this.content,
    required this.noteDate,
    required this.accountBookId,
  });

  static UserNoteVO fromAccountNote(AccountNote note) {
    return UserNoteVO(
      id: note.id,
      content: note.content ?? '',
      noteDate: note.noteDate,
      accountBookId: note.accountBookId,
    );
  }
}
