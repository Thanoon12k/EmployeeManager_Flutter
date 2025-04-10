import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/announcements.dart';
import 'package:employee_manager_app/login.dart';
import 'package:employee_manager_app/reports.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static Future<User?> getUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    final username = prefs.getString('username');
    final email = prefs.getString('email');
    final phone = prefs.getString('phone');
    final address = prefs.getString('address');
    final birthDate = prefs.getString('birthDate');
    final image = prefs.getString('image');
    final token = prefs.getString('token');
    final is_manager = prefs.getBool('is_manager') ?? false;

    if (username != null && email != null) {
      return User(
        id: int.tryParse(id ?? '0') ?? 0,
        username: username,
        email: email,
        phone: phone ?? '',
        address: address ?? '',
        birthDate: birthDate,
        image: image,
        token: token ?? '',
        is_manager: is_manager,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: getUserFromPrefs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(user: snapshot.data!);
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'الإعلانات'),
          BottomNavigationBarItem(
            icon: Icon(Icons.query_stats),
            label: 'الاستبيانات',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              {}
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnnouncementScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportScreen()),
              );
              break;
          }
        },
      ),
      body: Scaffold(
        appBar: AppBar(
          title: Text('الرئيسية'),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // User image and greeting section
            Column(
              children: [
                SizedBox(height: 40),
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      user.image != null
                          ? NetworkImage(
                            user.image ??
                                'https://example.com/default_image.png',
                          )
                          : AssetImage('assets/images/default_user.jpg')
                              as ImageProvider,
                  backgroundColor: Colors.grey[200],
                ),
                SizedBox(height: 20),
                Text(
                  'مرحبًا ${user.username}!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            // User details section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  InfoRow(label: 'البريد الإلكتروني:', value: user.email),
                  InfoRow(label: 'رقم الهاتف:', value: user.phone),
                  InfoRow(label: 'العنوان:', value: user.address),
                  InfoRow(
                    label: 'تاريخ الميلاد:',
                    value:
                        user.birthDate != null
                            ? user.birthDate.toString().split(' ')[0]
                            : 'غير متوفر',
                  ),
                ],
              ),
            ),

            // Logout button at the bottom center
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Clear all shared preferences
                  final prefs = await SharedPreferences.getInstance();

                  await prefs.clear();
                  print("shared cleaned: ${prefs.getKeys()}");
                  // Optionally, you can also clear the user data from the app
                  // Navigate to the login screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'تسجيل الخروج',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable widget for displaying user info in rows
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
