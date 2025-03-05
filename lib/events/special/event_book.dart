import '../../database/database.dart';
import '../../enums/operate_type.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_note_vo.dart';

/// 账本切换事件
class BookChangedEvent {
  final UserBookVO book;
  const BookChangedEvent(this.book);
}

/// 账目变动事件
class ItemChangedEvent {
  final AccountItem item;
  final OperateType operateType;
  const ItemChangedEvent(this.operateType, this.item);
}

class NoteChangedEvent {
  final AccountNote note;
  final OperateType operateType;
  const NoteChangedEvent(this.operateType, this.note);
}

class DebtChangedEvent {
  final AccountDebt debt;
  final OperateType operateType;
  const DebtChangedEvent(this.operateType, this.debt);
}
