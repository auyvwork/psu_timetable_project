import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<_DrawerItem> _items = <_DrawerItem>[
    _DrawerItem(
      label: 'Расписание',
      icon: CupertinoIcons.calendar_today,
      activeIcon: CupertinoIcons.calendar_today,
    ),
    _DrawerItem(
      label: 'Настройки',
      icon: CupertinoIcons.settings,
      activeIcon: CupertinoIcons.settings_solid,
    ),
    _DrawerItem(
      label: 'Учебный план',
      icon: CupertinoIcons.square_list,
      activeIcon: CupertinoIcons.square_list_fill,
    ),
    _DrawerItem(
      label: 'Оценки',
      icon: Icons.auto_graph_rounded,
      activeIcon: Icons.auto_graph_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Material(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 16, 12),
              child: Text(
                'Меню ПГНИУ',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Divider(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  final bool isSelected = selectedIndex == index;
                  final _DrawerItem item = _items[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: NavigationDrawerDestinationWidget(
                      label: item.label,
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.activeIcon),
                      isSelected: isSelected,
                      onTap: () => onDestinationSelected(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationDrawerDestinationWidget extends StatelessWidget {
  const NavigationDrawerDestinationWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color:
              isSelected ? colorScheme.secondaryContainer : Colors.transparent,
        ),
        child: Row(
          children: <Widget>[
            IconTheme(
              data: IconThemeData(
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              child: isSelected ? selectedIcon : icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}