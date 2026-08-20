import 'dart:async';
import 'package:flutter/material.dart';
import '../database/database.dart';
import '../drivers/driver_factory.dart';
import '../enums/note_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';
import '../events/special/event_book.dart';
import '../manager/app_config_manager.dart';
import '../manager/dao_manager.dart';
import '../models/common.dart';
import '../models/vo/user_note_vo.dart';
import '../models/dto/note_filter_dto.dart';

/// 缺失月份占位数据（报表模块）
class MissingMonthItem {
  final int year;
  final int month;
  MissingMonthItem({required this.year, required this.month});
}

/// 报表列表 Provider（仅展示 noteType='REPORT' 的月度收支报告）。
///
/// 与普通记事 [NoteListProvider] 相互独立，通过 NoteChangedEvent 的
/// noteType 分流，互不串台。
class ReportListProvider extends ChangeNotifier {
  late final StreamSubscription _bookSubscription;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _noteChangedSubscription;

  /// 报表固定查询的类型
  final String _noteType = NoteType.report.code;

  /// 报表列表
  final List<UserNoteVO> _reports = [];
  List<UserNoteVO> get reports => _reports;

  /// 是否加载中
  bool _loading = false;
  bool get loading => _loading;

  /// 是否还有更多数据
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// 当前页码
  int _page = 1;

  /// 每页数量
  static const int _pageSize = 20;

  String? _currentBookId;

  /// 搜索关键字
  String? _keyword;
  String? get keyword => _keyword;

  /// 当前年未生成报表的月份列表
  final List<MissingMonthItem> _missingMonths = [];
  List<MissingMonthItem> get missingMonths => _missingMonths;

  ReportListProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;
    _bookSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadNotes();
    });

    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadNotes();
    });

    _noteChangedSubscription = EventBus.instance.on<NoteChangedEvent>((event) {
      // 仅报表变化时刷新本列表，普通记事变化由 NoteListProvider 处理
      if (event.note.noteType != _noteType) return;
      loadNotes(true);
    });
  }

  @override
  void dispose() {
    _bookSubscription.cancel();
    _syncSubscription.cancel();
    _noteChangedSubscription.cancel();
    super.dispose();
  }

  Future<void> setKeyword(String keyword) async {
    _keyword = keyword;
    loadNotes(true);
  }

  /// 加载报表列表
  /// [refresh] 是否刷新列表，如果为 true 则清空现有数据并重置页码
  Future<void> loadNotes([bool refresh = true]) async {
    if (_loading || _currentBookId == null) return;
    if (!refresh && !_hasMore) return;

    _loading = true;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    try {
      final filter = NoteFilterDTO(
        keyword: _keyword,
        noteType: _noteType,
      );

      // 并行查询：账本报表 + 全局报表
      final results = await Future.wait([
        DriverFactory.driver.listNotesByBook(
          AppConfigManager.instance.userId,
          _currentBookId!,
          offset: (_page - 1) * _pageSize,
          limit: _pageSize,
          filter: filter,
        ),
        DaoManager.noteDao.listGlobalNotes(
          limit: _pageSize,
          filter: NoteFilterDTO(keyword: _keyword, noteType: _noteType),
        ),
      ]);

      final bookResult = results[0] as OperateResult<List<UserNoteVO>>;
      final globalNotes = results[1] as List<AccountNote>;

      if (refresh) {
        _reports.clear();
      }

      if (bookResult.ok) {
        _reports.addAll(bookResult.data ?? []);
        _hasMore = (bookResult.data?.length ?? 0) >= _pageSize;
      }

      // 合并全局报表，按更新时间排序
      for (final gn in globalNotes) {
        final vo = UserNoteVO.fromAccountNote(gn, null);
        if (!_reports.any((n) => n.id == vo.id)) {
          _reports.add(vo);
        }
      }
      _reports.sort((a, b) =>
          (b.updatedAt ?? b.createdAt ?? 0)
              .compareTo((a.updatedAt ?? a.createdAt ?? 0)));

      _computeMissingMonths();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载更多报表
  Future<void> loadMore() async {
    _page++;
    await loadNotes(false);
  }

  /// 删除报表
  Future<bool> deleteReport(UserNoteVO note) async {
    final result = await DriverFactory.driver
        .deleteNote(AppConfigManager.instance.userId, _currentBookId!, note.id);
    if (result.ok) {
      _reports.remove(note);
      notifyListeners();
    }
    return result.ok;
  }

  /// 计算今年已过去月份中未生成报表的月份
  void _computeMissingMonths() {
    _missingMonths.clear();
    final now = DateTime.now();
    // 已生成的月份标题
    final generatedTitles = _reports
        .where((n) => n.noteType == NoteType.report.code)
        .map((n) => n.title ?? '')
        .toSet();
    // 今年1月至上月
    for (int m = 1; m < now.month; m++) {
      final title = '月度收支报告 —— ${now.year}年$m月';
      if (!generatedTitles.contains(title)) {
        _missingMonths.add(MissingMonthItem(year: now.year, month: m));
      }
    }
    // 倒序
    _missingMonths.sort((a, b) => b.month.compareTo(a.month));
  }
}
