import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/report_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Report> _reports = [];
  List<String> _submittedReports = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserManager();
    _fetchReports();
    _checkSubmittedReports();
  }


  /// Check if the user is a manager
  Future<void> _checkIfUserManager() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isManager = prefs.getBool('is_manager') ?? false;
      _isManager = true;
    });
  }

  /// Fetch submitted reports from SharedPreferences
  Future<void> _checkSubmittedReports() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _submittedReports = prefs.getStringList('submitted_reports') ?? [];
  }

  /// Fetch reports from the API and update the UI
  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing in SharedPreferences.");
      }

      final response = await http.get(
        Uri.parse('https://thanoon.pythonanywhere.com/get-user-reports/'),
        headers: {'Authorization': 'Token $token'},
      );
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> reportsList = jsonResponse['reports'] ?? [];

        setState(() {
          _reports = reportsList.map((item) => Report.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  /// Check if a report is submitted
  Future<bool> _checkIfSubmitted(Report report) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> submittedReports =
          prefs.getStringList('submitted_reports') ?? [];
      return submittedReports.contains(report.id.toString());
    } catch (e) {
      print("Error checking if report is submitted: $e");
      return false;
    }
  }

  /// Open a webpage in the browser
  Future<void> _openWebPage(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      log('Could not launch $url: $e', name: 'ReportScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          if (_isManager)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'إضافة تقرير جديد',
              onPressed: () {
                _openWebPage(
                  'https://thanoon.pythonanywhere.com/admin/mainapp/report/add/',
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: _fetchReports,
          ),
        ],
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
                  return FutureBuilder<bool>(
                    future: _checkIfSubmitted(report),
                    builder: (context, snapshot) {
                      bool isSubmitted = snapshot.data ?? false;
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isManager)
                                IconButton(
                                  icon: const Icon(Icons.bar_chart),
                                  tooltip: 'عرض الإحصائيات',
                                  onPressed: () {
                                    _openWebPage(
                                      'https://thanoon.pythonanywhere.com/?report_id=${report.id}',
                                    );
                                    _fetchReports();
                                  },
                                ),
                              if (isSubmitted)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                          onTap: () {
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
                  );
                },
              ),
    );
  }
}
