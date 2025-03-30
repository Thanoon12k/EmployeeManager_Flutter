import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/announcement_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  _AnnouncementScreenState createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  bool _showUnreadOnly = false;
  List<Announcement> _allAnnouncements = [];
  List<Announcement> _filteredAnnouncements = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('https://thanoon.pythonanywhere.com/get-user-announcements/'),
        headers: {'Authorization': 'Token ${token ?? ""}'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        List<dynamic> announcementsList = jsonResponse['announcements'] ?? [];

        setState(() {
          _allAnnouncements =
              announcementsList
                  .map((item) => Announcement.fromJson(item))
                  .toList();
          _isLoading = false;
          _hasError = false;
        });
        await _applyFilter();
      } else {
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

  Future<void> _applyFilter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _filteredAnnouncements =
          _showUnreadOnly
              ? _allAnnouncements
                  .where(
                    (book) => !(prefs.getBool('read_${book.title}') ?? false),
                  )
                  .toList()
              : List.from(_allAnnouncements);
    });
  }

  Future<void> _markAsRead(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('read_$title', true);
    await _applyFilter();
  }

  Future<void> _markAsUnread(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('read_$title', false);
    await _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعلانات', style: TextStyle(fontFamily: 'Cairo')),
          actions: [
            Switch(
              value: _showUnreadOnly,
              onChanged: (value) async {
                setState(() {
                  _showUnreadOnly = value;
                });
                await _applyFilter();
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text(
                  _showUnreadOnly ? 'غير مقروء فقط' : 'جميع الاعلانات',
                  style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? const Center(child: Text('حدث خطأ أثناء تحميل البيانات!'))
                : _filteredAnnouncements.isEmpty
                ? const Center(child: Text('لا توجد كتب رسمية لعرضها!'))
                : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    Announcement book = _filteredAnnouncements[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          book.title,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            book.description,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AnnouncementDetailsScreen(
                                    announcement: book,
                                    markAsReadCallback:
                                        () => _markAsRead(book.title),
                                    markAsUnreadCallback:
                                        () => _markAsUnread(book.title),
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
