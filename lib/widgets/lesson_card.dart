import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LessonCard extends StatelessWidget {
  final String name;
  final String room;
  final String teacher;
  final String startTime;
  final String endTime;
  final String date;
  final String? link;

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

  Future<void> _launchURL() async {
    if (link != null) {
      final Uri url = Uri.parse(link!);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isOnline = link != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
              child: SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      startTime,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1,
                        color: theme.colorScheme.outlineVariant,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    Text(endTime, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],

                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: isOnline ? _launchURL : null,
                      child: _buildInfoRow(
                        isOnline
                            ? Icons.videocam_outlined
                            : CupertinoIcons.map_pin_ellipse,
                        room,
                        theme,
                        textColor: isOnline ? theme.colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(CupertinoIcons.person, teacher, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    ThemeData theme, {
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textColor ?? theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              decoration: textColor != null ? TextDecoration.underline : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
