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
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_sharp,
    ),
    _DrawerItem(
      label: 'Настройки',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
    ),
    _DrawerItem(
      label: 'Учебный план',
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt_sharp,
    ),
    _DrawerItem(
      label: 'Оценки',
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
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
                'ЕТИС 2.0',
                style: theme.textTheme.titleSmall?.copyWith(

                  fontWeight: FontWeight.w500,
                  fontSize: 24
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
          borderRadius: BorderRadius.circular(16),
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