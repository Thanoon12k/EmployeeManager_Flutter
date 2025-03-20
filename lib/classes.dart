class FormalBook {
  final int id;
  final String title;
  final String description;
  final String image;
  final String file;
  final DateTime pubDate;

  FormalBook({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.file,
    required this.pubDate,
  });

  factory FormalBook.fromJson(Map<String, dynamic> json) {
    return FormalBook(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      file: json['file'],
      pubDate: DateTime.parse(json['pub_date']),
    );
  }
}
