package com.example.psu_timetable

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class MyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val timetableJson = widgetData.getString("timetable", null)
        
        val now = Calendar.getInstance()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        val displayDateFormat = SimpleDateFormat("d MMM (E)", Locale("ru"))
        val timeFormat = SimpleDateFormat("H:mm", Locale.US)
        
        val currentTimeStr = timeFormat.format(now.time)
        val todayStr = dateFormat.format(now.time)
        val nowTotalMinutes = timeToMinutes(currentTimeStr)

        var titleText = "Расписание пусто"
        var messageText = "Зайдите в приложение"

        if (!timetableJson.isNullOrEmpty()) {
            try {
                val schedule = JSONObject(timetableJson)
                val allLessons = mutableListOf<LessonWithDate>()
                
                // 1. Собираем все пары из всех доступных дней
                val dateKeys = schedule.keys()
                while (dateKeys.hasNext()) {
                    val dateKey = dateKeys.next()
                    val lessons = schedule.getJSONArray(dateKey)
                    for (i in 0 until lessons.length()) {
                        val obj = lessons.getJSONObject(i)
                        allLessons.add(LessonWithDate(
                            date = dateKey,
                            name = obj.getString("name"),
                            start = obj.getString("startTime"),
                            end = obj.getString("endTime"),
                            room = obj.getString("room")
                        ))
                    }
                }

                // 2. Сортируем по дате и времени
                allLessons.sortWith(compareBy({ it.date }, { timeToMinutes(it.start) }))

                // 3. Ищем ближайшую актуальную пару
                var foundLesson: LessonWithDate? = null
                var isCurrentlyHappening = false

                for (lesson in allLessons) {
                    val lessonTotalStart = timeToMinutes(lesson.start)
                    val lessonTotalEnd = timeToMinutes(lesson.end)

                    if (lesson.date > todayStr) {
                        // Это первая пара в будущий день
                        foundLesson = lesson
                        break
                    } else if (lesson.date == todayStr) {
                        if (nowTotalMinutes <= lessonTotalEnd) {
                            // Пара либо идет сейчас, либо будет сегодня позже
                            foundLesson = lesson
                            isCurrentlyHappening = nowTotalMinutes >= lessonTotalStart
                            break
                        }
                    }
                }

                // 4. Формируем текст
                if (foundLesson != null) {
                    val dateObj = dateFormat.parse(foundLesson.date)
                    val dateFormatted = if (foundLesson.date == todayStr) "Сегодня" 
                                       else displayDateFormat.format(dateObj!!)
                    
                    val status = if (isCurrentlyHappening) "ИДЁТ" else "СЛЕД"
                    titleText = "$dateFormatted — $status"
                    messageText = "${foundLesson.start} | ${foundLesson.name} (${foundLesson.room})"
                } else {
                    titleText = "Пар больше нет"
                    messageText = "На этой неделе всё!"
                }

            } catch (e: Exception) {
                titleText = "Ошибка данных"
                messageText = "Перезайдите в приложение"
            }
        }

        // Обновляем все виджеты
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.example_layout).apply {
                setTextViewText(R.id.widget_title, titleText)
                setTextViewText(R.id.widget_message, messageText)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun timeToMinutes(time: String): Int {
        return try {
            val parts = time.split(":")
            parts[0].toInt() * 60 + parts[1].toInt()
        } catch (e: Exception) { 0 }
    }

    data class LessonWithDate(
        val date: String,
        val name: String,
        val start: String,
        val end: String,
        val room: String
    )
}
