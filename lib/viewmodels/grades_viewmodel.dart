import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;
import '../models/grade.dart';

class GradesViewModel extends ChangeNotifier {
  final dio = Dio();
  final cookieJar = CookieJar();

  final Map<int, List<DisciplineGrades>> _gradesByTerm = {};
  bool _isLoading = false;
  int _selectedTerm = 2;

  List<DisciplineGrades> get disciplines => _gradesByTerm[_selectedTerm] ?? [];
  List<DisciplineGrades> getDisciplinesForTerm(int term) =>
      _gradesByTerm[term] ?? [];
  bool get isLoading => _isLoading;
  int get selectedTerm => _selectedTerm;

  GradesViewModel() {
    dio.interceptors.add(CookieManager(cookieJar));
    _loadAllFromCache();
  }

  void setTerm(int term) {
    if (_selectedTerm == term) return;
    _selectedTerm = term;
    notifyListeners();
    fetchGrades(quiet: true);
  }

  Future<void> _loadAllFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (int term = 1; term <= 2; term++) {
      final String? cachedData =
          prefs.getString('cached_grades_term_$term');
      if (cachedData != null) {
        final List<dynamic> decodedData = jsonDecode(cachedData);
        _gradesByTerm[term] = decodedData
            .map((item) => DisciplineGrades.fromJson(item))
            .toList();
      } else {
        _gradesByTerm[term] = [];
      }
    }
    notifyListeners();
  }

  Future<void> _loadFromCache(int term) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('cached_grades_term_$term');
    if (cachedData != null) {
      final List<dynamic> decodedData = jsonDecode(cachedData);
      _gradesByTerm[term] = decodedData
          .map((item) => DisciplineGrades.fromJson(item))
          .toList();
    } else {
      _gradesByTerm[term] = [];
    }
  }

  Future<void> _saveToCache(int term) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
        (_gradesByTerm[term] ?? []).map((d) => d.toJson()).toList());
    await prefs.setString('cached_grades_term_$term', encodedData);
  }

  Future<void> fetchGrades({bool quiet = false}) async {
    // Показываем спиннер только если это не фоновое обновление
    if (!quiet) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final user = prefs.getString('username') ?? "";
      final pass = prefs.getString('password') ?? "";

      await dio.post(
        'https://student.psu.ru/pls/stu_cus_et/stu.login',
        data: {'p_username': user, 'p_password': pass},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final response = await dio.get(
        'https://student.psu.ru/pls/stu_cus_et/stu.signs?p_mode=current&p_term=$_selectedTerm',
        options: Options(responseType: ResponseType.bytes),
      );

      String html = await CharsetConverter.decode("windows-1251", Uint8List.fromList(response.data));
      _parseGrades(html);
      await _saveToCache(_selectedTerm);
    } catch (e) {
      debugPrint("Grades error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _parseGrades(String html) {
    final document = parse(html);
    List<DisciplineGrades> temp = [];
    var headers = document.querySelectorAll('h3');
    var tables = document.querySelectorAll('table.common');

    for (int i = 0; i < headers.length; i++) {
      String disciplineName = headers[i].text.trim();
      List<GradeItem> items = [];
      double total = 0;

      if (i < tables.length) {
        var rows = tables[i].querySelectorAll('tr');
        for (var row in rows) {
          var cells = row.querySelectorAll('td');
          if (cells.length >= 7) {
            String theme = cells[0].text.trim();
            if (theme.contains("Всего:") || theme.isEmpty || theme == "Тема") continue;
            String rawMark = cells[3].text.trim();
            double markValue = double.tryParse(rawMark.replaceAll(',', '.')) ?? 0;
            total += markValue;
            items.add(GradeItem(
              theme: theme,
              workType: cells[1].text.trim(),
              controlType: cells[2].text.trim(),
              mark: rawMark,
              maxRating: cells[6].text.trim(),
              date: cells[7].text.trim(),
            ));
          }
        }
      }
      if (items.isNotEmpty) {
        temp.add(DisciplineGrades(name: disciplineName, items: items, currentTotalPoints: total));
      }
    }
    _gradesByTerm[_selectedTerm] = temp;
  }
}