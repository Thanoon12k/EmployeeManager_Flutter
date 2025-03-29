import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = 'جاري تسجيل الدخول...';
    });

    try {
      print("إرسال طلب تسجيل الدخول...");

      final response = await http.post(
        Uri.parse('https://thanoon.pythonanywhere.com/api-token-auth/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      print("تم استلام الرد من السيرفر: ${response.statusCode}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("بيانات المستخدم المسترجعة: $responseData");

        // التأكد من أن البيانات تحتوي على المعلومات المطلوبة
        if (!responseData.containsKey('id') ||
            !responseData.containsKey('username') ||
            !responseData.containsKey('email') ||
            !responseData.containsKey('token')) {
          throw Exception("البيانات المسترجعة غير مكتملة!");
        }

        final User user = User(
          id: int.tryParse(responseData['id'].toString()) ?? 0,
          username: responseData['username'],
          email: responseData['email'],
          birthDate: responseData['birth_date'] ?? 'not known',
          address: responseData['address'] ?? '',
          phone: responseData['phone'] ?? '',
          image: responseData['image'] ?? '',
          token: responseData['token'],
        );

        // حفظ بيانات المستخدم في SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', user.id.toString());
        await prefs.setString('username', user.username);
        await prefs.setString('email', user.email);
        await prefs.setString('birth_date', user.birthDate ?? 'unknown');
        await prefs.setString('address', user.address);
        await prefs.setString('phone', user.phone);
        await prefs.setString('image', user.image ?? '');
        await prefs.setString('token', user.token);

        print("تم حفظ بيانات المستخدم بنجاح في SharedPreferences.");

        setState(() {
          _message = 'تم تسجيل الدخول بنجاح';
        });

        // الانتقال إلى الشاشة الرئيسية بعد التحقق من أن السياق لا يزال متاحًا
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          });
        }
      } else {
        print("خطأ في تسجيل الدخول، رمز الحالة: ${response.statusCode}");
        print("الرد من السيرفر: ${response.body}");

        setState(() {
          _message = 'خطأ في اسم المستخدم أو كلمة المرور';
        });
      }
    } catch (e) {
      print("حدث خطأ أثناء تسجيل الدخول: $e");
      setState(() {
        _message = 'حدث خطأ غير متوقع، يرجى المحاولة لاحقًا';
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
