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

/// 账目关联展示数据
class _ItemDisplayData {
  final AccountItem item;
  final String? categoryName;
  final String? fundName;

  _ItemDisplayData({
    required this.item,
    this.categoryName,
    this.fundName,
  });
}

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

  bool _showGroup = false;
  bool _showAttachment = false;
  bool _showRelation = false;

  @override
  void initState() {
    super.initState();
    _editorFocusNode.addListener(_collapseAllPanels);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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

  void _collapseAllPanels() {
    if (_editorFocusNode.hasFocus) {
      setState(() {
        _showGroup = false;
        _showAttachment = false;
        _showRelation = false;
      });
    }
  }

  @override
  void dispose() {
    _editorFocusNode.removeListener(_collapseAllPanels);
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
                  // 捕获 Navigator 首帧自动聚焦，防止键盘弹出
                  Focus(autofocus: true, child: const SizedBox.shrink()),
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
                                          final attachment = provider
                                              .attachments
                                              .where((e) => e.id == imageUrl)
                                              .first;
                                          return attachment.file != null
                                              ? FileImage(
                                                  File(
                                                      attachment.file?.path ??
                                                          ''))
                                              : null;
                                        },
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        // 工具栏：三段切换 + 格式按钮
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
                                padding: EdgeInsets.only(
                                    left: spacing.contentPadding.left),
                                child: _buildTogglePill(colorScheme),
                              ),
                              const SizedBox(width: 4),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: colorScheme.outline.withAlpha(20),
                              ),
                              const SizedBox(width: 4),
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
                  // 分组面板
                  if (provider.groups.isNotEmpty)
                    _buildSectionAnimated(
                      show: _showGroup,
                      child: _buildGroupSection(provider, colorScheme, spacing),
                    ),
                  // 附件面板
                  if (provider.attachments.isNotEmpty || provider.isNew)
                    _buildSectionAnimated(
                      show: _showAttachment,
                      child: _buildAttachmentSection(
                          provider, colorScheme, spacing),
                    ),
                  // 关联账目面板
                  if (!provider.isNew && provider.note.id.isNotEmpty)
                    _buildRelationPanel(provider, colorScheme, spacing),
                  SizedBox(height: bottomPadding + 16),
                ],
              ),
            ),
    );
  }

  /// 三段切换药丸（互斥，每次只展示一个面板）
  Widget _buildTogglePill(ColorScheme colorScheme) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleIcon(
            icon: Icons.folder_outlined,
            activeIcon: Icons.folder,
            active: _showGroup,
            onTap: () => _toggleSection('group'),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 1),
          _toggleIcon(
            icon: Icons.attach_file_outlined,
            activeIcon: Icons.attach_file,
            active: _showAttachment,
            onTap: () => _toggleSection('attachment'),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 1),
          _toggleIcon(
            icon: Icons.account_balance_outlined,
            activeIcon: Icons.account_balance,
            active: _showRelation,
            onTap: () => _toggleSection('relation'),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  void _toggleSection(String section) {
    setState(() {
      final wasActive = switch (section) {
        'group' => _showGroup,
        'attachment' => _showAttachment,
        'relation' => _showRelation,
        _ => false,
      };
      _showGroup = section == 'group' && !wasActive;
      _showAttachment = section == 'attachment' && !wasActive;
      _showRelation = section == 'relation' && !wasActive;
    });
  }

  Widget _toggleIcon({
    required IconData icon,
    required IconData activeIcon,
    required bool active,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 28,
        decoration: BoxDecoration(
          color: active ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          active ? activeIcon : icon,
          size: 17,
          color: active
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 独立动画面板包装
  Widget _buildSectionAnimated({
    required bool show,
    required Widget child,
  }) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: show
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Theme.of(context).colorScheme.outline.withAlpha(25),
                ),
                child,
              ],
            )
          : const SizedBox(width: double.infinity),
    );
  }

  /// 关联账目面板（含内置分隔线）
  Widget _buildRelationPanel(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
  ) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: _showRelation
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: colorScheme.outline.withAlpha(25),
                ),
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
                      final filter = query.isNotEmpty
                          ? ItemFilterDTO(keyword: query)
                          : null;
                      final result = await DriverFactory.driver
                          .listItemsByBook(
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
                          display:
                              '$sign${item.amount.abs().toStringAsFixed(2)}  ${item.description ?? ''}',
                          subtitle: subtitle,
                          leading: Icon(icon, size: 20),
                        );
                      }).toList();
                    },
                    bookListBuilder: () async {
                      final userId = AppConfigManager.instance.userId;
                      final result =
                          await DriverFactory.driver.listBooksByUser(userId);
                      if (result.ok && result.data != null) {
                        return result.data!
                            .map((b) =>
                                BookSwitcherItem(id: b.id, name: b.name))
                            .toList();
                      }
                      return [];
                    },
                    initialBookId: provider.bookMeta.id,
                    displayBuilder: (context, relation, onTap) {
                      return FutureBuilder<_ItemDisplayData>(
                        future:
                            _loadItemDisplayData(relation.itemId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return _buildCardPlaceholder(colorScheme);
                          }
                          return _buildAccountCard(
                              snapshot.data!, colorScheme);
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
          : const SizedBox(width: double.infinity),
    );
  }

  Future<_ItemDisplayData> _loadItemDisplayData(String itemId) async {
    final item = await DaoManager.itemDao.findById(itemId);
    if (item == null) throw Exception('Item not found: $itemId');

    String? categoryName;
    if (item.categoryCode != null) {
      final symbol =
          await DaoManager.symbolDao.findByCode(item.categoryCode!);
      categoryName = symbol?.name;
    }

    String? fundName;
    if (item.fundId != null) {
      final fund = await DaoManager.fundDao.findById(item.fundId!);
      fundName = fund?.name;
    }

    return _ItemDisplayData(
      item: item,
      categoryName: categoryName,
      fundName: fundName,
    );
  }

  Widget _buildCardPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 210,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainerHighest.withAlpha(40),
      ),
    );
  }

  /// 账目关联卡片（展示完整账目信息）
  Widget _buildAccountCard(_ItemDisplayData data, ColorScheme colorScheme) {
    final item = data.item;
    final isIncome = item.type == 'INCOME';
    final sign = isIncome ? '+' : '-';
    final amountColor = isIncome ? Colors.green : Colors.redAccent;

    final lines = <String>[
      if (data.categoryName != null) data.categoryName!,
      if (data.fundName != null) data.fundName!,
      item.accountDate,
    ];

    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withAlpha(15),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 左翼颜色条
            Container(width: 3.5, color: amountColor.withAlpha(180)),
            const SizedBox(width: 10),
            // 内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：金额 + 分类
                    Row(
                      children: [
                        Text(
                          '$sign${item.amount.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                            height: 1.2,
                          ),
                        ),
                        const Spacer(),
                        if (data.categoryName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: isIncome
                                  ? Colors.green.withAlpha(20)
                                  : Colors.redAccent.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              data.categoryName!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: amountColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 第二行：资金账户 + 日期
                    Text(
                      lines.join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // 第三行：描述
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant.withAlpha(160),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSection(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.contentPadding.left,
        spacing.formItemSpacing,
        spacing.contentPadding.right,
        spacing.formItemSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '分组',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: spacing.formItemSpacing / 1.5),
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
                  selectedColor: colorScheme.primaryContainer.withAlpha(120),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: selected
                      ? BorderSide(
                          color: colorScheme.primary.withAlpha(30), width: 0.5)
                      : BorderSide.none,
                  showCheckmark: false,
                );
              }),
              ActionChip(
                label: const Icon(Icons.add, size: 15),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: colorScheme.outline.withAlpha(40),
                  width: 0.5,
                ),
                onPressed: () => _handleCreateGroup(provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.contentPadding.left,
        spacing.formItemSpacing,
        spacing.contentPadding.right,
        spacing.formItemSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '附件',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: spacing.formItemSpacing / 1.5),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...provider.attachments.map((attachment) {
                final isImage = FileUtil.isImage(attachment.originName);
                return GestureDetector(
                  onLongPress: () =>
                      _handleDeleteAttachment(provider, attachment.id),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: colorScheme.surfaceContainerHighest,
                      image: isImage && attachment.file != null
                          ? DecorationImage(
                              image: FileImage(attachment.file!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: !isImage
                        ? Icon(Icons.insert_drive_file_outlined,
                            size: 20, color: colorScheme.onSurfaceVariant)
                        : null,
                  ),
                );
              }),
              GestureDetector(
                onTap: () => _handleAddAttachment(provider),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(30),
                      width: 0.5,
                    ),
                  ),
                  child:
                      Icon(Icons.add, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
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
