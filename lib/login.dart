import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:employee_manager_app/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<void> _login() async {
    // Validate username and password inputs
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _message = 'يرجى إدخال اسم المستخدم وكلمة المرور';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // Make POST request to login API
      final response = await http
          .post(
            Uri.parse('https://thanoon.pythonanywhere.com/api-token-auth/'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': _usernameController.text.trim(),
              'password': _passwordController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Process successful login
        final responseData = json.decode(response.body);
        print("resonse data user logged in: $responseData");
        // print(
        //   "User details saved - ID: ${responseData['id']}, Username: ${responseData['username']}, Email: ${responseData['email']}, is_manager: ${responseData['is_manager']}",
        // );
        if (responseData.containsKey('id') &&
            responseData.containsKey('username') &&
            responseData.containsKey('token')) {
          // Save user data in SharedPreferences
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('id', responseData['id'].toString());
          await prefs.setString('username', responseData['username']);
          await prefs.setString(
            'email',
            responseData['email'] ?? "لم يتم تسجيله",
          );
          await prefs.setString(
            'birth_date',
            responseData['birth_date'] ?? "غير معروف",
          );
          await prefs.setString('address', responseData['address'] ?? "");
          await prefs.setString('phone', responseData['phone'] ?? "");
          await prefs.setString('image', responseData['image'] ?? "");
          await prefs.setString('token', responseData['token']);
          await prefs.setBool(
            'is_manager',responseData['is_manager'] ,
          );

          setState(() {
            _message = 'تم تسجيل الدخول بنجاح';
          });

          // Navigate to MainScreen after a short delay
          if (mounted) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            });
          }
        } else {
          throw Exception('Incomplete user data from server');
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _message = 'اسم المستخدم أو كلمة المرور غير صحيح';
        });
      } else {
        setState(() {
          _message = 'حدث خطأ أثناء تسجيل الدخول. حاول مرة أخرى.';
        });
      }
    } on SocketException {
      setState(() {
        _message = 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.';
      });
    } on TimeoutException {
      setState(() {
        _message = 'انتهت مهلة الاتصال. حاول مجددًا.';
      });
    } catch (e) {
      setState(() {
        _message = 'حدث خطأ غير متوقع: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'مرحبًا بعودتك!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'تسجيل الدخول إلى حسابك',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text('تسجيل الدخول'),
                  ),
              const SizedBox(height: 20),
              Text(
                _message,
                style: TextStyle(
                  color:
                      _message == 'تم تسجيل الدخول بنجاح'
                          ? Colors.green
                          : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
