import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Discipline {
  final String name;
  final String controlType;
  final String totalHours;

  Discipline({required this.name, required this.controlType, required this.totalHours});
}

class AcademicPlanViewModel extends ChangeNotifier {
  final dio = Dio();
  final cookieJar = CookieJar();

  Map<String, List<Discipline>> _groupedPlan = {};
  bool _isLoading = false;

  Map<String, List<Discipline>> get groupedPlan => _groupedPlan;
  bool get isLoading => _isLoading;

  AcademicPlanViewModel() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<void> fetchPlan() async {
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
        'https://student.psu.ru/pls/stu_cus_et/stu.teach_plan',
        options: Options(responseType: ResponseType.bytes),
      );

      String html = await CharsetConverter.decode("windows-1251", Uint8List.fromList(response.data!));

      Map<String, List<Discipline>> tempGrouped = {};
      var semesterChunks = html.split('<h3>');

      for (var chunk in semesterChunks) {
        if (!chunk.contains('</h3>')) continue;
        String semName = chunk.split('</h3>')[0].trim();
        tempGrouped[semName] = [];

        var rows = chunk.split('<tr');
        for (var row in rows) {
          if (row.contains('stu.tpr?')) {
            RegExp nameRegex = RegExp(r'<a[^>]*>(.*?)<\/a>');
            var nameMatch = nameRegex.firstMatch(row);
            String name = nameMatch?.group(1)?.replaceAll('<br>', ' ').replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? "";

            RegExp cellRegex = RegExp(r'<td[^>]*>(.*?)<\/td>', dotAll: true);
            var matches = cellRegex.allMatches(row).toList();

            if (matches.length >= 4) {
              String type = matches[matches.length - 4].group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? "-";
              String hours = matches.last.group(1)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? "0";

              if (name.isNotEmpty && name != "Программы дисциплин" && !name.contains("оценить")) {
                tempGrouped[semName]?.add(Discipline(name: name, controlType: type, totalHours: hours));
              }
            }
          }
        }
      }

      _groupedPlan = tempGrouped..removeWhere((k, v) => v.isEmpty);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}