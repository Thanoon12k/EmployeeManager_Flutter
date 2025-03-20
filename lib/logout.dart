import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logout extends StatelessWidget {
  Future<void> clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Logout')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await clearSharedPreferences();
            print("Logged out");
            print("cleared shared preferences all ");
            Navigator.of(context).pushReplacementNamed('/login');
            // Navigate to login screen or perform other actions
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
