import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../widgets/common/progress_indicator_bar.dart';
import 'tabs/account_items_tab.dart';
import 'tabs/mine_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AccountItemsTab(),
    const MineTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final syncProvider = context.watch<SyncProvider>();

    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          // 同步进度条
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (syncProvider.syncing)
                  ProgressIndicatorBar(
                    value: syncProvider.progress > 0 ? syncProvider.progress : null,
                    label: syncProvider.currentStep ?? l10n.syncing,
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: l10n.tabAccountItems,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.tabMine,
          ),
        ],
      ),
    );
  }
}
