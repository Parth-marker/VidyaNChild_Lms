import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final bool isRecurring;
  final String recurrenceType; // 'Daily', 'Weekly', 'None'
  final bool isCompleted;

  TimelineEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.isRecurring = false,
    this.recurrenceType = 'None',
    this.isCompleted = false,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> map, String id) {
    return TimelineEvent(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      isRecurring: map['isRecurring'] ?? false,
      recurrenceType: map['recurrenceType'] ?? 'None',
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'isCompleted': isCompleted,
    };
  }
}
