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



class Question {
  final int id;
  final String questionText;
  final String questionType;
  final String? option1;
  final String? option2;
  final String? option3;
  final String? option4;

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['question_text'],
      questionType: json['question_type'],
      option1: json['option1'],
      option2: json['option2'],
      option3: json['option3'],
      option4: json['option4'],
    );
  }
}

class Report {
  final int id;
  final String title;
  final String description;
  final String pubDate;
  final List<Question> questions;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.pubDate,
    required this.questions,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    var list = json['questions'] as List;
    List<Question> questionsList = list.map((i) => Question.fromJson(i)).toList();

    return Report(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pubDate: json['pub_date'],
      questions: questionsList,
    );
  }
}

