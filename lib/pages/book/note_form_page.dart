import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import '../../database/database.dart';
import '../../enums/business_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/item_relation_panel.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../utils/attachment.util.dart';
import '../../utils/file_util.dart';
import '../../providers/note_form_provider.dart';
import '../../models/vo/book_meta.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/symbol_type.dart';

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
  final _editorFocusNode = FocusNode();
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editorFocusNode.unfocus();
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
    });
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
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

  Future<void> _handleAddAttachment(NoteFormProvider provider) async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return;

    final files = result.files
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList();
    if (files.isEmpty) return;

    final userId = provider.note.updatedBy ?? provider.note.createdBy ?? '';
    final attachments = files
        .map((file) => AttachmentUtil.generateVoFromFile(
              BusinessType.note,
              provider.note.id,
              file,
              userId,
            ))
        .toList();

    provider.updateAttachments([...provider.attachments, ...attachments]);

    for (final attachment in attachments) {
      final fileName = attachment.originName.toLowerCase();
      if (FileUtil.isImage(fileName)) {
        final delta = _quillController.document.toDelta();
        if (delta.isNotEmpty && !delta.last.data.toString().endsWith('\n')) {
          _quillController.document.insert(delta.length, '\n');
        }
        final imageDelta = Delta()
          ..insert('\n')
          ..insert({'image': attachment.id}, {'align': 'left'})
          ..insert('\n');
        _quillController.document.compose(imageDelta, ChangeSource.local);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final provider = context.watch<NoteFormProvider>();

    if (!provider.loading &&
        _titleController.text.isEmpty &&
        provider.title.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _editorFocusNode.unfocus();
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
      });
    }

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
                  // 标题
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.contentPadding.left,
                      spacing.contentPadding.top,
                      spacing.contentPadding.right,
                      0,
                    ),
                    child: TextField(
                      controller: _titleController,
                      decoration: null,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: provider.updateTitle,
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: colorScheme.outline.withAlpha(25),
                    indent: spacing.contentPadding.left,
                    endIndent: spacing.contentPadding.right,
                  ),
                  // 编辑器 + 工具栏
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: QuillEditor.basic(
                            controller: _quillController,
                            focusNode: _editorFocusNode,
                            config: QuillEditorConfig(
                              padding: EdgeInsets.only(
                                left: spacing.contentPadding.left,
                                right: spacing.contentPadding.right,
                                top: spacing.formItemSpacing,
                                bottom: 0,
                              ),
                              placeholder: '开始写...',
                              autoFocus: false,
                              embedBuilders: kIsWeb
                                  ? FlutterQuillEmbeds.editorWebBuilders()
                                  : FlutterQuillEmbeds.editorBuilders(
                                      imageEmbedConfig:
                                          QuillEditorImageEmbedConfig(
                                        imageProviderBuilder:
                                            (context, imageUrl) {
                                          final attachment = provider.attachments
                                              .where((e) => e.id == imageUrl)
                                              .first;
                                          return attachment.file != null
                                              ? FileImage(
                                                  File(attachment.file?.path ?? ''))
                                              : null;
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        // 极简工具栏
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: colorScheme.outline.withAlpha(20),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: spacing.contentPadding.left),
                                child: GestureDetector(
                                  onTap: () => setState(() => _showDetails = !_showDetails),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: _showDetails
                                          ? colorScheme.primaryContainer
                                          : colorScheme.surfaceContainerHighest.withAlpha(150),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _showDetails
                                            ? colorScheme.primary.withAlpha(30)
                                            : colorScheme.outline.withAlpha(20),
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Icon(
                                      _showDetails ? Icons.close : Icons.grid_view_rounded,
                                      size: 15,
                                      color: _showDetails
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: QuillSimpleToolbar(
                                  controller: _quillController,
                                  config: const QuillSimpleToolbarConfig(
                              multiRowsDisplay: false,
                              showBoldButton: true,
                              showItalicButton: true,
                              showUnderLineButton: true,
                              showListCheck: true,
                              showListBullets: true,
                              showHeaderStyle: false,
                              showListNumbers: false,
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
                              showFontSize: false,
                              showSearchButton: false,
                              showSubscript: false,
                              showSuperscript: false,
                              showClipboardCut: false,
                              showClipboardCopy: false,
                              showClipboardPaste: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                  // 底部可折叠区域（分组、附件、关联账目）
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: _showDetails
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Divider(
                                height: 1,
                                thickness: 0.5,
                                color: colorScheme.outline.withAlpha(25),
                                indent: spacing.contentPadding.left,
                                endIndent: spacing.contentPadding.right,
                              ),
                              _buildBottomSections(provider, colorScheme, spacing),
                              if (!provider.isNew && provider.note.id.isNotEmpty)
                                ItemRelationPanel(
                                  relationCode: 'note',
                                  relationId: provider.note.id,
                                  accountBookId: provider.bookMeta.id,
                                  displayMode: RelationDisplayMode.compact,
                                  target: RelationTargetConfig(
                                    code: 'item',
                                    label: '账目',
                                    multiSelect: true,
                                    searchBuilder: (context, query, bookId) async {
                                      final userId = AppConfigManager.instance.userId;
                                      final bid = bookId ?? provider.bookMeta.id;
                                      final filter = query.isNotEmpty ? ItemFilterDTO(keyword: query) : null;
                                      final result = await DriverFactory.driver.listItemsByBook(
                                        userId,
                                        bid,
                                        filter: filter,
                                        limit: 50,
                                      );
                                      if (!result.ok || result.data == null) {
                                        return <SearchResult>[];
                                      }
                                      return result.data!.map((item) {
                                        final isIncome = item.type == 'INCOME';
                                        final sign = isIncome ? '+' : '-';
                                        final icon = isIncome
                                            ? Icons.account_balance_outlined
                                            : Icons.shopping_cart_outlined;
                                        final subtitle = [
                                          if (item.categoryName != null) item.categoryName,
                                          if (item.fundName != null) item.fundName,
                                          item.accountDateOnly,
                                        ].join('  ');
                                        return SearchResult(
                                          id: item.id,
                                          display: '$sign${item.amount.abs().toStringAsFixed(2)}  ${item.description ?? ''}',
                                          subtitle: subtitle,
                                          leading: Icon(icon, size: 20),
                                        );
                                      }).toList();
                                    },
                                    bookListBuilder: () async {
                                      final userId = AppConfigManager.instance.userId;
                                      final result = await DriverFactory.driver.listBooksByUser(userId);
                                      if (result.ok && result.data != null) {
                                        return result.data!.map((b) => BookSwitcherItem(id: b.id, name: b.name)).toList();
                                      }
                                      return [];
                                    },
                                    initialBookId: provider.bookMeta.id,
                                    displayBuilder: (context, relation, onTap) {
                                      return FutureBuilder<AccountItem?>(
                                        future: DaoManager.itemDao.findById(relation.itemId),
                                        builder: (context, snapshot) {
                                          final item = snapshot.data;
                                          final isIncome = item?.type == 'INCOME';
                                          final sign = isIncome ? '+' : '-';
                                          final amount = item?.amount ?? 0;
                                          final amountColor =
                                              isIncome ? Colors.green : Colors.redAccent;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surfaceContainerHighest
                                                  .withAlpha(80),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isIncome
                                                      ? Icons.arrow_upward
                                                      : Icons.arrow_downward,
                                                  size: 14,
                                                  color: amountColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$sign${amount.abs().toStringAsFixed(0)}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: amountColor,
                                                  ),
                                                ),
                                                if (item?.description != null &&
                                                    item!.description!.isNotEmpty) ...[
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '·',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    item.description!,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    onTap: (context, relation) {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.itemsList,
                                        arguments: provider.bookMeta,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: bottomPadding + 16),
                ],
              ),
            ),
    );
  }

  Widget _buildBottomSections(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.contentPadding.left,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: spacing.formItemSpacing),
          // 分组标签
          _buildGroupSection(provider, colorScheme, spacing),
          SizedBox(height: spacing.formItemSpacing),
          // 附件
          _buildAttachmentSection(provider, colorScheme, spacing),
          SizedBox(height: spacing.formItemSpacing),
        ],
      ),
    );
  }

  Widget _buildGroupSection(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_outlined, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '分组',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        SizedBox(height: spacing.formItemSpacing / 2),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ...provider.groups.map((group) {
              final selected = provider.groupCode == group.code;
              return FilterChip(
                label: Text(group.name),
                selected: selected,
                onSelected: (_) => provider.updateGroup(group),
                visualDensity: VisualDensity.compact,
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide.none,
              );
            }),
            ActionChip(
              label: const Icon(Icons.add, size: 16),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(
                color: colorScheme.outline.withAlpha(50),
              ),
              onPressed: () => _handleCreateGroup(provider),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttachmentSection(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '附件',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        SizedBox(height: spacing.formItemSpacing / 2),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...provider.attachments.map((attachment) {
                final isImage = FileUtil.isImage(attachment.originName);
                return GestureDetector(
                  onLongPress: () => _handleDeleteAttachment(provider, attachment.id),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surfaceContainerHighest,
                      image: isImage && attachment.file != null
                          ? DecorationImage(
                              image: FileImage(attachment.file!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: !isImage
                        ? Icon(Icons.attach_file,
                            size: 20, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                );
              }),
              GestureDetector(
                onTap: () => _handleAddAttachment(provider),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(30),
                    ),
                  ),
                  child: Icon(Icons.add, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _handleCreateGroup(NoteFormProvider provider) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建分组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入分组名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final result = await DriverFactory.driver.createSymbol(
        AppConfigManager.instance.userId,
        provider.bookMeta.id,
        name: name,
        symbolType: SymbolType.noteGroup,
      );
      if (result.data != null) {
        await provider.loadGroups();
        final newGroup = provider.groups.firstWhere((g) => g.name == name);
        provider.updateGroup(newGroup);
      }
    }
  }

  void _handleDeleteAttachment(NoteFormProvider provider, String attachmentId) {
    provider.updateAttachments(
      provider.attachments.where((a) => a.id != attachmentId).toList(),
    );
  }
}
