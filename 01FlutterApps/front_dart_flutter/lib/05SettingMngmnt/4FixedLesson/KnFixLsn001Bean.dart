// FixLesson.dart
class KnFixLsn001Bean {
  final String studentId;
  final String subjectId;
  final String studentName;
  final String subjectName;
  final String fixedWeek;
  final int fixedHour;
  final int fixedMinute;
  final String classTime;

  KnFixLsn001Bean({required this.studentId, 
                   required this.subjectId, 
                   required this.studentName, 
                   required this.subjectName, 
                   required this.fixedWeek, 
                   required this.fixedHour,
                   required this.fixedMinute,
                   required this.classTime});

  factory KnFixLsn001Bean.fromJson(Map<String, dynamic> json) {
    return KnFixLsn001Bean(
      studentId: json['stuId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      studentName: json['stuName'] ?? '',
      subjectName: json['subjectName'] ?? '',
      fixedWeek: json['fixedWeek'] ?? '',
      fixedHour: json['fixedHour'] ?? '',
      fixedMinute: json['fixedMinute'] ?? '',
      classTime: '${(json['fixedHour'] ?? '00').toString().padLeft(2,'0')}:${(json['fixedMinute'] ?? '00').toString().padLeft(2,'0')}'
    );
  }
}