class User {
  final int id;
  final String username;
  final String email;
  final String? birthDate;
  final String address;
  final String phone;
  final String? image;
  final String token;
  final bool is_manager;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.birthDate,
    required this.address,
    required this.phone,
    this.image,
    required this.token,
    required this.is_manager,
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
      is_manager: json['is_manager'] ?? false,
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
  final List<String>? options; // For multiple-choice questions
  final bool isStatistic;

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    this.options,
    required this.isStatistic,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String>? optionsList;
    if (json['options_data'] != null) {
      optionsList = (json['options_data'] as String).split('-');
    }

    return Question(
      id: json['id'],
      questionText: json['question'],
      questionType: json['question_type'],
      options: optionsList,
      isStatistic: json['is_statistic'] ?? false,
    );
  }
}

class Report {
  final int id;
  final String title;
  final String? description;
  final String pubDate;
  final List<Question> questions;

  Report({
    required this.id,
    required this.title,
    this.description,
    required this.pubDate,
    required this.questions,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    List<dynamic> list = json['questions'] ?? [];
    List<Question> questionsList =
        list.map((i) => Question.fromJson(i)).toList();

    return Report(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pubDate: json['pub_date'],
      questions: questionsList,
    );
  }
}
