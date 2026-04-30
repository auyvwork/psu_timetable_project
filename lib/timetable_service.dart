import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimetableService {
  static const String _timetableKey = 'weekly_timetable';

  // Сохраняем всё расписание на неделю
  static Future<void> saveWeeklyTimetable(Map<String, List<Lesson>> weeklySchedule) async {
    final prefs = await SharedPreferences.getInstance();

    // Конвертируем расписание в JSON
    final Map<String, dynamic> jsonSchedule = {};
    weeklySchedule.forEach((day, lessons) {
      jsonSchedule[day] = lessons.map((lesson) => lesson.toJson()).toList();
    });

    await prefs.setString(_timetableKey, jsonEncode(jsonSchedule));

    // Сохраняем также в HomeWidget для быстрого доступа
    await HomeWidget.saveWidgetData('timetable', jsonEncode(jsonSchedule));

    // Принудительно обновляем виджет
    await HomeWidget.updateWidget(androidName: 'MyWidgetProvider');
  }

  // Загружаем расписание
  static Future<Map<String, List<Lesson>>> loadWeeklyTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_timetableKey);

    if (jsonString == null) return {};

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final Map<String, List<Lesson>> schedule = {};

    jsonMap.forEach((day, lessonsJson) {
      schedule[day] = (lessonsJson as List)
          .map((json) => Lesson.fromJson(json))
          .toList();
    });

    return schedule;
  }
}

class Lesson {
  final String name;
  final String room;
  final String teacher;
  final String startTime;
  final String endTime;
  final String date;
  final String? link;

  Lesson({
    required this.name,
    required this.room,
    required this.teacher,
    required this.startTime,
    required this.endTime,
    required this.date,
    this.link,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'room': room,
    'teacher': teacher,
    'startTime': startTime,
    'endTime': endTime,
    'date': date,
    'link': link,
  };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    name: json['name'],
    room: json['room'],
    teacher: json['teacher'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    date: json['date'],
    link: json['link'],
  );
}