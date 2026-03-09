import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/settings_screen.dart';
import '../screens/timetable_screen.dart';
import '../screens/plan_screen.dart';
import '../screens/grades_screen.dart';
import 'app_menu_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.onLogout,
  });

  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const double _drawerWidth = 280.0;
  static const List<String> _titles = <String>[
    'Расписание',
    'Настройки',
    'План',
    'Оценки',
  ];

  late final AnimationController _menuController;
  int _currentIndex = 0;

  final ValueNotifier<String> _subtitleNotifier =
      ValueNotifier<String>('ПГНИУ • Очное');
  final ValueNotifier<IconData?> _actionIconNotifier =
      ValueNotifier<IconData?>(null);
  VoidCallback? _onActionPressed;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _subtitleNotifier.dispose();
    _actionIconNotifier.dispose();
    super.dispose();
  }

  void _updateAppBar({
    required String subtitle,
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    Future<void>.microtask(() {
      _subtitleNotifier.value = subtitle;
      _actionIconNotifier.value = icon;
      _onActionPressed = onPressed;
    });
  }

  void _toggleMenu() {
    if (_menuController.isCompleted) {
      _menuController.reverse();
    } else {
      _menuController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return
       Scaffold(
        body: Stack(
          children: <Widget>[
            _buildDrawer(),
            AnimatedBuilder(
              animation: _menuController,
              builder: (BuildContext context, Widget? child) {
                return Transform.translate(
                  offset: Offset(_menuController.value * _drawerWidth, 0),
                  child: child,
                );
              },
              child: Stack(
                children: <Widget>[
                  _buildMainScreen(theme, theme.colorScheme),
                  _buildOverlay(),
                ],
              ),
            ),
          ],
        ),

    );
  }

  Widget _buildMainScreen(ThemeData theme, ColorScheme colorScheme) {
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemStatusBarContrastEnforced: false,
        ),

        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(top: 12, left: 8),
          child: IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: _toggleMenu,

            padding: EdgeInsets.zero,

            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(
              fixedSize: const Size(44, 44),
              shape: const CircleBorder(),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        title: ValueListenableBuilder<String>(
          valueListenable: _subtitleNotifier,
          builder: (BuildContext context, String subtitle, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 12),
                Text(
                  _titles[_currentIndex],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12, right: 8),
            child: ValueListenableBuilder<IconData?>(
              valueListenable: _actionIconNotifier,
              builder: (BuildContext context, IconData? icon, _) {
                if (icon == null) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  icon: Icon(icon),
                  onPressed: () => _onActionPressed?.call(),
                );
              },
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          TimetableScreen(onHeaderUpdate: _updateAppBar),
          SettingsScreen(
            onThemeChanged: widget.onThemeChanged,
            onLogout: widget.onLogout,
          ),
          const AcademicPlanScreen(),
          const GradesScreen(),
        ],
      ),
    );

  }

  Widget _buildOverlay() {
    return AnimatedBuilder(
      animation: _menuController,
      builder: (BuildContext context, _) {
        if (_menuController.value == 0) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: _toggleMenu,
          child: Container(
            color: Colors.black.withOpacity(_menuController.value * 0.5),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
      animation: _menuController,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset:
              Offset(-_drawerWidth + (_menuController.value * _drawerWidth), 0),
          child: SizedBox(width: _drawerWidth, child: child),
        );
      },
      child: AppNavigationDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
          if (index != 0) {
            _subtitleNotifier.value = 'ПГНИУ • Очное';
            _actionIconNotifier.value = null;
          }
          _toggleMenu();
        },
      ),
    );
  }
}