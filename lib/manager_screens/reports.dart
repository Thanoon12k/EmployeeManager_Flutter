import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/report_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerReports extends StatefulWidget {
  const ManagerReports({super.key});

  @override
  _ManagerReportsState createState() => _ManagerReportsState();
}

class _ManagerReportsState extends State<ManagerReports> {
  List<Report> _reports = [];
  List<String> _submittedReports = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      _submittedReports = prefs.getStringList('submitted_reports') ?? [];

      final response = await http.get(
        Uri.parse('https://thanoon.pythonanywhere.com/get-user-reports/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List<dynamic> reportsList = jsonResponse['reports'] ?? [];

        setState(() {
          _reports = reportsList.map((item) => Report.fromJson(item)).toList();
          _isLoading = false;
          _hasError = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _markAsSubmitted(Report report) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _submittedReports.add(report.id.toString());
    await prefs.setStringList('submitted_reports', _submittedReports);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? const Center(child: Text('حدث خطأ أثناء تحميل البيانات!'))
              : _reports.isEmpty
              ? const Center(child: Text('لا توجد تقارير لعرضها!'))
              : ListView.builder(
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  Report report = _reports[index];
                  bool isSubmitted = _submittedReports.contains(
                    report.id.toString(),
                  );
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        report.title,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      subtitle: Text(
                        report.description,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      trailing:
                          isSubmitted
                              ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                              : null,
                      onTap: () async {
                        await _markAsSubmitted(report);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ReportDetailsScreen(report: report),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
