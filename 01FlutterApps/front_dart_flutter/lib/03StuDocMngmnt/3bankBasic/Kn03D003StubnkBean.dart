class Kn03D003StubnkBean {
  final String bankId;
  final String bankName;
  final String stuId;
  final String stuName;
  final int delFlg;

  Kn03D003StubnkBean({
    required this.bankId, 
    required this.bankName, 
    required this.stuId, 
    required this.stuName, 
    required this.delFlg,
    });

  factory Kn03D003StubnkBean.fromJson(Map<String, dynamic> json) {
    return Kn03D003StubnkBean(
      bankId: json['bankId'],
      bankName: json['bankName'],
      stuId: json['stuId'],
      stuName: json['stuName'],
      delFlg: json['delFlg'] ?? 0,
    );
  }
}
