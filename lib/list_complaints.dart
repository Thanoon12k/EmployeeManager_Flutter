import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

class ListComplaintsScreen extends StatefulWidget {
  const ListComplaintsScreen({super.key});

  @override
  _ListComplaintsScreenState createState() => _ListComplaintsScreenState();
}

class _ListComplaintsScreenState extends State<ListComplaintsScreen> {
  List<dynamic> _complaints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://thanoon.pythonanywhere.com/get-complaints-list/'),
        headers: {
          'Authorization': 'Token efdd6b90521dc82481f734b36577a2f06bd55d5a',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _complaints = jsonResponse['complaints'];
          _isLoading = false;
        });
      } else {
        print('Failed to load complaints: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openWebPage() async {
    final Uri uri = Uri.parse(
      'https://thanoon.pythonanywhere.com/admin/mainapp/complaint/',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      print(
        'Could not launch https://thanoon.pythonanywhere.com/admin/mainapp/complaint/: $e  ',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشكاوى', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
            onPressed: _fetchComplaints,
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings), // Admin page icon
            tooltip: 'لوحة الإدارة',
            onPressed: () {
              _openWebPage();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'جارٍ تحميل الشكاوى...',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              )
              : _complaints.isEmpty
              ? const Center(
                child: Text(
                  'لا توجد شكاوى متاحة',
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: _complaints.length,
                itemBuilder: (context, index) {
                  final complaint = _complaints[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نص الشكوى:',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            complaint['text'],
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المشتكي: ${complaint['complainant__username']}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'المشتكى عليه: ${complaint['respondent__username']}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      complaint['is_resolved']
                                          ? Colors.green.withOpacity(0.8)
                                          : Colors.orange.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  complaint['is_resolved']
                                      ? 'تم الحل'
                                      : 'معلّق',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
