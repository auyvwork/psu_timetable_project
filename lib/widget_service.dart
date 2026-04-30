import 'package:home_widget/home_widget.dart';

class WidgetService {
  static Future<void> updateTimetableWidget({
    required String subject,
    required String timeAndRoom,
  }) async {
    try {
      await HomeWidget.saveWidgetData('widget_title', subject);
      await HomeWidget.saveWidgetData('widget_message', timeAndRoom);

      await HomeWidget.updateWidget(
        androidName: 'MyWidgetProvider',
      );

      print("Виджет обновлен: $subject");
    } catch (e) {
      print("Ошибка виджета: $e");
    }
  }
}