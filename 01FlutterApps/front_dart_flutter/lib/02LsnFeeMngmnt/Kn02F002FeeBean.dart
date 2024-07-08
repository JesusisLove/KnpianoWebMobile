import 'package:intl/intl.dart';

class Kn02F002FeeBean {
  final String lsnFeeId;
  final String lessonId;
  final double lsnFee;
  final String lsnMonth;
  final int ownFlg;
  final int lessonType;
  final String stuId;
  final String subjectId;
  final String stuName;
  final String subjectName;
  final int payStyle;
  final double lsnCount;
  // 画面用变量
  final int month;
  final String payDate;
  final int? payStatus;

  Kn02F002FeeBean({
    required this.lsnFeeId,
    required this.lessonId,
    required this.lsnFee,
    required this.lsnMonth,
    required this.ownFlg,
    required this.lessonType,
    required this.stuId,
    required this.subjectId,
    required this.stuName,
    required this.subjectName,
    required this.payStyle,
    required this.lsnCount,
    // 画面用变量
    required this.month,
    required this.payDate,
    required this.payStatus,
  });

  factory Kn02F002FeeBean.fromJson(Map<String, dynamic> json) {
    String formattedPayDate = '';

    try {
      if (json['payDate'] != null && json['payDate'] != '') {
        DateTime parsedDate = DateTime.parse(json['payDate']);
        formattedPayDate = DateFormat('yyyy-MM-dd').format(parsedDate.toLocal());
      }
    } catch (e) {
      print('Error parsing or formatting payDate: $e');
    }

    String lsnMonth = json['lsnMonth'] ?? '';
    int month = 0;// 从 "2024-06" 提取月份
    if (lsnMonth.isNotEmpty) {
      try {
        month = int.parse(lsnMonth.split('-')[1]);
      } catch (e) {
        print('Error parsing month: $e');
      }
    }

    return Kn02F002FeeBean(
      lsnFeeId    : json['lsnFeeId'] ?? '',
      lessonId    : json['lessonId'] ?? '',
      lsnFee      : json['lsnFee']?.toDouble() ?? 0.0,
      lsnMonth    : json['lsnMonth'] ?? '',
      ownFlg      : json['ownFlg'] ?? 0,
      lessonType  : json['lessonType'] ?? 0,
      stuId       : json['stuId'] ?? '',
      subjectId   : json['subjectId'] ?? '',
      stuName     : json['stuName'] ?? '',
      subjectName : json['subjectName'] ?? '',
      payStyle    : json['payStyle'] ?? 0,
      lsnCount    : json['lsnCount']?.toDouble() ?? 0.0,
      month       : month,
      payDate     : formattedPayDate,
      payStatus   : json['payStatus'] as int? ?? 0,
    );
  }
}
