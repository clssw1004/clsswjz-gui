import 'package:clsswjz/providers/books_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import '../manager/l10n_manager.dart';
import 'tabs/items_tab.dart';
import 'tabs/notes_tab.dart';
import 'tabs/mine_tab.dart';
import 'tabs/statistics_tab.dart';
import '../routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ItemsTab(),
    const NotesTab(),
    const StatisticsTab(),
    const MineTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        height: 72,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.secondaryContainer,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            // 点击中间的新增按钮
            final provider = Provider.of<BooksProvider>(context, listen: false);
            Navigator.pushNamed(context, AppRoutes.itemAdd, arguments: [
              provider.selectedBook,
            ]);
            return;
          }
          final actualIndex = index > 2 ? index - 1 : index;
          setState(() {
            _currentIndex = actualIndex;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: L10nManager.l10n.tabAccountItems,
          ),
          NavigationDestination(
            icon: const Icon(Icons.note_alt_outlined),
            selectedIcon: const Icon(Icons.note_alt),
            label: L10nManager.l10n.tabNotes,
          ),
          NavigationDestination(
            icon: Container(
              margin: const EdgeInsets.only(top: 2),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 24,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: L10nManager.l10n.tabStatistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: L10nManager.l10n.tabMine,
          ),
        ],
      ),
    );
  }
}
