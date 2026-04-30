import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widget_service.dart'; // замени your_project_name на имя своего проекта
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.name,
    required this.room,
    required this.teacher,
    required this.startTime,
    required this.endTime,
    required this.date,
    this.link,
  });

  final String name;
  final String room;
  final String teacher;
  final String startTime;
  final String endTime;
  final String date;
  final String? link;

  bool get _isOnline => link != null && link!.isNotEmpty;

  Future<void> _launchURL(BuildContext context) async {
    if (!_isOnline) return;

    final Uri url = Uri.parse(link!);
    final bool opened = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть ссылку занятия'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      startTime,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    Text(
                      endTime,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () {
                  // 1. Обновляем виджет при каждом нажатии
                  WidgetService.updateTimetableWidget(
                    subject: name,
                    timeAndRoom: '$startTime - $endTime | $room',
                  );

                  // 2. Если есть ссылка — открываем её
                  if (_isOnline) {
                    _launchURL(context);
                  } else {
                    // Опционально: показать уведомление, что виджет обновлен
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Расписание отправлено на виджет'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),

                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.5),
                      width: 1
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: _isOnline
                            ? Icons.videocam_outlined
                            : CupertinoIcons.map_pin_ellipse,
                        text: room,
                        theme: theme,
                        textColor: _isOnline ? colorScheme.primary : null,
                        underline: _isOnline,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: CupertinoIcons.person,
                        text: teacher,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required ThemeData theme,
    Color? textColor,
    bool underline = false,
  }) {
    final ColorScheme colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 16,
          color: textColor ?? colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor ?? colorScheme.onSurface,
              decoration: underline ? TextDecoration.underline : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
