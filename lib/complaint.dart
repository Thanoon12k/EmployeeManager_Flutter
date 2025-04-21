import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({Key? key}) : super(key: key);

  @override
  _AddComplaintScreenState createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedRespondent;
  bool _isSubmitting = false;
  List<String> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('https://thanoon.pythonanywhere.com/get-users-list/'),
      headers: {'Authorization': 'Token ${token ?? ""}'},
    );
    print("respoines status cod  : ${response.statusCode}");
    print("got users :${response.body}");
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _users =
            (data['users'] as List)
                .map((user) => user['username'].toString())
                .toList();
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (_textController.text.isEmpty || _selectedRespondent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    print(
      "data to submitted :text ${_textController.text} ,user   $_selectedRespondent",
    );
    final response = await http.post(
      Uri.parse('https://thanoon.pythonanywhere.com/submit-complaint/'),
      headers: {
        'Authorization': 'Token ${token ?? ""}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "text": _textController.text,
        "respondent": _selectedRespondent,
      }),
    );

    setState(() {
      _isSubmitting = false;
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال الشكوى بنجاح!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الإرسال! ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقديم شكوى', style: TextStyle(fontFamily: 'Cairo')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedRespondent,
              decoration: const InputDecoration(
                labelText: 'المشتكى عليه',
                border: OutlineInputBorder(),
              ),
              items:
                  _users.map((String user) {
                    return DropdownMenuItem<String>(
                      value: user,
                      child: Text(user),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRespondent = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'نص الشكوى',
                border: OutlineInputBorder(),
                hintText: 'اكتب نص الشكوى هنا...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitComplaint,
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('ارسال'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
