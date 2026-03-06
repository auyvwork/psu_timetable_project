import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/timetable_screen.dart';
import '../screens/settings_screen.dart';
import 'app_menu_drawer.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final VoidCallback onLogout;

  const HomePage({
    super.key,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  final double _drawerWidth = 280.0;


  final ValueNotifier<String> _subtitleNotifier = ValueNotifier("ПГНИУ • Очное");
  final ValueNotifier<IconData?> _actionIconNotifier = ValueNotifier(null);
  VoidCallback? _onActionPressed;

  void _updateAppBar({required String subtitle, IconData? icon, VoidCallback? onPressed}) {

    Future.microtask(() {
      _subtitleNotifier.value = subtitle;
      _actionIconNotifier.value = icon;
      _onActionPressed = onPressed;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  }

  void _toggleMenu() => _controller.isCompleted ? _controller.reverse() : _controller.forward();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [

            _buildDrawer(),


            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_controller.value * _drawerWidth, 0),
                  child: child,
                );
              },
              child: Stack(
                children: [
                  _buildMainScreen(theme,theme.colorScheme),
                  _buildOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen(ThemeData theme, ColorScheme colorScheme) {
    return
       Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
          surfaceTintColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(top: 24, left: 8),
            child: IconButton(
              icon: const Icon(Icons.menu, size: 28),
              onPressed: _toggleMenu,
            ),),
          title: ValueListenableBuilder<String>(
            valueListenable: _subtitleNotifier,
            builder: (context, subtitle, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    ["Расписание", "Настройки", "План", "Оценки"][_currentIndex],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              );
            },
          ),
          actions: [
        Padding(
        padding: const EdgeInsets.only(top: 24, left: 8),
         child:
            ValueListenableBuilder<IconData?>(
              valueListenable: _actionIconNotifier,
              builder: (context, icon, _) {
                if (icon == null) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(icon),
                  onPressed: () => _onActionPressed?.call(),
                );
              },
            ),
        )
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            TimetableScreen(onHeaderUpdate: _updateAppBar),
            SettingsScreen(onThemeChanged: widget.onThemeChanged, onLogout: widget.onLogout),
            const Center(child: Text("План")),
            const Center(child: Text("Оценки")),
          ],
        ),
      );

  }

  Widget _buildOverlay() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.value == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: _toggleMenu,
          child: Container(
            color: Colors.black.withOpacity(_controller.value * 0.5),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(-_drawerWidth + (_controller.value * _drawerWidth), 0),
        child: SizedBox(width: _drawerWidth, child: child),
      ),
      child: AppNavigationDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index != 0) {
            _subtitleNotifier.value = "ПГНИУ • Очное";
            _actionIconNotifier.value = null;
          }
          _toggleMenu();
        },
      ),
    );
  }
}