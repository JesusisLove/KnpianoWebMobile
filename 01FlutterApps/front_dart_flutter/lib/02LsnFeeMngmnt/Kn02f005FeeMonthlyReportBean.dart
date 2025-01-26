class Kn02f005FeeMonthlyReportBean {
  final double shouldPayLsnFee;
  final double hasPaidLsnFee;
  final double unpaidLsnFee;
  final String lsnMonth;
  final String stuName;
  final String stuId;

  Kn02f005FeeMonthlyReportBean({
    required this.shouldPayLsnFee,
    required this.hasPaidLsnFee,
    required this.unpaidLsnFee,
    required this.lsnMonth,
    required this.stuName,
    required this.stuId,
  });

  factory Kn02f005FeeMonthlyReportBean.fromJson(Map<String, dynamic> json) {
    return Kn02f005FeeMonthlyReportBean(
      shouldPayLsnFee : json['shouldPayLsnFee']?.toDouble() ?? 0.0,
      hasPaidLsnFee   : json['hasPaidLsnFee']?.toDouble() ?? 0.0,
      unpaidLsnFee    : json['unpaidLsnFee']?.toDouble() ?? 0.0,
      lsnMonth        : json['lsnMonth'] as String ? ?? '',
      stuName         : json['stuName'] as String ? ?? '',
      stuId           : json['stuId'] as String ? ?? '',
    );
  }
}