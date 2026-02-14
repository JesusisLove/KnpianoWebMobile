// [课程表新潮版] 2026-02-13 课程详情面板（BottomSheet）
// 复用固定排课的LessonDetailSheet模式，支持调课课程显示From/To

import 'package:flutter/material.dart';
import '../Kn01L002LsnBean.dart';
import 'lesson_type_colors.dart';

/// 课程详情面板（BottomSheet）
class LessonDetailSheet extends StatelessWidget {
  final Kn01L002LsnBean lesson;
  final Function(Kn01L002LsnBean) onEdit;
  final Function(Kn01L002LsnBean) onReschedule;
  final Function(Kn01L002LsnBean)? onCancelReschedule;
  final Function(Kn01L002LsnBean) onDelete;
  final Function(Kn01L002LsnBean)? onSign;      // [课程表新潮版] 2026-02-13 签到
  final Function(Kn01L002LsnBean)? onRestore;   // [课程表新潮版] 2026-02-13 撤销签到
  final Function(Kn01L002LsnBean)? onNote;      // [课程表新潮版] 2026-02-13 备注

  const LessonDetailSheet({
    super.key,
    required this.lesson,
    required this.onEdit,
    required this.onReschedule,
    this.onCancelReschedule,
    required this.onDelete,
    this.onSign,
    this.onRestore,
    this.onNote,
  });

  /// 显示详情面板
  static Future<void> show({
    required BuildContext context,
    required Kn01L002LsnBean lesson,
    required Function(Kn01L002LsnBean) onEdit,
    required Function(Kn01L002LsnBean) onReschedule,
    Function(Kn01L002LsnBean)? onCancelReschedule,
    required Function(Kn01L002LsnBean) onDelete,
    Function(Kn01L002LsnBean)? onSign,
    Function(Kn01L002LsnBean)? onRestore,
    Function(Kn01L002LsnBean)? onNote,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LessonDetailSheet(
        lesson: lesson,
        onEdit: onEdit,
        onReschedule: onReschedule,
        onCancelReschedule: onCancelReschedule,
        onDelete: onDelete,
        onSign: onSign,
        onRestore: onRestore,
        onNote: onNote,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdjusted = lesson.lsnAdjustedDate.isNotEmpty;
    final bgColor = LessonTypeColors.getColor(lesson.lessonType, isAdjusted: isAdjusted);

    // 获取有效上课时间
    final effectiveDate = isAdjusted ? lesson.lsnAdjustedDate : lesson.schedualDate;

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
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    effectiveDate,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // 三个点菜单
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) => _handleMenuAction(context, value),
                  itemBuilder: (context) {
                    final hasBeenSigned = lesson.scanQrDate.isNotEmpty;

                    // [课程表新潮版] 2026-02-13 业务逻辑与传统版一致
                    // 已签到的课程：生米煮成熟饭，只能操作备注
                    if (hasBeenSigned) {
                      // 判断是否是当天签到的（只有当天签到才能撤销）
                      final today = DateTime.now();
                      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                      final isSignedToday = lesson.scanQrDate == todayStr;

                      return [
                        // 当天签到的可以撤销
                        if (isSignedToday && onRestore != null)
                          const PopupMenuItem(
                            value: 'restore',
                            child: Text('撤销签到', style: TextStyle(color: Colors.orange)),
                          ),
                        // 已签到只能操作备注
                        if (onNote != null)
                          const PopupMenuItem(value: 'note', child: Text('备注')),
                      ];
                    }

                    // 未签到的课程：可以签到、调课、删除、备注
                    return [
                      if (onSign != null)
                        const PopupMenuItem(
                          value: 'sign',
                          child: Text('签到', style: TextStyle(color: Colors.green)),
                        ),
                      const PopupMenuItem(value: 'reschedule', child: Text('调课')),
                      if (isAdjusted)
                        const PopupMenuItem(value: 'cancel_reschedule', child: Text('取消调课')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('删除', style: TextStyle(color: Colors.red)),
                      ),
                      if (onNote != null)
                        const PopupMenuItem(value: 'note', child: Text('备注')),
                    ];
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          // 课程卡片
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildLessonCard(bgColor, isAdjusted),
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

  Widget _buildLessonCard(Color bgColor, bool isAdjusted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bgColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 学生信息行
          Row(
            children: [
              // 颜色标识
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
                          lesson.stuName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.music_note, size: 14, color: bgColor),
                        const SizedBox(width: 4),
                        Text(lesson.subjectName, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('${lesson.classDuration}分钟', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 调课信息（仅调课课程显示）
          if (isAdjusted) ...[
            const Divider(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('原日期：', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(lesson.schedualDate, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.arrow_forward, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      const Text('调至：', style: TextStyle(color: Colors.orange, fontSize: 13)),
                      Text(
                        lesson.lsnAdjustedDate,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // 课程类型标签
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isAdjusted ? '已调课' : LessonTypeColors.getTypeName(lesson.lessonType),
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),

          // [课程表新潮版] 2026-02-13 备注内容
          if (lesson.memo != null && lesson.memo!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '备注: ${lesson.memo}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    Navigator.of(context).pop(); // 先关闭底部面板

    switch (action) {
      case 'sign':
        onSign?.call(lesson);
        break;
      case 'restore':
        onRestore?.call(lesson);
        break;
      case 'edit':
        onEdit(lesson);
        break;
      case 'reschedule':
        onReschedule(lesson);
        break;
      case 'cancel_reschedule':
        onCancelReschedule?.call(lesson);
        break;
      case 'note':
        onNote?.call(lesson);
        break;
      case 'delete':
        onDelete(lesson);
        break;
    }
  }
}
