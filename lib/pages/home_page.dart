import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../manager/l10n_manager.dart';
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
    return Scaffold(
      body: _pages[_currentIndex],
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
            label: L10nManager.l10n.tabAccountItems,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: L10nManager.l10n.tabMine,
          ),
        ],
      ),
    );
  }
}
