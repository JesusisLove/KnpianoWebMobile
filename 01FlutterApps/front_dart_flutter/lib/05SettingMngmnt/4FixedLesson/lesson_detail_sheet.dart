// [固定排课新潮界面] 2026-02-12 课程详情面板（BottomSheet）

import 'package:flutter/material.dart';
import 'KnFixLsn001Bean.dart';
import 'subject_colors.dart';

/// 课程详情面板（BottomSheet）
class LessonDetailSheet extends StatelessWidget {
  final String weekDay;
  final String timeSlot; // "09:00"
  final List<KnFixLsn001Bean> lessons;
  final Function(KnFixLsn001Bean) onEdit;
  final Function(KnFixLsn001Bean) onDelete;

  const LessonDetailSheet({
    super.key,
    required this.weekDay,
    required this.timeSlot,
    required this.lessons,
    required this.onEdit,
    required this.onDelete,
  });

  /// 显示详情面板
  static Future<void> show({
    required BuildContext context,
    required String weekDay,
    required String timeSlot,
    required List<KnFixLsn001Bean> lessons,
    required Function(KnFixLsn001Bean) onEdit,
    required Function(KnFixLsn001Bean) onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LessonDetailSheet(
        weekDay: weekDay,
        timeSlot: timeSlot,
        lessons: lessons,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDayName = _getWeekDayName(weekDay);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽条
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$weekDayName $timeSlot',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${lessons.length} 节课',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          // 课程列表
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: lessons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return _buildLessonCard(context, lesson);
              },
            ),
          ),
          // 关闭按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ),
          ),
          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, KnFixLsn001Bean lesson) {
    final bgColor = SubjectColors.getColor(lesson.subjectName);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // 科目颜色标识
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // 信息区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      lesson.studentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.music_note, size: 14, color: bgColor),
                    const SizedBox(width: 4),
                    Text(
                      lesson.subjectName,
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${lesson.classDuration}分钟',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 操作按钮
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
              onEdit(lesson);
            },
            tooltip: '编辑',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: () {
              Navigator.of(context).pop();
              onDelete(lesson);
            },
            tooltip: '删除',
          ),
        ],
      ),
    );
  }

  String _getWeekDayName(String weekDay) {
    const names = {
      'Mon': '周一',
      'Tue': '周二',
      'Wed': '周三',
      'Thu': '周四',
      'Fri': '周五',
      'Sat': '周六',
      'Sun': '周日',
    };
    return names[weekDay] ?? weekDay;
  }
}
