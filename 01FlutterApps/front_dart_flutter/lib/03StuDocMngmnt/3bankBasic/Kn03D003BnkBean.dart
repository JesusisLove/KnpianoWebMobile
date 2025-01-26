class Kn03D003BnkBean {
  final String bankId;
  final String bankName;
  final int delFlg;

  Kn03D003BnkBean( {
    required this.bankId, 
    required this.bankName, 
    required this.delFlg,
    });

  factory Kn03D003BnkBean.fromJson(Map<String, dynamic> json) {
    return Kn03D003BnkBean(
      bankId: json['bankId'],
      bankName: json['bankName'],
      delFlg: json['delFlg'] ?? 0,
    );
  }
}
