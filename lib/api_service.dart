import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://thanoon.pythonanywhere.com/api'; // Replace with your actual backend URL

class ApiService {
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );
    return response.statusCode == 200 ? jsonDecode(response.body) : {
      
    };
  }
  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users/'));
    return response.statusCode == 200 ? jsonDecode(response.body) : [];
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await http.post(Uri.parse('$baseUrl/users/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await http.put(Uri.parse('$baseUrl/users/$id/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data));
  }

  Future<void> deleteUser(int id) async {
    await http.delete(Uri.parse('$baseUrl/users/$id/'));
  }
}
