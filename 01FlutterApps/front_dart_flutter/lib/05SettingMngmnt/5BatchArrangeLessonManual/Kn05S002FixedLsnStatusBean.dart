import 'package:intl/intl.dart';

class Kn05S002FixedLsnStatusBean {
  final int weekNumber;
  final String startWeekDate;
  final String endWeekDate;
  final int fixedStatus;

  Kn05S002FixedLsnStatusBean({
    required this.weekNumber,
    required this.startWeekDate,
    required this.endWeekDate,
    required this.fixedStatus,
  });

  factory Kn05S002FixedLsnStatusBean.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Kn05S002FixedLsnStatusBean(
      weekNumber: json['weekNumber'],
      startWeekDate: dateFormat.format(DateTime.parse(json['startWeekDate'])),
      endWeekDate: dateFormat.format(DateTime.parse(json['endWeekDate'])),
      fixedStatus: json['fixedStatus'],
    );
  }
}
