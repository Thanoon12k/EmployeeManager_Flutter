import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'classes.dart'; // Import the above classes

class ReportDetailsScreen extends StatefulWidget {
  final Report report;

  const ReportDetailsScreen({Key? key, required this.report}) : super(key: key);

  @override
  _ReportDetailsScreenState createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final Map<int, dynamic> _answers = {}; // Stores user answers
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _checkIfSubmitted();
  }

  Future<void> _checkIfSubmitted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
        "report_title": widget.report.title,
        "answers":
            widget.report.questions.map((question) {
              return {
                "question_title": question.questionText,
                "answer_data": _answers[question.id]?.toString() ?? "",
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

      final List<String> submittedReports =
          prefs.getStringList('submitted_reports') ?? [];
      submittedReports.add(widget.report.id.toString());
      await prefs.setStringList('submitted_reports', submittedReports);
      setState(() {
        _isSubmitted = true;
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

  Widget _buildQuestionCard(Question question) {
    if (question.questionType == 'TEXT') {
      return TextField(
        onChanged: (value) => _answers[question.id] = value,
        decoration: const InputDecoration(hintText: 'أدخل إجابتك هنا'),
        enabled: !_isSubmitted,
      );
    } else if (question.questionType == 'T/F') {
      return SwitchListTile(
        title: const Text('نعم / لا'),
        value: _answers[question.id] ?? false,
        onChanged:
            _isSubmitted
                ? null
                : (value) => setState(() => _answers[question.id] = value),
      );
    } else if (question.questionType == 'multiple_choice' &&
        question.options != null) {
      return Column(
        children:
            question.options!.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _answers[question.id],
                onChanged:
                    _isSubmitted
                        ? null
                        : (value) =>
                            setState(() => _answers[question.id] = value),
              );
            }).toList(),
      );
    } else {
      return const Text('نوع السؤال غير مدعوم أو خيارات فارغة');
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
        child:
            widget.report.questions.isEmpty
                ? const Center(
                  child: Text('لا توجد أسئلة لعرضها في هذا التقرير'),
                )
                : ListView(
                  children: [
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildQuestionCard(q),
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
