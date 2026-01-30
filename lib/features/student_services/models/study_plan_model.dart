import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlan {
  final String id;
  final String userId;
  final String title;
  final String mathTopic;
  final String goal;
  final String currentLevel;
  final int hoursPerWeek;
  final int durationWeeks;
  final String learningStyle;
  final String generatedPlan; // Markdown content from AI
  final DateTime createdAt;
  final bool isActive;

  StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.mathTopic,
    required this.goal,
    required this.currentLevel,
    required this.hoursPerWeek,
    required this.durationWeeks,
    required this.learningStyle,
    required this.generatedPlan,
    required this.createdAt,
    this.isActive = true,
  });

  factory StudyPlan.fromMap(Map<String, dynamic> map, String id) {
    return StudyPlan(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Untitled Plan',
      mathTopic: map['mathTopic'] ?? 'General Math',
      goal: map['goal'] ?? '',
      currentLevel: map['currentLevel'] ?? 'Beginner',
      hoursPerWeek: map['hoursPerWeek'] ?? 1,
      durationWeeks: map['durationWeeks'] ?? 1,
      learningStyle: map['learningStyle'] ?? 'Visual',
      generatedPlan: map['generatedPlan'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'mathTopic': mathTopic,
      'goal': goal,
      'currentLevel': currentLevel,
      'hoursPerWeek': hoursPerWeek,
      'durationWeeks': durationWeeks,
      'learningStyle': learningStyle,
      'generatedPlan': generatedPlan,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}
