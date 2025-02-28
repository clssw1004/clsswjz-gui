import '../../models/vo/user_book_vo.dart';

/// 账本切换事件
class BookChangedEvent {
  final UserBookVO book;
  const BookChangedEvent(this.book);
}
