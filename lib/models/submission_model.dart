import 'package:cloud_firestore/cloud_firestore.dart';

class Submission {
  final String id;
  final String assignmentId;
  final String assignmentTitle;
  final String subject;
  final String studentId;
  final String studentName;
  final Map<String, int> answers; // Question index -> Selected option index
  final double score; // Percentage or points
  final DateTime submittedAt;
  final String? attachmentUrl;
  final String? attachmentName;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.subject,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.score,
    required this.submittedAt,
    this.attachmentUrl,
    this.attachmentName,
  });

  factory Submission.fromMap(Map<String, dynamic> map, String id) {
    return Submission(
      id: id,
      assignmentId: map['assignmentId'] ?? '',
      assignmentTitle: map['assignmentTitle'] ?? '',
      subject: map['subject'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? 'Unknown',
      answers: Map<String, int>.from(map['answers'] ?? {}),
      score: (map['score'] ?? 0).toDouble(),
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      attachmentUrl: map['attachmentUrl'] as String?,
      attachmentName: map['attachmentName'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'assignmentTitle': assignmentTitle,
      'subject': subject,
      'studentId': studentId,
      'studentName': studentName,
      'answers': answers,
      'score': score,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'attachmentUrl': attachmentUrl,
      'attachmentName': attachmentName,
    };
  }
}
