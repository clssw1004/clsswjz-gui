import 'package:flutter/material.dart';
import '../manager/l10n_manager.dart';
import 'tabs/items_tab.dart';
import 'tabs/notes_tab.dart';
import 'tabs/mine_tab.dart';
import 'tabs/statistics_tab.dart';
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
  late Animation<double> _fadeAnimation;
  final double centerIconSize = 52.0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ItemsTab(),
      const NotesTab(),
      const StatisticsTab(),
      const MineTab(),
    ];
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _fadeAnimation = CurvedAnimation(
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
          right: MediaQuery.of(context).size.width / 2 - 22,
          bottom: 0,
          child: Padding(
            padding: EdgeInsets.only(bottom: padding * _expandAnimation.value),
            child: IgnorePointer(
              ignoring: _expandAnimation.value == 0,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      elevation: 3,
                      shadowColor: backgroundColor.withAlpha(80),
                      color: Theme.of(context).colorScheme.surface,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: backgroundColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: centerIconSize,
                      height: centerIconSize,
                      child: FloatingActionButton(
                        heroTag: 'home_page_fab_$label',
                        elevation: 4,
                        highlightElevation: 8,
                        backgroundColor: backgroundColor,
                        foregroundColor: iconColor,
                        shape: const CircleBorder(),
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
    switch (_currentIndex) {
      case 0:
        await NavigationUtil.toItemAdd(context);
        break;
      case 1:
        await NavigationUtil.toNoteAdd(context);
        break;
      default:
        _toggleMenu();
        break;
    }
  }

  void _handleLongPress() {
    _toggleMenu();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          if (_isMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  color: colorScheme.scrim.withAlpha(40),
                ),
              ),
            ),
          // 展开的动作按钮
          ...[
            _buildExpandingActionButton(
              padding: 25 + centerIconSize * 2,
              icon: Icons.note_alt,
              label: L10nManager.l10n.addNew(L10nManager.l10n.note),
              backgroundColor: colorScheme.secondary,
              iconColor: colorScheme.onSecondary,
              onPressed: () => NavigationUtil.toNoteAdd(context),
            ),
            _buildExpandingActionButton(
              padding: 20 + centerIconSize,
              icon: Icons.money,
              label: L10nManager.l10n.addNew(L10nManager.l10n.debt),
              backgroundColor: colorScheme.tertiary,
              iconColor: colorScheme.onTertiary,
              onPressed: () => NavigationUtil.toDebtAdd(context),
            ),
            _buildExpandingActionButton(
              padding: 15,
              icon: Icons.account_balance_wallet,
              label: L10nManager.l10n.addNew(L10nManager.l10n.accountItem),
              backgroundColor: colorScheme.primary,
              iconColor: colorScheme.onPrimary,
              onPressed: () => NavigationUtil.toItemAdd(context),
            ),
          ],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 2,
        height: 68,
        shadowColor: colorScheme.shadow,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedIndex: _currentIndex > 1 ? _currentIndex + 1 : _currentIndex,
        onDestinationSelected: (index) {
          FocusScope.of(context).unfocus();
          if (index == 2) {
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
            icon: Icon(Icons.account_balance_wallet_outlined,
                color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.account_balance_wallet,
                color: colorScheme.onSecondaryContainer),
            label: L10nManager.l10n.tabAccountItems,
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined,
                color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.note_alt,
                color: colorScheme.onSecondaryContainer),
            label: L10nManager.l10n.tabNotes,
          ),
          NavigationDestination(
            icon: GestureDetector(
              onLongPress: _handleLongPress,
              onTap: () => _handleAddButtonTap(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(top: 2),
                width: centerIconSize,
                height: centerIconSize,
                decoration: BoxDecoration(
                  color: _isMenuOpen
                      ? colorScheme.primary
                      : colorScheme.secondary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isMenuOpen
                              ? colorScheme.primary
                              : colorScheme.secondary)
                          .withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: _isMenuOpen ? 0.125 : 0,
                  child: Icon(
                    Icons.add_rounded,
                    size: 32,
                    color: colorScheme.onSecondary,
                  ),
                ),
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined,
                color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.bar_chart,
                color: colorScheme.onSecondaryContainer),
            label: L10nManager.l10n.tabStatistics,
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline,
                color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.person,
                color: colorScheme.onSecondaryContainer),
            label: L10nManager.l10n.tabMine,
          ),
        ],
      ),
    );
  }
}
