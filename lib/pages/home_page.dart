import 'package:clsswjz/providers/books_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import '../manager/l10n_manager.dart';
import '../providers/item_list_provider.dart';
import '../providers/note_list_provider.dart';
import 'tabs/items_tab.dart';
import 'tabs/notes_tab.dart';
import 'tabs/mine_tab.dart';
import 'tabs/statistics_tab.dart';
import '../routes/app_routes.dart';
import '../enums/note_type.dart';
import '../utils/navigation_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMenuOpen = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  final double cenerIconSize = 50.0;

  final List<Widget> _pages = [
    const ItemsTab(),
    const NotesTab(),
    const StatisticsTab(),
    const MineTab(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildExpandingActionButton({
    required double padding,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Positioned(
          right: MediaQuery.of(context).size.width / 2 - 20,
          bottom: 0,
          child: Padding(
            padding: EdgeInsets.only(bottom: padding * _expandAnimation.value),
            child: Opacity(
              opacity: _expandAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    elevation: 2,
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: backgroundColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: cenerIconSize,
                    height: cenerIconSize,
                    child: FloatingActionButton(
                      heroTag: 'home_page_fab_$label',
                      elevation: 2,
                      backgroundColor: backgroundColor,
                      foregroundColor: iconColor,
                      onPressed: () {
                        _toggleMenu();
                        onPressed();
                      },
                      child: Icon(icon, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 根据当前tab处理新增按钮点击
  Future<void> _handleAddButtonTap(BuildContext context) async {
    if (_isMenuOpen) {
      _toggleMenu();
      return;
    }

    final provider = Provider.of<BooksProvider>(context, listen: false);
    switch (_currentIndex) {
      case 0: // 记账tab
        await NavigationUtil.toItemAdd(context);
        break;
      case 1: // 记事tab
        await NavigationUtil.toNoteAdd(context);
        break;
      default: // 其他tab
        _toggleMenu();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<BooksProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  color: Colors.black12,
                ),
              ),
            ),
          // 展开的按钮
          ...[
            _buildExpandingActionButton(
              padding: 25 + cenerIconSize * 2,
              icon: Icons.account_balance_wallet,
              label: L10nManager.l10n.addNew(L10nManager.l10n.accountItem),
              backgroundColor: theme.colorScheme.primary,
              iconColor: theme.colorScheme.onPrimary,
              onPressed: () => NavigationUtil.toItemAdd(context),
            ),
            _buildExpandingActionButton(
              padding: 20 + cenerIconSize,
              icon: Icons.note_alt,
              label: L10nManager.l10n.addNew(L10nManager.l10n.note),
              backgroundColor: theme.colorScheme.secondary,
              iconColor: theme.colorScheme.onSecondary,
              onPressed: () => NavigationUtil.toNoteAdd(context),
            ),
            _buildExpandingActionButton(
              padding: 15,
              icon: Icons.money,
              label: L10nManager.l10n.addNew(L10nManager.l10n.debt),
              backgroundColor: theme.colorScheme.tertiary,
              iconColor: theme.colorScheme.onTertiary,
              onPressed: () => NavigationUtil.toDebtAdd(context),
            ),
          ],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 0,
        height: 72,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.secondaryContainer,
        selectedIndex: _currentIndex > 1 ? _currentIndex + 1 : _currentIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            // 点击中间的新增按钮
            _handleAddButtonTap(context);
            return;
          }
          if (_isMenuOpen) {
            _toggleMenu();
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
            icon: GestureDetector(
              onLongPress: _toggleMenu,
              onTap: () => _handleAddButtonTap(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 2),
                width: cenerIconSize,
                height: cenerIconSize,
                decoration: BoxDecoration(
                  color: _isMenuOpen
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isMenuOpen ? 0.125 : 0,
                  child: Icon(
                    Icons.add_rounded,
                    size: 35,
                    color: _isMenuOpen
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSecondaryContainer,
                  ),
                ),
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
