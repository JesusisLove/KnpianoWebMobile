// ignore: file_names
import 'package:intl/intl.dart';

class Kn01L002LsnBean {
  final String stuId;
  final String subjectId;
  final String subjectSubId;
  final String stuName;
  final String subjectName;
  final String subjectSubName;
  final int classDuration;
  final int lessonType;
  final String schedualDate; // 将其标记为 final，因为它在构造函数中被赋值。
  final String time;

  // 更新构造函数以正确赋值
  Kn01L002LsnBean({
    required this.stuId,
    required this.subjectId,
    required this.subjectSubId,
    required this.stuName,
    required this.subjectName,
    required this.subjectSubName,
    required this.classDuration,
    required this.lessonType,
    required this.schedualDate,
    required this.time,
  });

  // 更新工厂方法以正确解析和格式化日期
  factory Kn01L002LsnBean.fromJson(Map<String, dynamic> json) {
    String formattedSchedualDate = '';
    String formattedTime = '';

    try {
      if (json['schedualDate'] != null && json['schedualDate'] != '') {
        DateTime parsedDate = DateTime.parse(json['schedualDate']);
        formattedSchedualDate = DateFormat('yyyy-MM-dd HH:mm').format(parsedDate.toLocal());
        formattedTime = DateFormat('HH:mm').format(parsedDate.toLocal());
      }
    } catch (e) {
      print('Error parsing or formatting schedualDate: $e');
    }

    return Kn01L002LsnBean(
      stuId: json['stuId'] as String,
      subjectId: json['subjectId'] as String,
      subjectSubId: json['subjectSubId'] as String,
      stuName: json['stuName'] as String,
      subjectName: json['subjectName'] as String,
      subjectSubName: json['subjectSubName'] as String,
      classDuration: json['classDuration'] as int,
      lessonType: json['lessonType'] as int,
      schedualDate: formattedSchedualDate,
      time: formattedTime,
    );
  }
}
