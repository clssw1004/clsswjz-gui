import 'package:flutter/material.dart';

import '../models/vo/user_note_vo.dart';
import 'book/note_tile.dart';
import 'report/report_tile.dart';
import '../pages/report/report_detail_page.dart';

/// 笔记渲染器接口
/// 每种 noteType + template 组合注册一个渲染器
abstract class NoteRenderer {
  /// 在列表中渲染预览卡片
  Widget buildTile(UserNoteVO note, VoidCallback? onTap);

  /// 构建详情页
  Widget buildPage(UserNoteVO note);

  /// 是否可编辑
  bool get isEditable => false;
}

/// 笔记渲染器注册中心（适配器模式）
class NoteRendererRegistry {
  NoteRendererRegistry._();

  static final Map<String, NoteRenderer> _registry = {};

  /// 注册渲染器
  /// [key] 格式为 "noteType:template"，如 "NOTE:"、"REPORT:report_v1"
  static void register(String noteType, String? template, NoteRenderer renderer) {
    _registry['$noteType:${template ?? ''}'] = renderer;
  }

  /// 获取渲染器，按 noteType+template 精确匹配，再按 noteType 模糊匹配
  static NoteRenderer? resolve(String? noteType, String? template) {
    // 精确匹配
    final exact = _registry['$noteType:${template ?? ''}'];
    if (exact != null) return exact;
    // 按 noteType 匹配（任意 template）
    final typeMatch = _registry['$noteType:'];
    if (typeMatch != null) return typeMatch;
    return null;
  }
}

/// 默认 Quill 笔记渲染器
class DefaultNoteRenderer extends NoteRenderer {
  @override
  bool get isEditable => true;

  @override
  Widget buildTile(UserNoteVO note, VoidCallback? onTap) {
    return NoteTile(
      note: note,
      index: 0,
      onTap: onTap,
    );
  }

  @override
  Widget buildPage(UserNoteVO note) {
    // 默认走编辑页（只读查看通过 NoteFormPage 实现）
    // 实际路由到编辑页时由调用方处理
    return const SizedBox();
  }
}

/// 月度报告渲染器
class ReportNoteRenderer extends NoteRenderer {
  @override
  bool get isEditable => false;

  @override
  Widget buildTile(UserNoteVO note, VoidCallback? onTap) {
    return ReportTile(note: note, onTap: onTap);
  }

  @override
  Widget buildPage(UserNoteVO note) {
    return ReportDetailPage(note: note);
  }
}

/// 初始化默认渲染器
void initNoteRenderers() {
  NoteRendererRegistry.register('NOTE', null, DefaultNoteRenderer());
  NoteRendererRegistry.register('NOTE', '', DefaultNoteRenderer());
  NoteRendererRegistry.register('REPORT', '', ReportNoteRenderer());
  NoteRendererRegistry.register('REPORT', 'report_v1', ReportNoteRenderer());
}
