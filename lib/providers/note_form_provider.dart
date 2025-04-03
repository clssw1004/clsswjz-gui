import 'package:flutter/material.dart';
import '../enums/business_type.dart';
import '../enums/note_type.dart';
import '../enums/operate_type.dart';
import '../enums/account_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../manager/dao_manager.dart';
import '../manager/service_manager.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_note_vo.dart';
import '../models/vo/attachment_vo.dart';
import '../utils/date_util.dart';
import '../manager/app_config_manager.dart';
import '../drivers/driver_factory.dart';

/// 笔记表单状态管理
class NoteFormProvider extends ChangeNotifier {
  /// 账本数据
  final BookMetaVO _bookMeta;
  BookMetaVO get bookMeta => _bookMeta;

  /// 笔记数据
  UserNoteVO _note;
  UserNoteVO get note => _note;

  /// 是否为新增
  bool get isNew => _note.id.isEmpty;

  /// 是否正在保存
  bool _saving = false;
  bool get saving => _saving;

  /// 错误信息
  String? _error;
  String? get error => _error;

  /// 附件列表
  List<AttachmentVO> _attachments = [];
  List<AttachmentVO> get attachments => _attachments;

  /// 是否正在加载数据
  bool _loading = false;
  bool get loading => _loading;

  /// 笔记内容
  String _content = '';
  String get content => _content;

  /// 笔记标题
  String _title = '';
  String get title => _title;

  NoteFormProvider(BookMetaVO bookMeta, UserNoteVO? note)
      : _bookMeta = bookMeta,
        _note = note ??
            UserNoteVO(
              id: '',
              accountBookId: bookMeta.id,
              title: '',
              content: '',
              plainContent: '',
              createdBy: AppConfigManager.instance.userId,
              updatedBy: AppConfigManager.instance.userId,
              createdAt: DateUtil.now(),
              updatedAt: DateUtil.now(),
            ) {
    _init();
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();

    if (!isNew) {
      _title = _note.title ?? '';
      _content = _note.content;
      await loadAttachments();
    }

    _loading = false;
    notifyListeners();
  }

  /// 加载附件列表
  Future<void> loadAttachments() async {
    if (note.id.isEmpty) return;

    _attachments =
        await ServiceManager.attachmentService.getAttachmentsByBusiness(
      BusinessType.note,
      note.id,
    );
    notifyListeners();
  }

  /// 更新标题
  void updateTitle(String title) {
    _title = title;
    notifyListeners();
  }

  /// 更新内容
  void updateContent(String content, String plainContent) {
    _content = content;
    _note = _note.copyWith(
      content: content,
      plainContent: plainContent,
    );
    notifyListeners();
  }

  /// 更新附件列表
  void updateAttachments(List<AttachmentVO> attachments) {
    _attachments = attachments;
    notifyListeners();
  }

  /// 创建笔记
  Future<bool> create() async {
    if (_saving) return false;

    _saving = true;
    notifyListeners();

    try {
      final userId = AppConfigManager.instance.userId;

      // 创建笔记
      final result = await DriverFactory.driver.createNote(
        userId,
        _bookMeta.id,
        title: _title,
        noteType: NoteType.note,
        content: _content,
        plainContent: _note.plainContent,
        files: _attachments
            .where((attachment) => attachment.file != null)
            .map((attachment) => attachment.file!)
            .toList(),
      );

      if (result.ok) {
        final noteId = result.data!;
        final note = await DaoManager.noteDao.findById(noteId);
        EventBus.instance.emit(NoteChangedEvent(OperateType.create, note!));
        return true;
      } else {
        _error = result.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  /// 更新笔记
  Future<bool> update() async {
    if (_saving) return false;

    _saving = true;
    notifyListeners();

    try {
      final userId = AppConfigManager.instance.userId;

      // 更新笔记
      final result = await DriverFactory.driver.updateNote(
        userId,
        _bookMeta.id,
        _note.id,
        title: _title,
        content: _content,
        plainContent: _note.plainContent,
        attachments: _attachments,
      );

      if (result.ok) {
        final note = await DaoManager.noteDao.findById(_note.id);
        EventBus.instance.emit(NoteChangedEvent(OperateType.update, note!));
        return true;
      } else {
        _error = result.message;
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}
