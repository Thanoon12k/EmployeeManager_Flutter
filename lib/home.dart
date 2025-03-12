import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    FormalBooksListScreen(),
    QueriesListScreen(),
    PlaceholderWidget(Colors.green), // Placeholder for the third screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Formal Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Queries',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class FormalBooksListScreen extends StatelessWidget {
  const FormalBooksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Formal Books List Screen'),
    );
  }
}

class QueriesListScreen extends StatelessWidget {
  const QueriesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Queries List Screen'),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}