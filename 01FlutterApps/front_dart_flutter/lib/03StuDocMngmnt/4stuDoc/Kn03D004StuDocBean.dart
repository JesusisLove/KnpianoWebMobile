class Kn03D004StuDocBean {
  final String stuId;
  final String subjectId;
  final String subjectSubId; // 枝番番号
  final String stuName;
  final String subjectName;
  final String subjectSubName; // 枝番名称
  final String adjustedDate;
  // late DateTime adjustedDate;
  final int    payStyle;
  final int    minutesPerLsn;
  final double lessonFee;
  final double lessonFeeAdjusted;
  final String examDate;
  final double examScore;

  Kn03D004StuDocBean({
    required this.stuId,
    required this.subjectId,
    required this.subjectSubId,
    required this.stuName,
    required this.subjectName,
    required this.subjectSubName,
    required this.adjustedDate,
    required this.payStyle,
    required this.minutesPerLsn,
    required this.lessonFee,
    required this.lessonFeeAdjusted,
    required this.examDate,
    required this.examScore,
  });

  // 从后台拿到的json数据转化为Kn03D004StuDocBean对象
  factory Kn03D004StuDocBean.fromJson(Map<String, dynamic> json) {
    return Kn03D004StuDocBean(
      stuId:              json['stuId'] ?? '',
      subjectId:          json['subjectId'] ?? '',
      subjectSubId:       json['subjectSubId'] ?? '',
      stuName:            json['stuName'] ?? '',
      subjectName:        json['subjectName'] ?? '',
      subjectSubName:     json['subjectSubName'] ?? '',
      // adjustedDate:       DateTime.parse(json['adjustedDate']).toLocal(),
      adjustedDate:       json['adjustedDate'] ?? '',
      payStyle:           json['payStyle'] ?? 0,
      minutesPerLsn:      json['minutesPerLsn'] ?? 0,
      lessonFee:          json['lessonFee']?.toDouble() ?? 0.0,
      lessonFeeAdjusted:  json['lessonFeeAdjusted']?.toDouble() ?? 0.0,
      examDate:           json['examDate'] ?? '',
      examScore:          json['examScore']?.toDouble() ?? 0.0,
    );
  }
}