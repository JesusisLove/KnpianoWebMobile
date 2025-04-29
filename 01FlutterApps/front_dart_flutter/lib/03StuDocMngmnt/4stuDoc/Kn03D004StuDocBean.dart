import 'package:intl/intl.dart';

class Kn03D004StuDocBean {
  final String stuId;
  final String subjectId;
  final String subjectSubId; // 枝番番号
  final String stuName;
  final String nikName;
  final String subjectName;
  final String subjectSubName; // 枝番名称
  final String adjustedDate;
  final int payStyle;
  final int minutesPerLsn;
  final int subjectCount;
  final double lessonFee;
  final double lessonFeeAdjusted;
  final String examDate;
  final double examScore;
  final String introducer;

  Kn03D004StuDocBean({
    required this.stuId,
    required this.subjectId,
    required this.subjectSubId,
    required this.stuName,
    required this.nikName,
    required this.subjectName,
    required this.subjectSubName,
    required this.adjustedDate,
    required this.payStyle,
    required this.minutesPerLsn,
    required this.subjectCount,
    required this.lessonFee,
    required this.lessonFeeAdjusted,
    required this.examDate,
    required this.examScore,
    required this.introducer,
  });

  // 从后台拿到的json数据转化为Kn03D004StuDocBean对象
  factory Kn03D004StuDocBean.fromJson(Map<String, dynamic> json) {
    String formattedAdjustedDate = '';
    try {
      if (json['adjustedDate'] != null && json['adjustedDate'] != '') {
        DateTime parsedDate = DateTime.parse(json['adjustedDate']);
        /* 解决从后端java传到前端，日期总是偏差一天的处理 例如，java端给出的日期是2024-01-01，到了前端却变成了2023-12-31T15:00:00.000+00:00 
        下面代码是处理从后端java传递过来的日期，在前端也能正常显示
        */
        formattedAdjustedDate =
            DateFormat('yyyy-MM-dd').format(parsedDate.toLocal());
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing or formatting adjustedDate: $e');
    }

    return Kn03D004StuDocBean(
      stuId: json['stuId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      subjectSubId: json['subjectSubId'] ?? '',
      stuName: json['stuName'] ?? '',
      nikName: json['nikName'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectSubName: json['subjectSubName'] ?? '',
      adjustedDate: formattedAdjustedDate,
      payStyle: json['payStyle'] ?? 0,
      minutesPerLsn: json['minutesPerLsn'] ?? 0,
      subjectCount: json['subjectCount'] ?? 0,
      lessonFee: json['lessonFee']?.toDouble() ?? 0.0,
      lessonFeeAdjusted: json['lessonFeeAdjusted']?.toDouble() ?? 0.0,
      examDate: json['examDate'] ?? '',
      examScore: json['examScore']?.toDouble() ?? 0.0,
      introducer: json['introducer'] ?? '',
    );
  }
}
