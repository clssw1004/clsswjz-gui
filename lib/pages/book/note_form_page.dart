import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
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
      child: const _NoteFormContent(),
    );
  }
}

class _NoteFormContent extends StatefulWidget {
  const _NoteFormContent();

  @override
  State<_NoteFormContent> createState() => _NoteFormContentState();
}

class _NoteFormContentState extends State<_NoteFormContent> {
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

  Future<void> _saveNote(NoteFormProvider provider) async {
    if (_formKey.currentState?.validate() ?? false) {
      provider.updateTitle(_titleController.text.trim());
      provider.updateContent(
        jsonEncode(_quillController.document.toDelta().toJson()),
        _quillController.document.toPlainText(),
      );

      final success =
          provider.isNew ? await provider.create() : await provider.update();

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else if (mounted && provider.error != null) {
        ToastUtil.showError(provider.error!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final provider = context.watch<NoteFormProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(provider.isNew
            ? L10nManager.l10n.addNew(L10nManager.l10n.note)
            : L10nManager.l10n.editTo(L10nManager.l10n.note)),
        actions: [
          IconButton(
            onPressed: provider.saving ? null : () => _saveNote(provider),
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
                            onChanged: provider.updateTitle,
                          ),
                          // 内容编辑器
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: QuillEditor.basic(
                                    controller: _quillController,
                                    config: QuillEditorConfig(
                                      padding: const EdgeInsets.all(16),
                                      autoFocus: false,
                                      embedBuilders: kIsWeb
                                          ? FlutterQuillEmbeds
                                              .editorWebBuilders()
                                          : FlutterQuillEmbeds.editorBuilders(
                                              imageEmbedConfig:
                                                  QuillEditorImageEmbedConfig(
                                                imageProviderBuilder:
                                                    (context, imageUrl) {
                                                  final attachment = provider
                                                      .attachments
                                                      .where((e) =>
                                                          e.id == imageUrl)
                                                      .first;
                                                  return attachment.file != null
                                                      ? FileImage(File(
                                                          attachment
                                                                  .file?.path ??
                                                              ''))
                                                      : null;
                                                },
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                // 附件上传
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: CommonAttachmentField(
                                    attachments: provider.attachments,
                                    label: L10nManager.l10n.attachments,
                                    onUpload: (files) async {
                                      final userId =
                                          provider.note.updatedBy ?? '';
                                      final attachments = files
                                          .map((file) =>
                                              AttachmentUtil.generateVoFromFile(
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

                                      // 处理图片类型的附件
                                      for (final attachment in attachments) {
                                        final fileName =
                                            attachment.originName.toLowerCase();
                                        if (FileUtil.isImage(fileName)) {
                                          try {
                                            // 确保文档以换行符结束
                                            final delta = _quillController
                                                .document
                                                .toDelta();
                                            if (delta.isNotEmpty &&
                                                !delta.last.data
                                                    .toString()
                                                    .endsWith('\n')) {
                                              _quillController.document
                                                  .insert(delta.length, '\n');
                                            }

                                            // 构建图片Delta
                                            final imageDelta = Delta()
                                              ..insert('\n')
                                              ..insert(
                                                {'image': attachment.id},
                                                {'align': 'left'},
                                              )
                                              ..insert('\n');

                                            // 将Delta合并到文档中
                                            _quillController.document.compose(
                                              imageDelta,
                                              ChangeSource.local,
                                            );
                                          } catch (e) {
                                            print('插入图片时出错: $e');
                                          }
                                        }
                                      }
                                    },
                                    onDelete: (attachment) async {
                                      provider.updateAttachments(
                                        provider.attachments
                                            .where((a) => a.id != attachment.id)
                                            .toList(),
                                      );
                                    },
                                  ),
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(bottom: bottomPadding),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    border: Border(
                                      top: BorderSide(
                                          color: colorScheme.outline
                                              .withAlpha(100)),
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
                                              _showFullToolbar =
                                                  !_showFullToolbar;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                  _showFullToolbar
                                                      ? '收起'
                                                      : '展开',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 工具栏
                                      Row(
                                        children: [
                                          Expanded(
                                            child: QuillSimpleToolbar(
                                              controller: _quillController,
                                              config: QuillSimpleToolbarConfig(
                                                showListCheck: true,
                                                showListBullets: true,
                                                showListNumbers: true,
                                                showHeaderStyle:
                                                    _showFullToolbar,
                                                showSearchButton:
                                                    _showFullToolbar,
                                                showAlignmentButtons:
                                                    _showFullToolbar,
                                                showCodeBlock: _showFullToolbar,
                                                showQuote: _showFullToolbar,
                                                showIndent: _showFullToolbar,
                                                showLink: _showFullToolbar,
                                                showUndo: true,
                                                showRedo: true,
                                                showClearFormat:
                                                    _showFullToolbar,
                                                showColorButton:
                                                    _showFullToolbar,
                                                showBackgroundColorButton:
                                                    _showFullToolbar,
                                                showSmallButton:
                                                    _showFullToolbar,
                                                showLineHeightButton:
                                                    _showFullToolbar,
                                                showStrikeThrough:
                                                    _showFullToolbar,
                                                showInlineCode:
                                                    _showFullToolbar,
                                                showJustifyAlignment:
                                                    _showFullToolbar,
                                                showFontFamily:
                                                    _showFullToolbar,
                                                showFontSize: _showFullToolbar,
                                                showBoldButton: true,
                                                showItalicButton: true,
                                                showUnderLineButton:
                                                    _showFullToolbar,
                                                showClipboardPaste:
                                                    _showFullToolbar,
                                                showClipboardCopy:
                                                    _showFullToolbar,
                                                showClipboardCut:
                                                    _showFullToolbar,
                                                showSubscript: _showFullToolbar,
                                                showSuperscript:
                                                    _showFullToolbar,
                                                multiRowsDisplay:
                                                    _showFullToolbar,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
