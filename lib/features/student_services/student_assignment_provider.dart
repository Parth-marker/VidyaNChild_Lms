import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:lms_project/features/teachers/widgets/quiz_question_builder.dart';

class StudentAssignmentProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error;
  Stream<List<Map<String, dynamic>>>? _assignmentsStream;
  String? _cachedEmail;

  String get _uid => _auth.currentUser?.uid ?? '';
  String? get _email => _auth.currentUser?.email;

  // Check if current user is the test student
  // bool get _isTestStudent => _email == 'parthvermablue@gmail.com';

  // Get all published assignments
  // For now, show all published assignments if user is test student
  Stream<List<Map<String, dynamic>>> getPublishedAssignments() {
    // Reset stream if email changed (user switched)
    if (_cachedEmail != _email) {
      _assignmentsStream = null;
      _cachedEmail = _email;
    }

    // Return cached stream if available
    if (_assignmentsStream != null) {
      return _assignmentsStream!;
    }

    // if (!_isTestStudent) {
    //   _assignmentsStream = Stream.value([]);
    //   return _assignmentsStream!;
    // }

    // Create stream without orderBy to avoid index issues
    // We'll sort manually in the map function
    _assignmentsStream = _db
        .collection('assignments')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snap) {
          final docs = snap.docs.map((d) {
            final data = d.data();
            return {...data, 'id': d.id};
          }).toList();

          // Sort manually by createdAt if available (newest first)
          docs.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return docs;
        });

    return _assignmentsStream!;
  }

  // Get a specific assignment by ID
  Future<Map<String, dynamic>?> getAssignment(String assignmentId) async {
    try {
      final doc = await _db.collection('assignments').doc(assignmentId).get();
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Parse quiz questions from assignment content
  List<QuizQuestion> parseQuizQuestions(String content) {
    try {
      final List<dynamic> questionsJson = jsonDecode(content);
      return questionsJson
          .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q)))
          .toList();
    } catch (e) {
      print('Error parsing quiz questions: $e');
      return [];
    }
  }

  // Check if student has already attempted a quiz
  Future<bool> hasAttemptedQuiz(String assignmentId) async {
    try {
      final snapshot = await _db
          .collection('quizSubmissions')
          .where('assignmentId', isEqualTo: assignmentId)
          .where('studentId', isEqualTo: _uid)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking quiz attempt: $e');
      return false;
    }
  }

  // Get quiz submission/score for a specific assignment
  Future<Map<String, dynamic>?> getQuizScore(String assignmentId) async {
    try {
      final snapshot = await _db
          .collection('quizSubmissions')
          .where('assignmentId', isEqualTo: assignmentId)
          .where('studentId', isEqualTo: _uid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Sort manually and get the most recent
        final docs = snapshot.docs.toList();
        docs.sort((a, b) {
          final aTime = a.data()['submittedAt'] as Timestamp?;
          final bTime = b.data()['submittedAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        final doc = docs.first;
        return {...doc.data(), 'id': doc.id};
      }
      return null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Submit quiz answers and auto-grade
  Future<Map<String, dynamic>?> submitQuiz({
    required String assignmentId,
    required String teacherId,
    required List<QuizQuestion> questions,
    required List<int> selectedAnswers,
    int? timeTaken,
  }) async {
    // if (!_isTestStudent) {
    //   error = 'Only test student can submit quizzes';
    //   notifyListeners();
    //   return null;
    // }

    loading = true;
    error = null;
    notifyListeners();

    try {
      // Validate answers length matches questions length
      if (selectedAnswers.length != questions.length) {
        throw Exception('Number of answers does not match number of questions');
      }

      // Calculate score
      int correctAnswers = 0;
      List<Map<String, dynamic>> answerDetails = [];

      for (int i = 0; i < questions.length; i++) {
        final question = questions[i];
        final selectedAnswer = selectedAnswers[i];
        final isCorrect = selectedAnswer == question.correctAnswerIndex;

        if (isCorrect) {
          correctAnswers++;
        }

        answerDetails.add({
          'questionIndex': i,
          'selectedAnswerIndex': selectedAnswer,
          'correctAnswerIndex': question.correctAnswerIndex,
          'isCorrect': isCorrect,
        });
      }

      final totalQuestions = questions.length;
      final percentage = (correctAnswers / totalQuestions) * 100;

      // Create submission document
      final submissionData = {
        'assignmentId': assignmentId,
        'studentId': _uid,
        'teacherId': teacherId,
        'answers': answerDetails,
        'score': correctAnswers,
        'totalQuestions': totalQuestions,
        'percentage': percentage,
        'submittedAt': FieldValue.serverTimestamp(),
        if (timeTaken != null) 'timeTaken': timeTaken,
      };

      final docRef = await _db
          .collection('quizSubmissions')
          .add(submissionData);

      // Also create/update a general submission record for teacher stats
      await _db.collection('submissions').add({
        'assignmentId': assignmentId,
        'studentId': _uid,
        'teacherId': teacherId,
        'assignmentType': 'Quiz',
        'status': 'submitted',
        'submittedAt': FieldValue.serverTimestamp(),
        'score': percentage,
      });

      loading = false;
      notifyListeners();

      return {
        ...submissionData,
        'id': docRef.id,
        'submittedAt': Timestamp.now(), // Approximate for return value
      };
    } catch (e) {
      error = e.toString();
      loading = false;
      notifyListeners();
      return null;
    }
  }

  // Get all quiz submissions for current student
  Stream<List<Map<String, dynamic>>> getMyQuizSubmissions() {
    if (_uid.isEmpty) {
      return Stream.value([]);
    }

    return _db
        .collection('quizSubmissions')
        .where('studentId', isEqualTo: _uid)
        .snapshots()
        .map((snap) {
          final docs = snap.docs.map((d) {
            final data = d.data();
            return {...data, 'id': d.id};
          }).toList();

          // Sort manually by submittedAt if available (newest first)
          docs.sort((a, b) {
            final aTime = a['submittedAt'] as Timestamp?;
            final bTime = b['submittedAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          return docs;
        });
  }

  // Get top 2 recent published worksheets and lessons
  Stream<List<Map<String, dynamic>>> getRecentWorksheetsAndLessons() {
    // if (!_isTestStudent) {
    //   return Stream.value([]);
    // }

    return _db
        .collection('assignments')
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snap) {
          final docs = snap.docs.map((d) {
            final data = d.data();
            return {...data, 'id': d.id};
          }).toList();

          // Filter for Worksheets and Lessons only
          final worksheetsAndLessons = docs.where((a) {
            final type = a['assignmentType'] as String?;
            return type == 'Worksheet' || type == 'Lesson';
          }).toList();

          // Sort manually by createdAt if available (newest first)
          worksheetsAndLessons.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime);
          });

          // Return top 2
          return worksheetsAndLessons.take(2).toList();
        });
  }
}
