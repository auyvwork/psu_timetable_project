import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLogout,
  });

  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: <Widget>[
          _buildSectionHeader('Настройки', theme),
          const SizedBox(height: 12),
          _buildCard(
            theme: theme,
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: Icon(
                isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                color: colorScheme.primary,
              ),
              title: const Text(
                'Тёмная тема',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              value: isDark,
              activeColor: colorScheme.primary,
              onChanged: onThemeChanged,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Безопасность', theme),
          const SizedBox(height: 12),
          _buildCard(
            theme: theme,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(
                Icons.logout_rounded,
                color: colorScheme.error,
              ),
              title: Text(
                'Выйти из профиля',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _confirmLogout(context, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, ColorScheme colorScheme) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Выход'),
        content: const Text('Данные входа будут удалены. Вы уверены?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildCard({
    required ThemeData theme,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white10
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: child,
    );
  }
}