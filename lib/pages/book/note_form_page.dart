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
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_note_vo.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/item_relation_panel.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../utils/attachment.util.dart';
import '../../utils/color_util.dart';
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
  bool _showScope = false;

  @override
  void initState() {
    super.initState();
    _editorFocusNode.addListener(_collapseAllPanels);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
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
                                color: colorScheme.outline.withValues(alpha: 0.18),
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
                                color: colorScheme.outline.withValues(alpha: 0.18),
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
                  // 功能面板区域（与编辑器有明显边界）
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (provider.groups.isNotEmpty)
                          _buildSectionAnimated(
                            show: _showGroup,
                            child: _buildGroupSection(
                                provider, colorScheme, spacing),
                            maxHeight: mediaQuery.size.height * 0.33,
                          ),
                        _buildSectionAnimated(
                          show: _showScope,
                          child: _buildScopeSection(provider, colorScheme, spacing),
                          maxHeight: 120,
                        ),
                        if (provider.attachments.isNotEmpty || provider.isNew)
                          _buildSectionAnimated(
                            show: _showAttachment,
                            child: _buildAttachmentSection(
                                provider, colorScheme, spacing),
                            maxHeight: mediaQuery.size.height * 0.33,
                          ),
                        if (!provider.isNew && provider.note.id.isNotEmpty)
                          _buildRelationPanel(provider, colorScheme, spacing,
                              mediaQuery.size.height * 0.33),
                      ],
                    ),
                  ),
                  SizedBox(height: bottomPadding + 16),
                ],
              ),
            ),
    );
  }

  /// 三段切换药丸（互斥，每次只展示一个面板）
  Widget _buildTogglePill(ColorScheme colorScheme) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(17),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleIcon(
            icon: Icons.label_outlined,
            activeIcon: Icons.label,
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
            icon: Icons.link_outlined,
            activeIcon: Icons.link,
            active: _showRelation,
            onTap: () => _toggleSection('relation'),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 1),
          _toggleIcon(
            icon: Icons.public_outlined,
            activeIcon: Icons.public,
            active: _showScope,
            onTap: () => _toggleSection('scope'),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  void _toggleSection(String section) {
    FocusScope.of(context).unfocus();
    setState(() {
      final wasActive = switch (section) {
        'group' => _showGroup,
        'attachment' => _showAttachment,
        'relation' => _showRelation,
        'scope' => _showScope,
        _ => false,
      };
      _showGroup = section == 'group' && !wasActive;
      _showAttachment = section == 'attachment' && !wasActive;
      _showRelation = section == 'relation' && !wasActive;
      _showScope = section == 'scope' && !wasActive;
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
    double? maxHeight,
  }) {
    final content = maxHeight != null
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 0),
            child: child,
          )
        : child;
    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        heightFactor: show ? 1.0 : 0.0,
        child: content,
      ),
    );
  }

  /// 关联账目面板（含内置分隔线）
  Widget _buildRelationPanel(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
    double maxHeight,
  ) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 0),
      child: ItemRelationPanel(
        relationCode: 'note',
        relationId: provider.note.id,
        accountBookId: provider.bookMeta.id,
        displayMode: RelationDisplayMode.list,
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
              final amountColor = ColorUtil.getAmountColor(item.type);
              return SearchResult(
                id: item.id,
                display: item.categoryName ?? '未分类',
                subtitle: item.description ?? '',
                colorValue: amountColor.toARGB32(),
                trailingText:
                    '$sign${item.amount.abs().toStringAsFixed(2)}',
              );
            }).toList();
          },
          bookListBuilder: () async {
            final userId = AppConfigManager.instance.userId;
            final result = await DriverFactory.driver.listBooksByUser(userId);
            if (result.ok && result.data != null) {
              return result.data!
                  .map((b) =>
                      BookSwitcherItem(id: b.id, name: b.name))
                  .toList();
            }
            return [];
          },
          initialBookId: provider.bookMeta.id,
          onCreateItem: (context, bookId) async {
            final userId = AppConfigManager.instance.userId;
            final bookResult =
                await DriverFactory.driver.getBook(userId, bookId);
            if (!bookResult.ok || bookResult.data == null) return null;
            if (!context.mounted) return null;
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.itemAdd,
              arguments: [
                BookMetaVO(bookInfo: bookResult.data!),
              ],
            );
            if (result == true) {
              final items =
                  await DaoManager.itemDao.listByBook(bookId, limit: 1);
              return items.isNotEmpty ? items.first.id : null;
            }
            return null;
          },
          displayBuilder: (context, relation, onTap) {
            return FutureBuilder<_ItemDisplayData>(
              future: _loadItemDisplayData(relation.itemId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildCardPlaceholder(colorScheme);
                }
                return GestureDetector(
                  onTap: onTap,
                  child: _buildAccountCard(
                      snapshot.data!, colorScheme),
                );
              },
            );
          },
          onTap: (context, relation) async {
            final item = await DaoManager.itemDao
                .findById(relation.itemId);
            if (item != null && context.mounted) {
              Navigator.of(context).pushNamed(
                AppRoutes.itemEdit,
                arguments: [
                  provider.bookMeta,
                  UserItemVO.fromAccountItem(item: item),
                ],
              );
            }
          },
        ),
      ),
    );
    return ClipRect(
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        heightFactor: _showRelation ? 1.0 : 0.0,
        child: content,
      ),
    );
  }

  Future<_ItemDisplayData> _loadItemDisplayData(String itemId) async {
    final item = await DaoManager.itemDao.findById(itemId);
    if (item == null) throw Exception('Item not found: $itemId');

    String? categoryName;
    if (item.categoryCode != null) {
      final category = await DaoManager.categoryDao.findByBookAndCode(
        item.accountBookId,
        item.categoryCode!,
      );
      categoryName = category?.name;
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
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainerHighest.withAlpha(40),
      ),
    );
  }

  /// 账目关联卡片
  Widget _buildAccountCard(_ItemDisplayData data, ColorScheme colorScheme) {
    final item = data.item;
    final isIncome = item.type == 'INCOME';
    final sign = isIncome ? '+' : '-';
    final amountColor = ColorUtil.getAmountColor(item.type);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 色条
            Container(
              width: 3.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    amountColor,
                    amountColor.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 分类 + 描述
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.categoryName ?? '未分类',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                    if (item.description != null &&
                        item.description!.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        item.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 金额
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '$sign${item.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: amountColor,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeSection(
    NoteFormProvider provider,
    ColorScheme colorScheme,
    ThemeSpacing spacing,
  ) {
    final theme = Theme.of(context);
    final isGlobal = provider.scope == 'global';

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
          Row(
            children: [
              Icon(Icons.public_outlined,
                  size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                '笔记范围',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildScopeOption(
                  icon: Icons.book_outlined,
                  title: '当前账本',
                  subtitle: '仅在当前账本中可见',
                  selected: !isGlobal,
                  onTap: () => provider.updateScope('book'),
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildScopeOption(
                  icon: Icons.public,
                  title: '全局',
                  subtitle: '在所有账本中可见',
                  selected: isGlobal,
                  onTap: () => provider.updateScope('global'),
                  colorScheme: colorScheme,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScopeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.outline.withValues(alpha: 0.1),
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 24,
                color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant),
            const SizedBox(height: 6),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
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
    final groups = provider.groups;
    final selectedCode = provider.groupCode;

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
          Row(
            children: [
              Icon(Icons.folder_outlined,
                  size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                '分组',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (selectedCode != 'none')
                Text(
                  groups.where((g) => g.code == selectedCode).firstOrNull?.name ?? '',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.formItemSpacing * 0.45),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...groups.map((group) {
                  final selected = selectedCode == group.code;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildGroupChip(
                      group, selected, colorScheme, theme, provider),
                  );
                }),
                _buildAddGroupChip(colorScheme, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChip(
    AccountSymbol group,
    bool selected,
    ColorScheme colorScheme,
    ThemeData theme,
    NoteFormProvider provider,
  ) {
    return GestureDetector(
      onTap: () => provider.updateGroup(group),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? colorScheme.outline.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.08),
            width: selected ? 1.0 : 0.5,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              group.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddGroupChip(ColorScheme colorScheme, NoteFormProvider provider) {
    return GestureDetector(
      onTap: () => _showCreateGroupSheet(provider),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Icon(Icons.add_rounded,
            size: 18, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Future<void> _showCreateGroupSheet(NoteFormProvider provider) async {
    final controller = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '新建分组',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '输入分组名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                child: const Text('创建'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
    if (name != null && name.isNotEmpty && mounted) {
      final result = await DriverFactory.driver.createSymbol(
        AppConfigManager.instance.userId,
        provider.bookMeta.id,
        name: name,
        symbolType: SymbolType.noteGroup,
      );
      if (result.data != null && mounted) {
        await provider.loadGroups();
        final newGroup = provider.groups.firstWhere((g) => g.name == name);
        provider.updateGroup(newGroup);
      }
    }
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
          Row(
            children: [
              Icon(Icons.attach_file_outlined,
                  size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                '附件',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (provider.attachments.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '${provider.attachments.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: spacing.formItemSpacing * 0.45),
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
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
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
                                  size: 22, color: colorScheme.onSurfaceVariant)
                              : null,
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          width: 56,
                          child: Text(
                            attachment.originName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: () => _handleAddAttachment(provider),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20,
                          color: colorScheme.onSurfaceVariant),
                      Text(
                        '添加',
                        style: TextStyle(
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleDeleteAttachment(NoteFormProvider provider, String attachmentId) {
    provider.updateAttachments(
      provider.attachments.where((a) => a.id != attachmentId).toList(),
    );
  }
}
