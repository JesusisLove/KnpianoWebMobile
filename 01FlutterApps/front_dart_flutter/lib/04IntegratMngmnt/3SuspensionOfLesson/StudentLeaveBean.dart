// student.dart
class StudentLeaveBean {
  final String stuId;
  final String stuName;
  final String nikName;
  final String enterDate;
  final String quitDate;

  StudentLeaveBean({
    required this.stuId,
    required this.stuName,
    required this.nikName,
    required this.enterDate,
    required this.quitDate,
  });

// 从后台拿到的json数据转化为KnStu001Bean对象
  factory StudentLeaveBean.fromJson(Map<String, dynamic> json) {
    return StudentLeaveBean(
      stuId: json['stuId'] ?? '',
      stuName: json['stuName'] ?? '',
      nikName: json['nikName'] ?? '',
      enterDate: json['enterDate'] ?? '',
      quitDate: json['quitDate'] ?? '',
    );
  }
}
