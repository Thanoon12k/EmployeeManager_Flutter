class User {
  final int id;
  final String username;
  final String email;
  final String? birthDate;
  final String address;
  final String phone;
  final String? image;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.birthDate,
    required this.address,
    required this.phone,
    this.image,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id'].toString()) ?? 0, // تأمين التحويل إلى int
      username: json['username'] ?? 'غير معروف',
      email: json['email'] ?? 'غير متوفر',
      birthDate: json['birth_date'] ?? 'غير معروف',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      token: json['token'] ?? '',
    );
  }
}

class Announcement {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String? file;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.file,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      file: json['file'],
    );
  }
}
