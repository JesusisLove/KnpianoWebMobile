import 'package:flutter/material.dart';

class ScheduleForm extends StatefulWidget {
  @override
  _ScheduleFormState createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();

  String? selectedStudent;
  String? selectedSubject;
  String? selectedDay;
  String? selectedHour;
  String? selectedMinute;

  List<String> students = ['Alice', 'Bob', 'Charlie'];
  Map<String, List<String>> subjects = {
    'Alice': ['Math', 'Science'],
    'Bob': ['History', 'Biology'],
    'Charlie': ['Math', 'Geography'],
  };
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  // List<String> hours = List.generate(24, (index) => index.toString().padLeft(2, '0'));
  // 只要从早08点到22点之间到时间 
  List<String> hours = List.generate(15, (index) => (index + 8).toString().padLeft(2, '0'));

  List<String> minutes = ['00', '15', '30', '45'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("学生固定排课")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: selectedStudent,
                hint: const Text('学生姓名'),
                onChanged: (newValue) {
                  setState(() {
                    selectedStudent = newValue;
                    selectedSubject = null;  // Reset subject when student changes
                  });
                },
                validator: (value) => value == null ? '请选择要排课的学生' : null,
                items: students.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              if (selectedStudent != null) ...[
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  hint: const Text('科目名称'),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSubject = newValue;
                    });
                  },
                  validator: (value) => value == null ? '请选择要排课的科目' : null,
                  items: subjects[selectedStudent]!.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
              DropdownButtonFormField<String>(
                value: selectedDay,
                hint: const Text('固定星期几'),
                onChanged: (newValue) {
                  setState(() {
                    selectedDay = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择星期几' : null,
                items: days.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                value: selectedHour,
                hint: const Text('固定在几点'),
                onChanged: (newValue) {
                  setState(() {
                    selectedHour = newValue;
                  });
                },
                validator: (value) => value == null ? '请选择几点' : null,
                items: hours.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                value: selectedMinute,
                hint: const Text('固定在几分'),
                onChanged: (newValue) {
                  setState(() {
                    selectedMinute = newValue;
                  });
                },
                // validator: (value) => value == null ? 'Minute is required' : null,
                validator: (value) => value == null ? '请选择几分' : null,
                items: minutes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('保存'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Submission Successful'),
          content: Text('Schedule saved for $selectedStudent'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
   