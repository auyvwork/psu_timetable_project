import 'dart:convert';
import 'dart:typed_data';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:enough_convert/enough_convert.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';

class TimetableViewModel extends ChangeNotifier {
  final dio = Dio();
  final cookieJar = CookieJar();

  Map<String, List<Lesson>> _timetable = {};
  final Set<int> _loadedWeeksIds = {};
  bool _isLoading = false;
  int? _currentWeekId;

  bool get isLoading => _isLoading;

  TimetableViewModel() {
    dio.interceptors.add(CookieManager(cookieJar));
    _loadFromCache();
  }

  List<DateTime> generateDates() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return List.generate(120, (index) => monday.add(Duration(days: index)));
  }

  Future<void> initFetch() async {
    await fetchWeek();
    if (_currentWeekId != null) {
      fetchWeek(weekId: _currentWeekId! + 1);
    }
  }

  Future<void> autoFetchNext(int currentIndex) async {
    if (_isLoading || _currentWeekId == null) return;
    int weekOffset = (currentIndex + 1) ~/ 7;
    int targetWeekId = _currentWeekId! + weekOffset;

    if (!_loadedWeeksIds.contains(targetWeekId)) {
      await fetchWeek(weekId: targetWeekId);
      fetchWeek(weekId: targetWeekId + 1);
    }
  }

  Future<void> fetchWeek({int? weekId}) async {
    if (weekId != null && _loadedWeeksIds.contains(weekId)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString('username') ?? "";
      final pass = prefs.getString('password') ?? "";

      await dio.post(
        'https://student.psu.ru/pls/stu_cus_et/stu.login',
        data: {'p_redirect': '', 'p_username': user, 'p_password': pass},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final response = await dio.get<List<int>>(
        'https://student.psu.ru/pls/stu_cus_et/stu.timetable',
        queryParameters: weekId != null ? {'p_week': weekId} : {},
        options: Options(responseType: ResponseType.bytes),
      );

      const codec = Windows1251Codec();
      final html = codec.decode(Uint8List.fromList(response.data!));

      Map<String, List<Lesson>> parsedData = _parseHtml(html);

      _timetable.addAll(parsedData);

      RegExp weekNumRegex = RegExp(r'p_week=(\d+)');
      var match = weekNumRegex.firstMatch(html);
      if (match != null) {
        int id = int.parse(match.group(1)!);
        _loadedWeeksIds.add(id);
        if (weekId == null) _currentWeekId = id;
      }

      await _saveToCache();
    } catch (e) {
      debugPrint("ETIS Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, List<Lesson>> _parseHtml(String html) {
    Map<String, List<Lesson>> temp = {};
    String cleanHtml = html.replaceAll('\n', ' ').replaceAll('\r', '').replaceAll('&nbsp;', ' ');

    RegExp weekRangeRegex = RegExp(r'Неделя с (\d{2})\.(\d{2})\.(\d{4})');
    var weekMatch = weekRangeRegex.firstMatch(cleanHtml);
    if (weekMatch == null) return temp;

    DateTime mondayDate = DateTime(
        int.parse(weekMatch.group(3)!),
        int.parse(weekMatch.group(2)!),
        int.parse(weekMatch.group(1)!)
    );

    List<String> sections = cleanHtml.split('<div class="day">');
    if (sections.isNotEmpty) sections.removeAt(0);

    for (var section in sections) {
      RegExp h3Regex = RegExp(r'<h3>(.*?)</h3>');
      var hMatch = h3Regex.firstMatch(section);
      if (hMatch == null) continue;

      String header = hMatch.group(1)!.toLowerCase();
      int offset = -1;
      if (header.contains("понедельник")) offset = 0;
      else if (header.contains("вторник")) offset = 1;
      else if (header.contains("среда")) offset = 2;
      else if (header.contains("четверг")) offset = 3;
      else if (header.contains("пятница")) offset = 4;
      else if (header.contains("суббота")) offset = 5;
      else if (header.contains("воскресенье")) offset = 6;

      if (offset == -1) continue;
      String key = DateFormat('yyyy-MM-dd').format(mondayDate.add(Duration(days: offset)));

      if (section.contains('<table')) {
        List<Lesson> dayLessons = [];
        RegExp rowRegex = RegExp(r'<tr>(.*?)<\/tr>', dotAll: true);
        for (var row in rowRegex.allMatches(section)) {
          String rHtml = row.group(1)!;
          if (rHtml.contains('class="dis"')) {
            String start = RegExp(r'(\d{1,2}:\d{2})').firstMatch(rHtml)?.group(1) ?? "--:--";

            String name = _cleanTag(rHtml.split('class="dis"')[1].split('</a>')[0]);

            String teacher = rHtml.contains('class="teacher"')
                ? _cleanTag(rHtml.split('class="teacher"')[1].split('</a>')[0])
                : "Не указан";

            String room = "Не указана";
            String? link;
            if (rHtml.contains('class="aud"')) {
              String aud = rHtml.split('class="aud"')[1].split('</span>')[0];
              link = RegExp(r'href="(.*?)"').firstMatch(aud)?.group(1);
              room = _cleanTag(aud);
            }

            dayLessons.add(Lesson(
                name: name,
                room: room,
                teacher: teacher,
                startTime: start,
                endTime: _calculateEndTime(start),
                date: key,
                link: link
            ));
          }
        }
        temp[key] = dayLessons;
      }
    }
    return temp;
  }

  String _cleanTag(String s) {
    return s
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceFirst('>', '')
        .trim();
  }

  String _calculateEndTime(String start) {
    if (!start.contains(':')) return "";
    var p = start.split(':');
    var dt = DateTime(2026, 1, 1, int.parse(p[0]), int.parse(p[1]));
    return DateFormat('H:mm').format(dt.add(const Duration(hours: 1, minutes: 35)));
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_timetable.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())));
    await prefs.setString('cached_timetable', encoded);

    await prefs.setString('loaded_weeks', jsonEncode(_loadedWeeksIds.toList()));
    if (_currentWeekId != null) await prefs.setInt('current_week_id', _currentWeekId!);
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString('cached_timetable');
    if (encoded != null) {
      final Map<String, dynamic> decoded = jsonDecode(encoded);
      _timetable = decoded.map((k, v) => MapEntry(k, (v as List).map((e) => Lesson.fromJson(e)).toList()));

      final weeksStr = prefs.getString('loaded_weeks');
      if (weeksStr != null) {
        final List<dynamic> weeksList = jsonDecode(weeksStr);
        _loadedWeeksIds.addAll(weeksList.cast<int>());
      }
      _currentWeekId = prefs.getInt('current_week_id');
      notifyListeners();
    }
  }

  List<Lesson> getLessonsForDate(DateTime date) => _timetable[DateFormat('yyyy-MM-dd').format(date)] ?? [];
}