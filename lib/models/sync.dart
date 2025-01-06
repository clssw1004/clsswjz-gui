import '../database/database.dart';

class SyncResponseDTO {
  final List<AccountBookLog> logs;
  final List<User> users;
  final List<AccountBook> accountBooks;
  final List<AccountBookItem> items;
}
