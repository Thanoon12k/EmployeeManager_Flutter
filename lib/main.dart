import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/home.dart';
import 'package:employee_manager_app/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<User?> _getUserDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      String? username = prefs.getString('username');
      if (username == null) return null;

      String? id = prefs.getString('id');
      String email = prefs.getString('email') ?? "لم يتم تسجيله";
      String? birthDate = prefs.getString('birth_date');
      String? address = prefs.getString('address') ?? "لم يتم تسجيله";
      String? phone = prefs.getString('phone') ?? "لم يتم تسجيله";
      String? image = prefs.getString('image');
      String? token = prefs.getString('token') ?? "bad token";
      bool? is_manager = prefs.getBool('is_manager');

      return User(
        id: int.tryParse(id ?? '-99') ?? -99,
        username: username,
        email: email,
        birthDate: birthDate,
        address: address,
        phone: phone,
        image: image,
        token: token,
        is_manager: is_manager ?? false,
      );
    } catch (e) {
      debugPrint("Error fetching user details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'إدارة الموظفين',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      home: FutureBuilder<User?>(
        future: _getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            return MainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
