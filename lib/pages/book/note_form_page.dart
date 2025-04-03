import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';
import '../../enums/business_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_attachment_field.dart';
import '../../utils/toast_util.dart';
import '../../utils/attachment.util.dart';
import '../../utils/file_util.dart';
import '../../theme/theme_spacing.dart';
import '../../providers/note_form_provider.dart';
import '../../models/vo/book_meta.dart';

class NoteFormPage extends StatelessWidget {
  final UserNoteVO? note;
  final UserBookVO book;

  const NoteFormPage({
    super.key,
    this.note,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteFormProvider(
        BookMetaVO(bookInfo: book),
        note,
      ),
      child: const _NoteFormPage(),
    );
  }
}

class _NoteFormPage extends StatefulWidget {
  const _NoteFormPage();

  @override
  State<_NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<_NoteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _quillController = QuillController.basic();
  final _titleController = TextEditingController();
  bool _showFullToolbar = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<NoteFormProvider>();
    _titleController.text = provider.title;
    if (provider.content.isNotEmpty) {
      try {
        _quillController.document = Document.fromJson(
          jsonDecode(provider.content),
        );
      } catch (e) {
        _quillController.document = Document.fromDelta(
          Delta.fromJson([
            {"insert": provider.content},
          ]),
        );
      }
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final spacing = theme.extension<ThemeSpacing>() ?? const ThemeSpacing();

    return Consumer<NoteFormProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: CommonAppBar(
            title: Text(provider.isNew
                ? L10nManager.l10n.addNew(L10nManager.l10n.tabNotes)
                : L10nManager.l10n.editTo(L10nManager.l10n.tabNotes)),
            actions: [
              IconButton(
                onPressed: provider.saving
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          provider.updateTitle(_titleController.text.trim());
                          provider.updateContent(
                            jsonEncode(_quillController.document.toDelta().toJson()),
                            _quillController.document.toPlainText(),
                          );

                          final success = provider.isNew
                              ? await provider.create()
                              : await provider.update();

                          if (success) {
                            if (mounted) {
                              Navigator.of(context).pop(true);
                            }
                          } else if (mounted && provider.error != null) {
                            ToastUtil.showError(provider.error!);
                          }
                        }
                      },
                icon: provider.saving
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
          body: provider.loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                  color: colorScheme.outline.withAlpha(100)),
                            ),
                          ),
                          child: Column(
                            children: [
                              // 标题输入框
                              CommonTextFormField(
                                controller: _titleController,
                                hintText: L10nManager.l10n.title,
                                maxLines: 1,
                                required: false,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.15,
                                ),
                                onEditingComplete: () {},
                              ),
                              // 内容编辑器
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
                              // 附件上传
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: CommonAttachmentField(
                                  attachments: provider.attachments,
                                  label: L10nManager.l10n.attachments,
                                  onUpload: (files) async {
                                    final userId = provider.note.updatedBy ?? '';
                                    final attachments = files
                                        .map((file) => AttachmentUtil.generateVoFromFile(
                                              BusinessType.note,
                                              provider.note.id,
                                              file,
                                              userId,
                                            ))
                                        .toList();

                                    provider.updateAttachments([
                                      ...provider.attachments,
                                      ...attachments
                                    ]);
                                  },
                                  onDelete: (attachment) async {
                                    provider.updateAttachments(
                                      provider.attachments
                                          .where((a) => a.id != attachment.id)
                                          .toList(),
                                    );
                                  },
                                  onTap: (attachment) async {
                                    final result = await FileUtil.openFile(attachment);
                                    if (!result.ok && mounted) {
                                      ToastUtil.showError(result.message ?? '打开文件失败');
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: spacing.formItemSpacing),
                              Container(
                                padding: EdgeInsets.only(bottom: bottomPadding),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  border: Border(
                                    top: BorderSide(
                                        color: colorScheme.outline.withAlpha(100)),
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
                                          padding:
                                              const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _showFullToolbar
                                                    ? Icons.expand_more
                                                    : Icons.expand_less,
                                                size: 20,
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _showFullToolbar ? '收起' : '展开',
                                                style:
                                                    theme.textTheme.bodySmall?.copyWith(
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
                                        showUnderLineButton: _showFullToolbar,
                                        showClipboardPaste: _showFullToolbar,
                                        showClipboardCopy: _showFullToolbar,
                                        showClipboardCut: _showFullToolbar,
                                        showSubscript: _showFullToolbar,
                                        showSuperscript: _showFullToolbar,
                                        multiRowsDisplay: false,
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
      },
    );
  }
}
