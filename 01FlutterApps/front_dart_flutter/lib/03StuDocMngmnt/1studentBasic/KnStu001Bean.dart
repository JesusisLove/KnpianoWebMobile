// student.dart
class KnStu001Bean {
  final String stuId;
  final String stuName;
  final String nikName;
  final int gender;
  final String birthday;
  final String tel1;
  final String tel2;
  final String tel3;
  final String tel4;
  final String address;
  final String postCode;
  final String introducer;
  final int delFlg;

  KnStu001Bean({
    required this.stuId,
    required this.stuName,
    required this.nikName,
    required this.gender,
    required this.birthday,
    required this.tel1,
    required this.tel2,
    required this.tel3,
    required this.tel4,
    required this.address,
    required this.postCode,
    required this.introducer,
    required this.delFlg,
  });

// 从后台拿到的json数据转化为KnStu001Bean对象
  factory KnStu001Bean.fromJson(Map<String, dynamic> json) {
    return KnStu001Bean(
      stuId: json['stuId'] ?? '',
      stuName: json['stuName'] ?? '',
      nikName: json['nikName'] ?? '',
      gender: json['gender'] ?? 0,
      birthday: json['birthday'] ?? '',
      tel1: json['tel1'] ?? '',
      tel2: json['tel2'] ?? '',
      tel3: json['tel3'] ?? '',
      tel4: json['tel4'] ?? '',
      address: json['address'] ?? '',
      postCode: json['postCode'] ?? '',
      introducer: json['introducer'] ?? '',
      delFlg: json['delFlg'] ?? 0,
    );
  }
}
