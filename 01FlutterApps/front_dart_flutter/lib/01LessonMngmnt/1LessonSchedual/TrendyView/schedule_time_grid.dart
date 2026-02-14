// [课程表新潮版] 2026-02-13 时间网格组件
// 显示08:00-21:00的15分钟间隔网格，复用固定排课的网格逻辑

import 'package:flutter/material.dart';
import '../Kn01L002LsnBean.dart';
import 'schedule_lesson_card.dart';

/// 时间网格组件
class ScheduleTimeGrid extends StatefulWidget {
  final DateTime weekStart;
  final List<Kn01L002LsnBean> lessons;
  final double timeColumnWidth;
  final Function(DateTime date, int hour, int minute)? onEmptyCellTap;
  final Function(Kn01L002LsnBean lesson)? onLessonTap;

  const ScheduleTimeGrid({
    super.key,
    required this.weekStart,
    required this.lessons,
    this.timeColumnWidth = 50.0,
    this.onEmptyCellTap,
    this.onLessonTap,
  });

  // 时间配置（与固定排课一致）
  static const int startHour = 8;
  static const int endHour = 21;
  static const int intervalMinutes = 15;
  static const double cellHeight = 24.0;

  @override
  State<ScheduleTimeGrid> createState() => _ScheduleTimeGridState();
}

class _ScheduleTimeGridState extends State<ScheduleTimeGrid> {
  // 选中单元格的位置
  int? _selectedDayIndex;
  int? _selectedSlotIndex;

  // [课程表新潮版] 2026-02-14 Excel风格：按下时暂存待执行的动作
  Kn01L002LsnBean? _pendingLessonTap;
  // 待执行的空单元格点击信息
  DateTime? _pendingEmptyDate;
  int? _pendingEmptyHour;
  int? _pendingEmptyMinute;

  /// 获取时间槽列表
  List<String> get timeSlots {
    final slots = <String>[];
    for (int h = ScheduleTimeGrid.startHour; h < ScheduleTimeGrid.endHour; h++) {
      for (int m = 0; m < 60; m += ScheduleTimeGrid.intervalMinutes) {
        slots.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      }
    }
    return slots;
  }

  /// 按(日期, 开始时间)分组课程
  Map<String, List<Kn01L002LsnBean>> _groupLessons() {
    final grouped = <String, List<Kn01L002LsnBean>>{};

    for (final lesson in widget.lessons) {
      // 获取有效日期（调课日期优先）
      final effectiveDateStr = lesson.lsnAdjustedDate.isNotEmpty
          ? lesson.lsnAdjustedDate
          : lesson.schedualDate;

      if (effectiveDateStr.isEmpty) continue;

      // 解析日期和时间
      final effectiveDate = _parseDateTime(effectiveDateStr);
      if (effectiveDate == null) continue;

      // 检查是否在当前周
      final dayIndex = _getDayIndex(effectiveDate);
      if (dayIndex < 0 || dayIndex > 6) continue;

      // 获取时间槽
      final timeStr = '${effectiveDate.hour.toString().padLeft(2, '0')}:${effectiveDate.minute.toString().padLeft(2, '0')}';

      final key = '${dayIndex}_$timeStr';
      grouped.putIfAbsent(key, () => []).add(lesson);
    }

    return grouped;
  }

  /// 解析日期时间字符串
  DateTime? _parseDateTime(String dateStr) {
    try {
      // 尝试解析 "yyyy-MM-dd HH:mm" 格式
      return DateTime.parse(dateStr.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  /// 获取日期在当前周的索引（0=周一, 6=周日）
  int _getDayIndex(DateTime date) {
    final startOfWeek = DateTime(widget.weekStart.year, widget.weekStart.month, widget.weekStart.day);
    final diff = date.difference(startOfWeek).inDays;
    if (diff >= 0 && diff <= 6) {
      return diff;
    }
    return -1;
  }

  /// 获取时间槽索引
  int _getSlotIndex(int hour, int minute) {
    final slotMinute = (minute ~/ ScheduleTimeGrid.intervalMinutes) * ScheduleTimeGrid.intervalMinutes;
    return ((hour - ScheduleTimeGrid.startHour) * 60 + slotMinute) ~/ ScheduleTimeGrid.intervalMinutes;
  }

  /// 计算课程占用的格子数
  int _getCellSpan(int classDuration) {
    return (classDuration / ScheduleTimeGrid.intervalMinutes).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final groupedLessons = _groupLessons();
    final slots = timeSlots;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - widget.timeColumnWidth) / 7;
        final gridHeight = slots.length * ScheduleTimeGrid.cellHeight;

        return SingleChildScrollView(
          child: SizedBox(
            height: gridHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 时间列
                _buildTimeColumn(slots),
                // 网格主体
                Expanded(
                  child: Stack(
                    children: [
                      // 底层：网格线
                      _buildGridLines(slots, columnWidth),
                      // 上层：课程色块
                      ..._buildLessonBlocks(groupedLessons, columnWidth),
                      // 空闲格子点击区域
                      ..._buildEmptyCellTapAreas(slots, groupedLessons, columnWidth),
                      // 选中边框
                      if (_selectedDayIndex != null && _selectedSlotIndex != null)
                        _buildSelectionBorder(columnWidth),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建时间列
  Widget _buildTimeColumn(List<String> slots) {
    return SizedBox(
      width: widget.timeColumnWidth,
      child: Column(
        children: slots.map((slot) {
          final parts = slot.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          // 重要时间点（12:00中午、18:00傍晚）
          final isImportantTime = (hour == 12 || hour == 18) && minute == 0;

          // 整点显示完整时间，非整点只显示分钟
          String displayText;
          if (minute == 0) {
            displayText = slot;
          } else {
            displayText = minute.toString().padLeft(2, '0');
          }

          final textStyle = TextStyle(
            fontSize: isImportantTime ? 12 : 10,
            fontWeight: isImportantTime ? FontWeight.bold : FontWeight.normal,
            color: isImportantTime ? Colors.grey.shade800 : Colors.grey.shade600,
          );

          return Container(
            height: ScheduleTimeGrid.cellHeight,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 4),
            child: Transform.translate(
              offset: Offset(0, isImportantTime ? -8 : -7),
              child: Text(displayText, style: textStyle),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建网格线
  Widget _buildGridLines(List<String> slots, double columnWidth) {
    return Column(
      children: slots.asMap().entries.map((entry) {
        final index = entry.key;
        final slot = slots[index];
        final parts = slot.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        // 线条粗细
        final isImportantHourLine = minute == 0 && (hour == 12 || hour == 18);
        final isHourLine = minute == 0;
        double lineWidth;
        Color lineColor;
        if (isImportantHourLine) {
          lineWidth = 2.0;
          lineColor = Colors.grey.shade500;
        } else if (isHourLine) {
          lineWidth = 1.0;
          lineColor = Colors.grey.shade400;
        } else {
          lineWidth = 0.5;
          lineColor = Colors.grey.shade200;
        }

        return Container(
          height: ScheduleTimeGrid.cellHeight,
          decoration: BoxDecoration(
            border: Border(
              top: index == 0 ? BorderSide.none : BorderSide(color: lineColor, width: lineWidth),
            ),
          ),
          child: Row(
            children: List.generate(7, (dayIndex) {
              return Container(
                width: columnWidth,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  ),
                ),
              );
            }),
          ),
        );
      }).toList(),
    );
  }

  /// 构建课程色块
  List<Widget> _buildLessonBlocks(
    Map<String, List<Kn01L002LsnBean>> groupedLessons,
    double columnWidth,
  ) {
    final blocks = <Widget>[];

    groupedLessons.forEach((key, lessonList) {
      final lesson = lessonList.first;

      // 解析key获取dayIndex和时间
      final parts = key.split('_');
      final dayIndex = int.parse(parts[0]);
      final timeParts = parts[1].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final slotIndex = _getSlotIndex(hour, minute);
      final cellSpan = _getCellSpan(lesson.classDuration > 0 ? lesson.classDuration : 45);

      if (slotIndex < 0) return;

      final left = dayIndex * columnWidth + 1;
      final top = slotIndex * ScheduleTimeGrid.cellHeight;
      final width = columnWidth - 2;

      // 判断是否是调课
      final isAdjusted = lesson.lsnAdjustedDate.isNotEmpty;
      // [课程表新潮版] 2026-02-13 判断是否已签到
      final isSigned = lesson.scanQrDate.isNotEmpty;

      blocks.add(
        Positioned(
          left: left,
          top: top,
          width: width,
          child: GestureDetector(
            // [课程表新潮版] 2026-02-14 Excel风格：按下显示光标，松开才执行动作
            onTapDown: (_) {
              _selectCell(dayIndex, slotIndex);
              _pendingLessonTap = lesson;
            },
            onTapUp: (_) {
              if (_pendingLessonTap != null) {
                widget.onLessonTap?.call(_pendingLessonTap!);
                _pendingLessonTap = null;
              }
            },
            onTapCancel: () {
              _pendingLessonTap = null;
            },
            child: ScheduleLessonCard(
              stuName: lesson.stuName,
              subjectName: lesson.subjectName,
              lessonType: lesson.lessonType,
              isAdjusted: isAdjusted,
              isSigned: isSigned,
              memo: lesson.memo,  // [课程表新潮版] 2026-02-13 备注
              cellSpan: cellSpan,
            ),
          ),
        ),
      );
    });

    return blocks;
  }

  /// 构建空闲格子点击区域
  List<Widget> _buildEmptyCellTapAreas(
    List<String> slots,
    Map<String, List<Kn01L002LsnBean>> groupedLessons,
    double columnWidth,
  ) {
    // 记录已被课程占用的格子
    final occupiedCells = <String>{};
    groupedLessons.forEach((key, lessonList) {
      final lesson = lessonList.first;
      final parts = key.split('_');
      final dayIndex = int.parse(parts[0]);
      final timeParts = parts[1].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final slotIndex = _getSlotIndex(hour, minute);
      final cellSpan = _getCellSpan(lesson.classDuration > 0 ? lesson.classDuration : 45);

      if (slotIndex >= 0) {
        for (int i = 0; i < cellSpan; i++) {
          occupiedCells.add('${dayIndex}_${slotIndex + i}');
        }
      }
    });

    final tapAreas = <Widget>[];
    for (int slotIndex = 0; slotIndex < slots.length; slotIndex++) {
      final slot = slots[slotIndex];
      final parts = slot.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
        final cellKey = '${dayIndex}_$slotIndex';
        if (occupiedCells.contains(cellKey)) continue;

        final currentDayIndex = dayIndex;
        final currentSlotIndex = slotIndex;

        // [课程表新潮版] 2026-02-14 Excel风格：按下显示光标，松开才执行动作
        final tapDate = widget.weekStart.add(Duration(days: currentDayIndex));
        final tapHour = hour;
        final tapMinute = minute;

        tapAreas.add(
          Positioned(
            left: dayIndex * columnWidth,
            top: slotIndex * ScheduleTimeGrid.cellHeight,
            width: columnWidth,
            height: ScheduleTimeGrid.cellHeight,
            child: GestureDetector(
              onTapDown: (_) {
                _selectCell(currentDayIndex, currentSlotIndex);
                _pendingEmptyDate = tapDate;
                _pendingEmptyHour = tapHour;
                _pendingEmptyMinute = tapMinute;
              },
              onTapUp: (_) {
                if (_pendingEmptyDate != null) {
                  widget.onEmptyCellTap?.call(
                    _pendingEmptyDate!,
                    _pendingEmptyHour!,
                    _pendingEmptyMinute!,
                  );
                  _pendingEmptyDate = null;
                  _pendingEmptyHour = null;
                  _pendingEmptyMinute = null;
                }
              },
              onTapCancel: () {
                _pendingEmptyDate = null;
                _pendingEmptyHour = null;
                _pendingEmptyMinute = null;
              },
              behavior: HitTestBehavior.opaque,
              child: Container(),
            ),
          ),
        );
      }
    }
    return tapAreas;
  }

  /// 选中单元格
  void _selectCell(int dayIndex, int slotIndex) {
    setState(() {
      _selectedDayIndex = dayIndex;
      _selectedSlotIndex = slotIndex;
    });
  }

  /// 构建选中边框
  Widget _buildSelectionBorder(double columnWidth) {
    return Positioned(
      left: _selectedDayIndex! * columnWidth,
      top: _selectedSlotIndex! * ScheduleTimeGrid.cellHeight,
      width: columnWidth,
      height: ScheduleTimeGrid.cellHeight,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.green, width: 2.0),
          ),
        ),
      ),
    );
  }
}
