import 'package:intl/intl.dart';

class Kn02F003AdvcLsnFeePayBean {
  final String lessonId;
  final String lsnFeeId;
  final String lsnPayId;
  final String subjectId;
  final String subjectSubId;
  final String subjectName;
  final String subjectSubName;
  final String stuId;
  final String stuName;
  final int classDuration;
  final int lessonType;
  final int schedualType;
  final String schedualDate;
  final int payStyle;
  final double subjectPrice;
  final int minutesPerLsn;
  final double lsnPay;
  final String bankId;
  final String bankName;
  final int advcFlg;

  Kn02F003AdvcLsnFeePayBean({
    required this.lessonId,
    required this.lsnFeeId,
    required this.lsnPayId,
    required this.subjectId,
    required this.subjectSubId,
    required this.subjectName,
    required this.subjectSubName,
    required this.stuId,
    required this.stuName,
    required this.classDuration,
    required this.lessonType,
    required this.schedualType,
    required this.schedualDate,
    required this.payStyle,
    required this.subjectPrice,
    required this.minutesPerLsn,
    required this.lsnPay,
    required this.bankId,
    required this.bankName,
    required this.advcFlg,
  });

  factory Kn02F003AdvcLsnFeePayBean.fromJson(Map<String, dynamic> json) {
    String formattedSchedualDate = '';
    try {
      if (json['schedualDate'] != null && json['schedualDate'] != '') {
        DateTime parsedDate = DateTime.parse(json['schedualDate']);
        formattedSchedualDate = DateFormat('yyyy-MM-dd hh:mm').format(parsedDate.toLocal());
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error parsing or formatting schedualDate: $e');
    }

    return Kn02F003AdvcLsnFeePayBean(
      lessonId: json['lessonId'] ?? '',
      lsnFeeId: json['lsnFeeId'] ?? '',
      lsnPayId: json['lsnPayId'] ?? '',
      subjectId: json['subjectId'] ?? '',
      subjectSubId: json['subjectSubId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectSubName: json['subjectSubName'] ?? '',
      stuId: json['stuId'] ?? '',
      stuName: json['stuName'] ?? '',
      classDuration: json['classDuration'] ?? 0,
      lessonType: json['lessonType'] ?? 0,
      schedualType: json['schedualType'] ?? 0,
      schedualDate: formattedSchedualDate,
      payStyle: json['payStyle'] ?? 0,
      subjectPrice: json['subjectPrice']?.toDouble() ?? 0.0,
      minutesPerLsn: json['minutesPerLsn'] ?? 0,
      lsnPay: json['lsnPay']?.toDouble() ?? 0.0,
      bankId: json['bankId'] ?? '',
      bankName: json['bankName'] ?? '',
      advcFlg: json['advcFlg'] ?? 0,
    );
  }
}