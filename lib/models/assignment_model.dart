import 'package:cloud_firestore/cloud_firestore.dart';

class Assignment {
  final String id;
  final String title;
  final String description;
  final String subject;
  final DateTime dueDate;
  final String type; // 'Quiz', 'Worksheet', 'Lesson'
  final List<Question>? questions; // For quizzes/worksheets
  final String? content; // For lessons
  final String createdBy; // Teacher ID
  final DateTime createdAt;
  final bool isPublished;

  Assignment({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.dueDate,
    required this.type,
    this.questions,
    this.content,
    required this.createdBy,
    required this.createdAt,
    this.isPublished = false,
  });

  factory Assignment.fromMap(Map<String, dynamic> map, String id) {
    return Assignment(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      subject: map['subject'] ?? '',
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      type: map['type'] ?? 'Worksheet',
      questions: (map['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromMap(q))
          .toList(),
      content: map['content'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isPublished: map['isPublished'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subject': subject,
      'dueDate': Timestamp.fromDate(dueDate),
      'type': type,
      'questions': questions?.map((q) => q.toMap()).toList(),
      'content': content,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublished': isPublished,
    };
  }
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}
