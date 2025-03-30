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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? username = prefs.getString('username');
    if (username == null) {
      print('cannot find username in shared preferences');
      return null;
    }

    String? id = prefs.getString('id');
    String? email = prefs.getString('email');
    String? birthDate = prefs.getString('birth_date');
    String? address = prefs.getString('address');
    String? phone = prefs.getString('phone');
    String? image = prefs.getString('image');
    String? token = prefs.getString('token');

    if (id == null ||
        email == null ||
        address == null ||
        phone == null ||
        token == null) {
      print("Some required user details are missing!");
      return null;
    }

    return User(
      id: int.tryParse(id) ?? 0, // يجعل التحويل أكثر أمانًا
      username: username,
      email: email,
      birthDate: birthDate,
      address: address,
      phone: phone,
      image: image,
      token: token,
    );
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
