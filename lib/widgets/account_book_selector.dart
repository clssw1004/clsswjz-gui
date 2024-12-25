import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/common.dart';
import '../models/vo/user_book_vo.dart';
import '../services/account_book_service.dart';
import 'common_dialog.dart';

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

  /// 加载初始账本
  Future<void> _loadInitialBook() async {
    if (_selectedBook == null) {
      final result =
          await _accountBookService.getAccountsByUserId(widget.userId);
      if (result.ok && result.data!.isNotEmpty) {
        setState(() {
          _selectedBook = result.data!.first;
        });
        widget.onSelected?.call(_selectedBook!);
      }
    }
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

    return InkWell(
      onTap: _showBookSelector,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedBook != null) ...[
              Text(
                _selectedBook!.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
            ] else
              Text(l10n.loading),
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
        future: AccountBookService().getAccountsByUserId(userId),
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
                  Icons.book,
                  color: colorScheme.primary,
                ),
                title: Text(book.name),
                subtitle: Text(
                  book.description ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => Navigator.of(context).pop(book),
              );
            },
          );
        },
      ),
    );
  }
}
