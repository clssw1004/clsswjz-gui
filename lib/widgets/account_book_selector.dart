import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/vo/user_book_vo.dart';
import '../services/account_book_service.dart';
import 'common/common_dialog.dart';
import 'common/shared_badge.dart';

/// 账本选择组件
class AccountBookSelector extends StatefulWidget {
  /// 用户ID
  final String userId;

  /// 选中的账本
  final UserBookVO? selectedBook;

  /// 选中账本回调
  final void Function(UserBookVO book)? onSelected;

  const AccountBookSelector({
    super.key,
    required this.userId,
    this.selectedBook,
    this.onSelected,
  });

  @override
  State<AccountBookSelector> createState() => _AccountBookSelectorState();
}

class _AccountBookSelectorState extends State<AccountBookSelector> {
  /// 账本服务
  final _accountBookService = AccountBookService();

  /// 当前选中的账本
  UserBookVO? _selectedBook;

  @override
  void initState() {
    super.initState();
    _selectedBook = widget.selectedBook;
    _loadInitialBook();
  }

  /// 添加 didUpdateWidget 生命周期方法来处理外部属性更新
  @override
  void didUpdateWidget(AccountBookSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 selectedBook 发生变化时更新内部状态
    if (widget.selectedBook?.id != oldWidget.selectedBook?.id) {
      setState(() {
        _selectedBook = widget.selectedBook;
      });
      // 如果没有选中的账本，尝试加载初始账本
      if (_selectedBook == null) {
        _loadInitialBook();
      }
    }
  }

  /// 加载初始账本
  Future<void> _loadInitialBook() async {
    final result = await _accountBookService.getBooksByUserId(widget.userId);
    if (!mounted || !result.ok || result.data!.isEmpty) return;

    final books = result.data!;
    final defaultBookId = AppConfigManager.instance.defaultBookId;

    UserBookVO selectedBook;
    if (defaultBookId != null) {
      selectedBook = books.firstWhere(
        (book) => book.id == defaultBookId,
        orElse: () => _findDefaultBook(books),
      );
    } else {
      selectedBook = _findDefaultBook(books);
    }

    setState(() {
      _selectedBook = selectedBook;
    });
    widget.onSelected?.call(selectedBook);
  }

  /// 查找默认账本（第一个创建人是自己的账本）
  UserBookVO _findDefaultBook(List<UserBookVO> books) {
    return books.firstWhere(
      (book) => book.createdBy == widget.userId,
      orElse: () => books.first,
    );
  }

  /// 显示账本选择弹窗
  Future<void> _showBookSelector() async {
    final result = await CommonDialog.show<UserBookVO>(
      context: context,
      title: AppLocalizations.of(context)!.selectAccountBook,
      width: 320,
      content: _AccountBookList(userId: widget.userId),
    );

    if (result != null && mounted) {
      // 保存选中的账本ID
      await AppConfigManager.instance.setDefaultBookId(result.id);

      setState(() {
        _selectedBook = result;
      });
      widget.onSelected?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_selectedBook == null) {
      return Text(l10n.noAccountBooks);
    }

    final isOwner = _selectedBook!.createdBy == widget.userId;
    final bookName = isOwner
        ? _selectedBook!.name
        : '${_selectedBook!.name} (${_selectedBook!.createdByName})';

    return InkWell(
      onTap: _showBookSelector,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getBookIcon(_selectedBook!.icon),
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                bookName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// 账本列表
class _AccountBookList extends StatelessWidget {
  final String userId;

  const _AccountBookList({
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: FutureBuilder<OperateResult<List<UserBookVO>>>(
        future: AccountBookService().getBooksByUserId(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text(l10n.loading));
          }

          if (!snapshot.hasData || !snapshot.data!.ok) {
            return Center(
              child: Text(
                snapshot.data?.message ?? l10n.loadFailed,
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          final books = snapshot.data!.data!;
          if (books.isEmpty) {
            return Center(child: Text(l10n.noAccountBooks));
          }

          return ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: books.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: Icon(
                  _getBookIcon(book.icon),
                  color: colorScheme.primary,
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(book.name),
                    ),
                    if (book.createdBy != userId && book.createdByName != null)
                      SharedBadge(name: book.createdByName!),
                  ],
                ),
                subtitle: book.description?.isNotEmpty == true
                    ? Text(
                        book.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () async {
                  await AppConfigManager.instance.setDefaultBookId(book.id);
                  Navigator.of(context).pop(book);
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// 获取账本图标
IconData _getBookIcon(String? icon) {
  if (icon == null || icon.isEmpty) {
    return Icons.book;
  }
  // 这里可以根据icon字符串返回对应的图标
  return IconData(int.parse(icon), fontFamily: 'MaterialIcons');
}
