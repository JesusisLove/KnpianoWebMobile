import 'package:flutter/material.dart';

class AddCourseDialog extends StatefulWidget {
  const AddCourseDialog({super.key, this.scheduleDate, this.scheduleTime});
  final String? scheduleDate;
  final String? scheduleTime;
  @override
  // ignore: library_private_types_in_public_api
  _AddCourseDialogState createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  String? selectedStudent;
  String? selectedSubject;
  String? subjectLevel;
  String courseType = '课结算';
  String? courseDuration;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '添加课程:${widget.scheduleDate} ${widget.scheduleTime}', 
                  style: const TextStyle(fontSize: 14, 
                  fontWeight: FontWeight.bold)
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 0), // 减小此处的间距

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '学生姓名'),
              value: selectedStudent,
              onChanged: (value) => setState(() => selectedStudent = value),
              items: ['学生1', '学生2', '学生3'].map((name) => DropdownMenuItem(
                value: name,
                child: Text(name),
              )).toList(),
            ),
            const SizedBox(height: 0), // 减小此处的间距

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '科目名称'),
              value: selectedSubject,
              onChanged: (value) => setState(() => selectedSubject = value),
              items: ['数学', '英语', '物理'].map((subject) => DropdownMenuItem(
                value: subject,
                child: Text(subject),
              )).toList(),
            ),
            const SizedBox(height: 0), // 减小此处的间距

            TextFormField(
              decoration: const InputDecoration(labelText: '科目级别名称'),
              onChanged: (value) => setState(() => subjectLevel = value),
              readOnly: true,
            ),
            const SizedBox(height: 16), // 减小此处的间距

            
            const Text('上课种别', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // Radio按钮纵向排列
            // Column(
            //   children: ['课结算', '月计划', '月加课'].map((type) => 
            //     Column(
            //       children: [
            //         Row(
            //           children: [
            //             Radio<String>(
            //               value: type,
            //               groupValue: courseType,
            //               onChanged: (value) => setState(() => courseType = value!),
            //             ),
            //             Text(type),
            //           ],
            //         ),
            //         const SizedBox(height: 1), // 这里控制行间距，可以根据需要调整
            //       ],
            //     )
            //   ).toList(),
            // ),

            // Radio按钮纵向排列
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['课结算', '月计划', '月加课'].map((type) => 
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8, // 保持radio按钮的缩小比例
                      child: Radio<String>(
                        value: type,
                        groupValue: courseType,
                        onChanged: (value) => setState(() => courseType = value!),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 减少radio按钮的点击区域
                      ),
                    ),
                    const SizedBox(width: 0.1), // 添加很小的间距
                    Text(
                      type,
                      style: const TextStyle(fontSize: 12.0),
                    ),
                  ],
                )
              ).toList(),
            ),
            const SizedBox(height: 0), // 减小此处的间距

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '上课时长'),
              value: courseDuration,
              onChanged: (value) => setState(() => courseDuration = value),
              items: ['1小时', '1.5小时', '2小时'].map((duration) => DropdownMenuItem(
                value: duration,
                child: Text(duration),
              )).toList(),
            ),
            const SizedBox(height: 16), // 稍微保留一些底部间距
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('保存'),
                onPressed: () {
                  // 在这里处理保存逻辑
                  print('保存课程');
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}