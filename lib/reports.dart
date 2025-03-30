import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/report_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  /// Fetch reports from the API and update the UI
  Future<void> _fetchReports() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token'); // Retrieve token
      _submittedReports =
          prefs.getStringList('submitted_reports') ??
          []; // Fetch submitted reports

      if (token == null || token.isEmpty) {
        throw Exception("Token is missing in SharedPreferences.");
      }

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
      print('Error fetching reports: $e');
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
      return false; // Default to false if an error occurs
    }
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
