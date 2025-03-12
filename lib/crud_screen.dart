import 'package:flutter/material.dart';
import 'api_service.dart';

class CrudScreen extends StatefulWidget {
  @override
  _CrudScreenState createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() async {
    final data = await apiService.fetchUsers();
    setState(() => users = data);
  }

  void addUser() async {
    await apiService.createUser({"name": "New User"});
    loadUsers();
  }

  void deleteUser(int id) async {
    await apiService.deleteUser(id);
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD App")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteUser(users[index]['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addUser,
      ),
    );
  }
}
