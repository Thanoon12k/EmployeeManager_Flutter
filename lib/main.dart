import 'package:emp_manager_front_end/login.dart';
import 'package:emp_manager_front_end/home.dart'; // Import your main screen here
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ادارة الموظفين',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data == true ? MainScreen() : LoginScreen();
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    // return false;
    // return true; // Replace this with the actual implementation
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('token');
    return username != null;
  }
}
