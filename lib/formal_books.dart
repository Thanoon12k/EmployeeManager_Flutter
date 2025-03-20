import 'package:emp_manager_front_end/classes.dart';
import 'package:emp_manager_front_end/formal_book_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FormalBooksScreen extends StatefulWidget {
  const FormalBooksScreen({super.key});

  @override
  _FormalBooksScreenState createState() => _FormalBooksScreenState();
}

class _FormalBooksScreenState extends State<FormalBooksScreen> {
  late Future<List<FormalBook>> _formalBooks;
  bool _showUnreadOnly = false;
  List<FormalBook> _allBooks = [];
  List<FormalBook> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _formalBooks = fetchFormalBooks();
  }

  Future<List<FormalBook>> fetchFormalBooks() async {
    final response = await http.get(
      Uri.parse('https://thanoon.pythonanywhere.com/api/formalbooks/'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('thanoon:123'))}',
      },
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      _allBooks =
          jsonResponse.map((book) => FormalBook.fromJson(book)).toList();
      await _applyFilter();
      return _allBooks;
    } else {
      throw Exception('Error loading formal books');
    }
  }

  Future<void> _applyFilter() async {
    if (_showUnreadOnly) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _filteredBooks =
          _allBooks.where((book) {
            bool isRead = prefs.getBool('read_${book.title}') ?? false;
            return !isRead;
          }).toList();
    } else {
      _filteredBooks = _allBooks;
    }
    setState(() {});
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Formal Books'),
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
                _showUnreadOnly ? 'Unread Only' : 'All Books',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<FormalBook>>(
        future: _formalBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading formal books'));
          } else {
            return ListView.builder(
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                FormalBook book = _filteredBooks[index];
                return ListTile(
                  title: Text(book.title),
                  subtitle: Text(book.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FormalBookDetailScreen(
                              book: book,
                              markAsReadCallback: () => _markAsRead(book.title),
                              markAsUnreadCallback:
                                  () => _markAsUnread(book.title),
                            ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
