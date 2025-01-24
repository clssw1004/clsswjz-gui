import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../manager/app_config_manager.dart';
import '../../utils/toast_util.dart';
import '../../drivers/driver_factory.dart';

class NoteFormPage extends StatefulWidget {
  final UserNoteVO? note;
  final UserBookVO book;

  const NoteFormPage({super.key, this.note, required this.book});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quillController = QuillController.basic();
  bool _saving = false;
  bool _showFullToolbar = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      try {
        final doc = Document.fromJson(jsonDecode(widget.note!.content));
        _quillController.document = doc;
      } catch (e) {
        // 如果解析失败，将原始内容作为纯文本加载
        _quillController.document = Document.fromDelta(
          Delta.fromJson([
            {"insert": widget.note!.content},
          ]),
        );
      }
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final userId = AppConfigManager.instance.userId!;
      final now = DateTime.now();
      final noteDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      final note = UserNoteVO(
        id: widget.note?.id ?? '',
        content: jsonEncode(_quillController.document.toDelta().toJson()),
        noteDate: noteDate,
        accountBookId: widget.book.id,
      );

      final result = widget.note == null
          ? await DriverFactory.driver.createNote(userId, widget.book.id, content: note.content, noteDate: note.noteDate)
          : await DriverFactory.driver.updateNote(userId, widget.book.id, note.id, content: note.content, noteDate: note.noteDate);

      if (result.ok) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ToastUtil.showError(result.message ?? L10nManager.l10n.saveFailed(''));
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(
            widget.note == null ? L10nManager.l10n.addNew(L10nManager.l10n.tabNotes) : L10nManager.l10n.editTo(L10nManager.l10n.tabNotes)),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurface,
                    ),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: colorScheme.outline.withAlpha(100)),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: QuillEditor.basic(
                        controller: _quillController,
                        configurations: const QuillEditorConfigurations(
                          padding: EdgeInsets.all(16),
                          sharedConfigurations: QuillSharedConfigurations(
                            locale: Locale('zh', 'CN'),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border(
                          top: BorderSide(color: colorScheme.outline.withAlpha(100)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 展开按钮
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _showFullToolbar = !_showFullToolbar;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _showFullToolbar ? Icons.expand_less : Icons.expand_more,
                                      size: 20,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showFullToolbar ? '收起' : '展开',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // 工具栏
                          QuillSimpleToolbar(
                            controller: _quillController,
                            configurations: QuillSimpleToolbarConfigurations(
                              showListCheck: true,
                              showListBullets: true,
                              showListNumbers: true,
                              showHeaderStyle: _showFullToolbar,
                              showSearchButton: _showFullToolbar,
                              showAlignmentButtons: _showFullToolbar,
                              showCodeBlock: _showFullToolbar,
                              showQuote: _showFullToolbar,
                              showIndent: _showFullToolbar,
                              showLink: _showFullToolbar,
                              showUndo: true,
                              showRedo: true,
                              showClearFormat: _showFullToolbar,
                              showColorButton: _showFullToolbar,
                              showBackgroundColorButton: _showFullToolbar,
                              showSmallButton: _showFullToolbar,
                              showLineHeightButton: _showFullToolbar,
                              showStrikeThrough: _showFullToolbar,
                              showInlineCode: _showFullToolbar,
                              showJustifyAlignment: _showFullToolbar,
                              showFontFamily: _showFullToolbar,
                              showFontSize: _showFullToolbar,
                              showBoldButton: true,
                              showItalicButton: true,
                              showUnderLineButton: true,
                              showClipboardPaste: _showFullToolbar,
                              showClipboardCopy: _showFullToolbar,
                              showClipboardCut: _showFullToolbar,
                              showSubscript: _showFullToolbar,
                              showSuperscript: _showFullToolbar,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
