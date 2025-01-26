// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

class Kn05S003SubjectEdabnBean {
  final String subjectSubId;
  final String subjectSubName;
  final String subjectId;
  final String subjectName;
  final double  subjectPrice; // 注意不用Float，全部都用double
  final int    delFlg;

  Kn05S003SubjectEdabnBean( {
    required this.subjectSubId,
    required this.subjectSubName,
    required this.subjectId, 
    required this.subjectName, 
    required this.subjectPrice,
    required this.delFlg,
    });

  factory Kn05S003SubjectEdabnBean.fromJson(Map<String, dynamic> json) {
    return Kn05S003SubjectEdabnBean(
      subjectSubId: json['subjectSubId'],
      subjectSubName: json['subjectSubName'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectPrice: json['subjectPrice'].toDouble(),
      delFlg: json['delFlg'] ?? 0,
    );
  }
}
