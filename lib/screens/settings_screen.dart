import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsScreen extends StatelessWidget {
  final Function(bool) onThemeChanged;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          _buildSectionHeader(theme, "Настройки"),
          const SizedBox(height: 12),
          _buildCard(theme, [
            SwitchListTile(
              secondary: Icon(
                isDark ? CupertinoIcons.moon_fill : CupertinoIcons.sun_max_fill,
                color: const Color(0xFF4264EB),
              ),
              title: const Text("Тёмная тема", style: TextStyle(fontWeight: FontWeight.w500)),
              value: isDark,
              activeColor: const Color(0xFF4264EB),
              onChanged: onThemeChanged,
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionHeader(theme, "Безопасность"),
          const SizedBox(height: 12),
          _buildCard(theme, [
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text("Выйти из профиля", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () => _confirmLogout(context),
            ),
          ]),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Выход"),
        content: const Text("Данные входа будут удалены. Вы уверены?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
          ElevatedButton(
            onPressed: onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Выйти"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
    );
  }

  Widget _buildCard(ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }
}