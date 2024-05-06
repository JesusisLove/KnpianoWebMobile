// FixLesson.dart
class KnFixLsn001Bean {
  final String studentName;
  final String subjectName;
  final String fixedWeek;
  final String classTime;

  KnFixLsn001Bean({required this.studentName, required this.subjectName, required this.fixedWeek, required this.classTime});

  factory KnFixLsn001Bean.fromJson(Map<String, dynamic> json) {
    return KnFixLsn001Bean(
      studentName: json['stuName'] ?? '',
      subjectName: json['subjectName'] ?? '',
      fixedWeek: json['fixedWeek'] ?? '',
      classTime: '${(json['fixedHour'] ?? '00').toString().padLeft(2,'0')}:${(json['fixedMinute'] ?? '00').toString().padLeft(2,'0')}'
    );
  }
}
