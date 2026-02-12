// [固定排课新潮界面] 2026-02-12 网格单元格组件

import 'package:flutter/material.dart';
import 'KnFixLsn001Bean.dart';
import 'subject_colors.dart';

/// 已占用格子组件（单人）
class SingleLessonCell extends StatelessWidget {
  final KnFixLsn001Bean lesson;
  final VoidCallback onTap;

  const SingleLessonCell({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = SubjectColors.getColor(lesson.subjectName);
    final textColor = SubjectColors.getTextColor(lesson.subjectName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.studentName,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              lesson.subjectName,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 9,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// 已占用格子组件（多人 2-3人）
class MultiLessonCellSmall extends StatelessWidget {
  final List<KnFixLsn001Bean> lessons;
  final VoidCallback onTap;

  const MultiLessonCellSmall({
    super.key,
    required this.lessons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 使用第一个课程的科目颜色作为主色
    final bgColor = SubjectColors.getColor(lessons.first.subjectName);
    final textColor = SubjectColors.getTextColor(lessons.first.subjectName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示所有学生名字（用逗号分隔）
            Text(
              lessons.map((l) => l.studentName).join(', '),
              style: TextStyle(
                color: textColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            // 显示科目名
            Text(
              lessons.first.subjectName,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 8,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// 已占用格子组件（多人 4人及以上）
class MultiLessonCellLarge extends StatelessWidget {
  final List<KnFixLsn001Bean> lessons;
  final VoidCallback onTap;

  const MultiLessonCellLarge({
    super.key,
    required this.lessons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = SubjectColors.getColor(lessons.first.subjectName);
    final textColor = SubjectColors.getTextColor(lessons.first.subjectName);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lessons.first.subjectName,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${lessons.length}人',
                style: TextStyle(
                  color: textColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
