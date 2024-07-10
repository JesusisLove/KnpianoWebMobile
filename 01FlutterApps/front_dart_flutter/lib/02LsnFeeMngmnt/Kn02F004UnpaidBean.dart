import 'package:intl/intl.dart';

class Kn02F004UnpaidBean {
  final String? lsnPayId;
  final String  lsnFeeId;
  final double  lsnPay;
  final String  payMonth;
  late  String  bankId;
  final String  payDate;

  // 表关联项目
  final int?    lessonType;
  final String? stuId;
  final String? subjectId;
  final String? subjectSubId;
  final String? stuName;
  final String? subjectName;
  final String? subjectSubName;
  final String? lsnMonth;
  final int?    payStyle;
  final int?    lsnCount;
  final double? lsnFee;
  final int?    ownFlg;
  // 为了按月交费的计划课的精算业务，需要《学生档案》表里对象科目的最新价格
  final double? subjectPrice;

  Kn02F004UnpaidBean({
             this.lsnPayId,
    required this.lsnFeeId,
    required this.lsnPay,
    required this.payMonth,
    required this.payDate,
    required this.bankId,
             this.lessonType,
             this.stuId,
             this.subjectId,
             this.subjectSubId,
             this.stuName,
             this.subjectName,
             this.subjectSubName,
             this.lsnMonth,
             this.payStyle,
             this.lsnCount,
             this.lsnFee,
             this.ownFlg,
             this.subjectPrice,
  });

  // 从后台拿到的json数据转化为Kn02F004UnpaidBean对象
  factory Kn02F004UnpaidBean.fromJson(Map<String, dynamic> json) {
     String formattedPayDate = '';
    try {
      if (json['schedualDate'] != null && json['schedualDate'] != '') {
        DateTime parsedDate = DateTime.parse(json['schedualDate']);
        formattedPayDate = DateFormat('yyyy-MM-dd').format(parsedDate.toLocal());
      }
    } catch (e) {
      print('Error parsing or formatting schedualDate: $e');
    }

    return Kn02F004UnpaidBean(
      lsnPayId        : json['lsnPayId'] ?? '',
      lsnFeeId        : json['lsnFeeId'] ?? '',
      lsnPay          : json['lsnPay']?.toDouble() ?? 0.0,
      payMonth        : json['payMonth'] ?? '',
      payDate         : formattedPayDate,
      bankId          : json['bankId'] ?? '',
      lessonType      : json['lessonType'],
      stuId           : json['stuId'] ?? '',
      subjectId       : json['subjectId'] ?? '',
      subjectSubId    : json['subjectSubId'] ?? '',
      stuName         : json['stuName'] ?? '',
      subjectName     : json['subjectName'] ?? '',
      subjectSubName  : json['subjectSubName'] ?? '',
      lsnMonth        : json['lsnMonth'] ?? '',
      payStyle        : json['payStyle'],
      lsnCount        : json['lsnCount'],
      lsnFee          : json['lsnFee']?.toDouble() ?? 0.0,
      ownFlg          : json['ownFlg'],
      subjectPrice    : json['subjectPrice']?.toDouble() ?? 0.0,
    );
  }
  // 添加 toJson 方法
  Map<String, dynamic> toJson() {
    return {
      'lsnPayId'        : lsnPayId,
      'lsnFeeId'        : lsnFeeId,
      'lsnPay'          : lsnPay,
      'payMonth'        : payMonth,
      'payDate'         : payDate,
      'bankId'          : bankId,
      'lessonType'      : lessonType,
      'stuId'           : stuId,
      'subjectId'       : subjectId,
      'subjectSubId'    : subjectSubId,
      'stuName'         : stuName,
      'subjectName'     : subjectName,
      'subjectSubName'  : subjectSubName,
      'lsnMonth'        : lsnMonth,
      'payStyle'        : payStyle,
      'lsnCount'        : lsnCount,
      'lsnFee'          : lsnFee,
      'ownFlg'          : ownFlg,
      'subjectPrice'    : subjectPrice,
    };
  }

}