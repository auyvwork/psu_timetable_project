class GradeItem {
  GradeItem({
    required this.theme,
    required this.workType,
    required this.controlType,
    required this.mark,
    required this.maxRating,
    required this.date,
  });

  final String theme;
  final String workType;
  final String controlType;
  final String mark;
  final String maxRating;
  final String date;

  factory GradeItem.fromJson(Map<String, dynamic> json) {
    return GradeItem(
      theme: json['theme'] as String? ?? '',
      workType: json['workType'] as String? ?? '',
      controlType: json['controlType'] as String? ?? '',
      mark: json['mark'] as String? ?? '',
      maxRating: json['maxRating'] as String? ?? '',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'theme': theme,
      'workType': workType,
      'controlType': controlType,
      'mark': mark,
      'maxRating': maxRating,
      'date': date,
    };
  }
}

class DisciplineGrades {
  DisciplineGrades({
    required this.name,
    required this.items,
    required this.currentTotalPoints,
  });

  final String name;
  final List<GradeItem> items;
  final double currentTotalPoints;

  factory DisciplineGrades.fromJson(Map<String, dynamic> json) {
    return DisciplineGrades(
      name: json['name'] as String? ?? '',
      currentTotalPoints:
          (json['currentTotalPoints'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) =>
              GradeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'currentTotalPoints': currentTotalPoints,
      'items': items.map((GradeItem e) => e.toJson()).toList(),
    };
  }
}

