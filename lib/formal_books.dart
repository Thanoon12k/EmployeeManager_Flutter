import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormalBooksScreen extends StatefulWidget {
  @override
  _FormalBooksScreenState createState() => _FormalBooksScreenState();
}

class _FormalBooksScreenState extends State<FormalBooksScreen> {
  late Future<List<FormalBook>> futureFormalBooks;

  @override
  void initState() {
    super.initState();
    futureFormalBooks = fetchFormalBooks();
  }

  Future<List<FormalBook>> fetchFormalBooks() async {
    final response = await http.get(Uri.parse('https://thanoon.pythonanywhere.com/api/formalbooks/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((book) => FormalBook.fromJson(book)).toList();
    } else {
      throw Exception('Failed to load formal books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Formal Books')),
      body: FutureBuilder<List<FormalBook>>(
        future: futureFormalBooks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Image.network(snapshot.data![index].image),
                  title: Text(snapshot.data![index].title),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormalBookDetails(book: snapshot.data![index]),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class FormalBook {
  final int id;
  final String title;
  final String description;
  final String image;
  final String file;
  final String pubDate;

  FormalBook({required this.id, required this.title, required this.description, required this.image, required this.file, required this.pubDate});

  factory FormalBook.fromJson(Map<String, dynamic> json) {
    return FormalBook(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      file: json['file'],
      pubDate: json['pub_date'],
    );
  }
}

class FormalBookDetails extends StatelessWidget {
  final FormalBook book;

  FormalBookDetails({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(book.image),
            SizedBox(height: 16.0),
            Text(
              book.description,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // handle file download or viewing
                // For example, you can use a plugin like `url_launcher` to open the file link
              },
              child: Text('View Attached File'),
            ),
          ],
        ),
      ),
    );
  }
}
