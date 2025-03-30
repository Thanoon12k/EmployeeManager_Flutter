import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:employee_manager_app/classes.dart';

class ReportDetailsScreen extends StatefulWidget {
  final Report report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final Map<int, dynamic> _answers = {}; // لتخزين إجابات المستخدم
  bool _isSubmitting = false;
  bool _isSubmitted = false; // حالة التأكد من إرسال التقرير مسبقًا

  @override
  void initState() {
    super.initState();
    _checkIfSubmitted();
  }

  Future<void> _checkIfSubmitted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("shhreed : ${prefs.getStringList('submitted_reports')}");
    // استرجاع قائمة التقارير المرسلة مسبقًا
    final List<String> submittedReports =
        prefs.getStringList('submitted_reports') ?? [];

    if (submittedReports.contains(widget.report.id.toString())) {
      setState(() {
        _isSubmitted = true;
      });
    }
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('https://thanoon.pythonanywhere.com/submit-report/'),
      headers: {
        'Authorization': 'Token ${token ?? ""}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "report_id": widget.report.id,
        "answers":
            _answers.entries.map((entry) {
              return {
                "question_id": entry.key,
                if (entry.value is String) "text_answer": entry.value,
                if (entry.value is bool) "true_false_answer": entry.value,
                if (entry.value is int)
                  "selected_option": entry.value.toString(),
              };
            }).toList(),
      }),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال التقرير بنجاح!')));
      Navigator.pop(context);

      final List<String> submittedReports =
          prefs.getStringList('submitted_reports') ?? [];
      submittedReports.add(widget.report.id.toString());
      await prefs.setStringList('submitted_reports', submittedReports);

      setState(() {
        _isSubmitted = true;
      });
    } else if (response.statusCode == 208) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لقد قمت بإرسال هذا التقرير مسبقًا!'),
          backgroundColor: Colors.blue,
        ),
      );

      setState(() {
        _isSubmitted = true; // منع التعديل إذا كان التقرير مرسل مسبقًا
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء الإرسال! ${response.statusCode} ${response.body}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.report.title,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              widget.report.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ...widget.report.questions.map((q) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.questionText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (q.questionType == 'text')
                        TextField(
                          onChanged: (value) => _answers[q.id] = value,
                          decoration: const InputDecoration(
                            hintText: 'أدخل إجابتك هنا',
                          ),
                          enabled:
                              !_isSubmitted, // تعطيل الإدخال إذا كان التقرير مرسل مسبقًا
                        ),
                      if (q.questionType == 'true_false')
                        SwitchListTile(
                          title: const Text('نعم / لا'),
                          value: _answers[q.id] ?? false,
                          onChanged:
                              _isSubmitted
                                  ? null
                                  : (value) =>
                                      setState(() => _answers[q.id] = value),
                        ),
                      if (q.questionType == 'multiple_choice') ...[
                        if (q.option1 != null)
                          RadioListTile<int>(
                            title: Text(q.option1!),
                            value: 1,
                            groupValue: _answers[q.id],
                            onChanged:
                                _isSubmitted
                                    ? null
                                    : (value) =>
                                        setState(() => _answers[q.id] = value),
                          ),
                        if (q.option2 != null)
                          RadioListTile<int>(
                            title: Text(q.option2!),
                            value: 2,
                            groupValue: _answers[q.id],
                            onChanged:
                                _isSubmitted
                                    ? null
                                    : (value) =>
                                        setState(() => _answers[q.id] = value),
                          ),
                        if (q.option3 != null)
                          RadioListTile<int>(
                            title: Text(q.option3!),
                            value: 3,
                            groupValue: _answers[q.id],
                            onChanged:
                                _isSubmitted
                                    ? null
                                    : (value) =>
                                        setState(() => _answers[q.id] = value),
                          ),
                        if (q.option4 != null)
                          RadioListTile<int>(
                            title: Text(q.option4!),
                            value: 4,
                            groupValue: _answers[q.id],
                            onChanged:
                                _isSubmitted
                                    ? null
                                    : (value) =>
                                        setState(() => _answers[q.id] = value),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            if (!_isSubmitted)
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('إرسال'),
              )
            else
              const Center(
                child: Text(
                  'لقد تم إرسال هذا التقرير مسبقًا ✅',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
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
