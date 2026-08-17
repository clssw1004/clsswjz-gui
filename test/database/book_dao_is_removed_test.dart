import 'package:clsswjz_gui/database/dao/book_dao.dart';
import 'package:clsswjz_gui/database/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BookDao bookDao;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    bookDao = BookDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  AccountBookTableCompanion makeBook(String id, String owner) {
    return AccountBookTableCompanion.insert(
      id: id,
      name: '账本',
      currencySymbol: const Value('¥'),
      createdAt: 1000,
      updatedAt: 1000,
      createdBy: owner,
      updatedBy: owner,
    );
  }

  test('schemaVersion is 20 with isRemoved local column', () {
    expect(db.schemaVersion, 20);
    // isRemoved 是本地列，能写入并读取
    final companion = makeBook('book-0', 'u1')
        .copyWith(isRemoved: const Value(true));
    expect(companion.isRemoved.value, isTrue);
  });

  test('setRemoved hides book from queries but keeps local data', () async {
    await db.into(db.accountBookTable).insert(makeBook('book-1', 'u1'));

    // 创建者可看到
    expect(await bookDao.findByCreatedBy('u1'), hasLength(1));

    // 标记移除：列表不可见，但数据保留
    await bookDao.setRemoved('book-1', removed: true);
    expect(await bookDao.findByCreatedBy('u1'), hasLength(0));
    expect(await bookDao.findById('book-1'), isNotNull);

    // 重新加入：取消隐藏，重新可见（本地数据复用，无需全量重拉）
    await bookDao.setRemoved('book-1', removed: false);
    expect(await bookDao.findByCreatedBy('u1'), hasLength(1));
  });

  test('removed books are excluded from membership queries too', () async {
    await db.into(db.accountBookTable).insert(makeBook('book-2', 'u1'));
    await db.into(db.relAccountbookUserTable).insert(
      RelAccountbookUserTableCompanion.insert(
        id: 'rel-2',
        userId: 'u2',
        accountBookId: 'book-2',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    expect(await bookDao.findPermissionedByUserId('u2'), hasLength(1));

    await bookDao.setRemoved('book-2', removed: true);
    expect(await bookDao.findPermissionedByUserId('u2'), hasLength(0));
  });
}
