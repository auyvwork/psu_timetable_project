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