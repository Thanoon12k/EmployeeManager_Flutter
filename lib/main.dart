import 'package:flutter/material.dart';
import 'signin_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emplyee Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      ),
      home: HomePage(),
    );
  }
}
