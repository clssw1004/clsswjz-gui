import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_note_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../manager/app_config_manager.dart';
import '../../utils/toast_util.dart';
import '../../drivers/driver_factory.dart';

class NoteFormPage extends StatefulWidget {
  final UserNoteVO? note;

  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _quillController = QuillController.basic();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
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
    _titleController.dispose();
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
        title: _titleController.text,
        content: jsonEncode(_quillController.document.toDelta().toJson()),
        noteDate: noteDate,
        accountBookId: widget.note?.accountBookId ?? '',
      );

      final result = widget.note == null
          ? await DriverFactory.driver.createNote(userId, note: note)
          : await DriverFactory.driver.updateNote(userId, note: note);

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
                    QuillSimpleToolbar(
                      controller: _quillController,
                      configurations: const QuillSimpleToolbarConfigurations(
                        showListCheck: true,
                        showListBullets: true,
                        showListNumbers: true,
                        showHeaderStyle: true,
                        showSearchButton: false,
                        showAlignmentButtons: false,
                        showCodeBlock: false,
                        showQuote: false,
                        showIndent: false,
                        showLink: false,
                        showUndo: false,
                        showRedo: false,
                        showClearFormat: false,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        showSmallButton: false,
                        showLineHeightButton: false,
                        showStrikeThrough: false,
                        showInlineCode: false,
                        showJustifyAlignment: false,
                        showFontFamily: false,
                        showFontSize: true,
                        showBoldButton: false,
                        showItalicButton: false,
                        showUnderLineButton: false,
                        showClipboardPaste: false,
                        showClipboardCopy: false,
                        showClipboardCut: false,
                        showSubscript: false,
                        showSuperscript: false,
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
