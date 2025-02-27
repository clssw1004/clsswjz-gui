import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/note_type.dart';
import '../models/vo/book_meta.dart';
import '../providers/books_provider.dart';
import '../providers/item_list_provider.dart';
import '../providers/note_list_provider.dart';
import '../routes/app_routes.dart';

/// 导航工具类
class NavigationUtil {
  /// 私有构造函数，防止实例化
  NavigationUtil._();

  /// 获取当前选中的账本
  static BookMetaVO? _getCurrentBook(BuildContext context) {
    try {
      final provider = Provider.of<BooksProvider>(context, listen: false);
      return provider.selectedBook;
    } catch (e) {
      debugPrint('获取当前账本失败: $e');
      return null;
    }
  }

  /// 刷新记账列表数据
  static void _refreshItemList(BuildContext context) {
    if (!context.mounted) return;
    try {
      final provider = Provider.of<ItemListProvider>(context, listen: false);
      provider.loadItems();
    } catch (e) {
      debugPrint('刷新记账列表失败: $e');
    }
  }

  /// 刷新记事列表数据
  static void _refreshNoteList(BuildContext context) {
    if (!context.mounted) return;
    try {
      final provider = Provider.of<NoteListProvider>(context, listen: false);
      provider.loadNotes();
    } catch (e) {
      debugPrint('刷新记事列表失败: $e');
    }
  }

  /// 跳转到记账新增页面
  static Future<void> toItemAdd(BuildContext context) async {
    final accountBook = _getCurrentBook(context);
    if (accountBook == null) {
      debugPrint('账本不能为空');
      return;
    }

    try {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.itemAdd,
        arguments: [accountBook],
      );
      if (result == true) {
        _refreshItemList(context);
      }
    } catch (e) {
      debugPrint('跳转记账新增页面失败: $e');
    }
  }

  /// 跳转到记事新增页面
  static Future<void> toNoteAdd(
    BuildContext context, {
    NoteType type = NoteType.note,
  }) async {
    final accountBook = _getCurrentBook(context);
    if (accountBook == null) {
      debugPrint('账本不能为空');
      return;
    }

    try {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.noteAdd,
        arguments: [accountBook, type],
      );
      if (result == true) {
        _refreshNoteList(context);
      }
    } catch (e) {
      debugPrint('跳转记事新增页面失败: $e');
    }
  }

  /// 跳转到债务新增页面
  static Future<void> toDebtAdd(BuildContext context) async {
    final accountBook = _getCurrentBook(context);
    if (accountBook == null) {
      debugPrint('账本不能为空');
      return;
    }

    try {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.debtAdd,
        arguments: [accountBook],
      );
      if (result == true) {
        _refreshItemList(context);
      }
    } catch (e) {
      debugPrint('跳转债务新增页面失败: $e');
    }
  }

  /// 跳转到记账编辑页面
  static Future<void> toItemEdit(
    BuildContext context,
    dynamic item,
  ) async {
    final accountBook = _getCurrentBook(context);
    if (accountBook == null) {
      debugPrint('账本不能为空');
      return;
    }
    if (item == null) {
      debugPrint('记账不能为空');
      return;
    }

    try {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.itemEdit,
        arguments: [accountBook, item],
      );
      if (result == true) {
        _refreshItemList(context);
      }
    } catch (e) {
      debugPrint('跳转记账编辑页面失败: $e');
    }
  }

  /// 跳转到记事编辑页面
  static Future<void> toNoteEdit(
    BuildContext context,
    dynamic note,
  ) async {
    final accountBook = _getCurrentBook(context);
    if (accountBook == null) {
      debugPrint('账本不能为空');
      return;
    }
    if (note == null) {
      debugPrint('记事不能为空');
      return;
    }

    try {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.noteEdit,
        arguments: [note, accountBook],
      );
      if (result == true) {
        _refreshNoteList(context);
      }
    } catch (e) {
      debugPrint('跳转记事编辑页面失败: $e');
    }
  }
}
