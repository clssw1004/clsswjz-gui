import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../enums/storage_mode.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../manager/user_config_manager.dart';
import '../../models/common.dart';
import '../../providers/account_items_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list.dart';
import '../../widgets/common/common_app_bar.dart';
import '../account_book/account_item_form_page.dart';

class AccountItemsTab extends StatefulWidget {
  const AccountItemsTab({super.key});

  @override
  State<AccountItemsTab> createState() => _AccountItemsTabState();
}

class _AccountItemsTabState extends State<AccountItemsTab> {
  /// 刷新控制器
  final _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccountBooks();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _checkAccountBooks() async {
    final provider = context.read<AccountItemsProvider>();
    await provider.init(UserConfigManager.currentUserId);
  }

  /// 刷新数据
  Future<void> _onRefresh() async {
    final provider = context.read<AccountItemsProvider>();
    final storageType = AppConfigManager.instance.storageType;

    try {
      if (storageType == StorageMode.selfHost) {
        // 如果是自托管模式，先同步数据
        final syncService = ServiceManager.syncService;
        final result = await syncService
            .syncChange(AppConfigManager.instance.lastSyncTime!);
        if (!result.ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message ?? '同步数据失败'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          _refreshController.refreshFailed();
          return;
        }
      }

      // 刷新数据
      await provider.refresh();
      _refreshController.refreshCompleted();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AccountItemsProvider>();
    final accountBook = provider.selectedBook;

    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: AccountBookSelector(
          userId: UserConfigManager.currentUserId,
          selectedBook: provider.selectedBook,
          onSelected: provider.setSelectedBook,
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : accountBook == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noAccountBooks),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.accountBookForm,
                          );
                          if (result == true) {
                            await provider
                                .init(UserConfigManager.currentUserId);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addNew(l10n.accountBook)),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      child: AccountItemList(
                        accountBook: accountBook,
                        initialItems: provider.items,
                        onItemTap: (item) async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AccountItemFormPage(
                                accountBook: accountBook,
                                item: item,
                              ),
                            ),
                          );
                          if (result == true) {
                            provider.refresh();
                          }
                        },
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AccountItemFormPage(
                                accountBook: accountBook,
                              ),
                            ),
                          );
                          if (result == true) {
                            provider.refresh();
                          }
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
    );
  }
}
