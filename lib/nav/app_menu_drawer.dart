import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppNavigationDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppNavigationDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> items = [
      {"label": "Расписание", "icon": CupertinoIcons.calendar_today, "active": CupertinoIcons.calendar_today},
      {"label": "Настройки", "icon": CupertinoIcons.settings, "active": CupertinoIcons.settings_solid},
      {"label": "Учебный план", "icon": CupertinoIcons.square_list, "active": CupertinoIcons.square_list_fill},
      {"label": "Оценки", "icon": Icons.auto_graph_rounded, "active": Icons.auto_graph_rounded},
    ];

    return Material(


      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 16, 12),
              child: Text(
                "Меню ПГНИУ",
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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final bool isSelected = selectedIndex == index;
                  final item = items[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: NavigationDrawerDestinationWidget(
                      label: item["label"],
                      icon: Icon(item["icon"]),
                      selectedIcon: Icon(item["active"]),
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
  final String label;
  final Widget icon;
  final Widget selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationDrawerDestinationWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
        ),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
              ),
              child: isSelected ? selectedIcon : icon,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}