class KnSub001Bean {
  final String subjectId;
  final String subjectName;
  final int delFlg;

  KnSub001Bean( {
    required this.subjectId, 
    required this.subjectName, 
    required this.delFlg,
    });

  factory KnSub001Bean.fromJson(Map<String, dynamic> json) {
    return KnSub001Bean(
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      delFlg: json['delFlg'] ?? 0,
    );
  }
}
