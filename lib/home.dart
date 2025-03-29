import 'package:employee_manager_app/classes.dart';
import 'package:employee_manager_app/announcements.dart';
import 'package:employee_manager_app/logout.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final User user;

  const MainScreen({super.key, required this.user});

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
                MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
              );
              break;
          }
        },
      ),
      body: HomeScreen(user: user),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          user.image ?? 'https://example.com/default_image.png',
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Logout()),
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
    );
  }
}

// Reusable widget for displaying user info in rows
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({Key? key, required this.label, required this.value})
    : super(key: key);

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
