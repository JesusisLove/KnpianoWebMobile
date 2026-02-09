// [课程排他状态功能] 2026-02-08 冲突检测模型
// 用于存储课程时间冲突的信息

/// 单个冲突课程信息
class ConflictInfo {
  final String stuId;
  final String stuName;
  final String startTime;
  final String endTime;

  ConflictInfo({
    required this.stuId,
    required this.stuName,
    required this.startTime,
    required this.endTime,
  });

  factory ConflictInfo.fromJson(Map<String, dynamic> json) {
    return ConflictInfo(
      stuId: json['stuId'] ?? '',
      stuName: json['stuName'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stuId': stuId,
      'stuName': stuName,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

/// 冲突检测结果
class ConflictCheckResult {
  final bool success;
  final bool hasConflict;
  final bool isSameStudentConflict; // 同一学生自我冲突（严格禁止）
  final List<ConflictInfo> conflicts;
  final String message;

  ConflictCheckResult({
    required this.success,
    required this.hasConflict,
    this.isSameStudentConflict = false,
    required this.conflicts,
    required this.message,
  });

  factory ConflictCheckResult.fromJson(Map<String, dynamic> json) {
    return ConflictCheckResult(
      success: json['success'] ?? false,
      hasConflict: json['hasConflict'] ?? false,
      isSameStudentConflict: json['isSameStudentConflict'] ?? false,
      conflicts: (json['conflicts'] as List<dynamic>?)
              ?.map((e) => ConflictInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }
}
