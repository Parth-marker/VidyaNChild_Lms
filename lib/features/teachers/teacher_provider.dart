import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms_project/models/assignment_model.dart';
import 'package:lms_project/models/timeline_model.dart';
import 'dart:convert';

class TeacherProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool loading = false;
  bool saving = false;
  String? error;
  List<Map<String, dynamic>> uploads = [];
  List<Map<String, dynamic>> drafts = [];
  List<Map<String, dynamic>> analytics = [];

  String get _uid => _auth.currentUser?.uid ?? 'teacher-demo';

  List<Map<String, dynamic>> _asList(dynamic value) {
    return (value as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> loadDashboard() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      debugPrint('DEBUG: TeacherProvider.loadDashboard for UID: $_uid');
      // Load drafts from assignments collection
      final draftsSnapshot = await _db
          .collection('assignments')
          .where('createdBy', isEqualTo: _uid)
          .where('isPublished', isEqualTo: false)
          .get();

      drafts = draftsSnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
      debugPrint('DEBUG: Found ${drafts.length} drafts');

      // Load other teacher data
      final doc = await _db.collection('teachers').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        uploads = _asList(data['uploads']);
        analytics = _asList(data['analytics']);
      } else {
        debugPrint('DEBUG: Teacher document does not exist for UID: $_uid');
        uploads = [];
        analytics = [];
      }
    } catch (e) {
      debugPrint('ERROR: TeacherProvider.loadDashboard: $e');
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Stream<List<Map<String, dynamic>>> completionStats() {
    return _db
        .collection('assignments')
        .where('createdBy', isEqualTo: _uid)
        .snapshots()
        .map((snap) {
          debugPrint(
            'DEBUG: completionStats sync, found ${snap.docs.length} assignments',
          );
          return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
        });
  }

  Future<void> addUpload(Map<String, dynamic> upload) async {
    await _db.collection('teachers').doc(_uid).set({
      'uploads': FieldValue.arrayUnion([upload]),
    }, SetOptions(merge: true));
    uploads.add(upload);
    notifyListeners();
  }

  Future<String?> createAssignment(Map<String, dynamic> payload) async {
    saving = true;
    notifyListeners();
    try {
      // Handle Quiz Questions parsing
      List<Map<String, dynamic>>? questions;
      String? content = payload['content'];

      if (payload['assignmentType'] == 'Quiz' && content != null) {
        try {
          final List<dynamic> parsed = jsonDecode(content);
          questions = parsed.map((q) => Map<String, dynamic>.from(q)).toList();
          // Clear content string for Quizzes as we store it in 'questions' field
          content = null;
        } catch (e) {
          debugPrint('Error parsing quiz questions: $e');
        }
      }

      final assignment = Assignment(
        id: '', // Will be set by Firestore
        title: payload['title'] ?? '',
        description: payload['message'] ?? '',
        subject: 'Mathematics', // Default for now, can be dynamic later
        dueDate: payload['submissionDate'] as DateTime? ?? DateTime.now(),
        type: payload['assignmentType'] ?? 'Worksheet',
        questions: questions?.map((q) => Question.fromMap(q)).toList(),
        content: content,
        createdBy: _uid,
        createdAt: DateTime.now(),
        isPublished: payload['publish'] ?? false,
      );

      debugPrint('DEBUG: Creating assignment: ${assignment.title}');
      final docRef = await _db
          .collection('assignments')
          .add(assignment.toMap());
      debugPrint('DEBUG: Assignment created with ID: ${docRef.id}');

      // Reload dashboard to get updated drafts
      await loadDashboard();

      notifyListeners();
      return docRef.id;
    } catch (e) {
      debugPrint('ERROR: TeacherProvider.createAssignment: $e');
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAssignment(
    String assignmentId,
    Map<String, dynamic> payload,
  ) async {
    saving = true;
    notifyListeners();
    try {
      // Handle Quiz Questions parsing
      List<Map<String, dynamic>>? questions;
      String? content = payload['content'];

      if (payload['assignmentType'] == 'Quiz' && content != null) {
        try {
          final List<dynamic> parsed = jsonDecode(content);
          questions = parsed.map((q) => Map<String, dynamic>.from(q)).toList();
          content = null;
        } catch (e) {
          debugPrint('Error parsing quiz questions: $e');
        }
      }

      final updates = {
        'title': payload['title'],
        'description': payload['message'],
        'dueDate': payload['submissionDate'] != null
            ? Timestamp.fromDate(payload['submissionDate'] as DateTime)
            : null,
        'type': payload['assignmentType'],
        'questions': questions,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
        'isPublished': payload['publish'] ?? false,
      };

      if (payload['publish'] == true) {
        updates['publishedAt'] = FieldValue.serverTimestamp();
      }

      updates.removeWhere((key, value) => value == null);

      await _db.collection('assignments').doc(assignmentId).update(updates);

      // Reload dashboard
      await loadDashboard();

      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<bool> publishAssignment(String assignmentId) async {
    saving = true;
    notifyListeners();
    try {
      debugPrint('DEBUG: Publishing assignment $assignmentId');
      await _db.collection('assignments').doc(assignmentId).update({
        'isPublished': true,
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Remove from drafts
      await loadDashboard();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('ERROR: publishAssignment: $e');
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getAssignment(String assignmentId) async {
    try {
      final doc = await _db.collection('assignments').doc(assignmentId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAssignments({bool? published}) async {
    try {
      debugPrint(
        'DEBUG: getAssignments (published: $published) for UID: $_uid',
      );
      Query<Map<String, dynamic>> query = _db
          .collection('assignments')
          .where('createdBy', isEqualTo: _uid);
      if (published != null) {
        query = query.where('isPublished', isEqualTo: published);
      }
      final snapshot = await query.get();
      debugPrint('DEBUG: getAssignments returned ${snapshot.docs.length} docs');
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      debugPrint('ERROR: getAssignments: $e');
      error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Stream<Map<String, int>> getSubmissionStats(String assignmentId) {
    return _db
        .collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map((snapshot) {
          final total = snapshot.docs.length;
          final submitted = snapshot.docs.where((doc) {
            final data = doc.data();
            return data['status'] == 'submitted' || data['submittedAt'] != null;
          }).length;

          return {
            'total': total,
            'submitted': submitted,
            'percentage': total > 0 ? ((submitted / total) * 100).round() : 0,
          };
        });
  }

  Stream<List<Map<String, dynamic>>> getClassPerformance() {
    // Get all published assignments
    return _db
        .collection('assignments')
        .where('createdBy', isEqualTo: _uid)
        .where('isPublished', isEqualTo: true)
        .orderBy('publishedAt', descending: true)
        .limit(4)
        .snapshots()
        .asyncMap((assignmentsSnap) async {
          List<Map<String, dynamic>> performances = [];

          for (var doc in assignmentsSnap.docs) {
            final assignmentId = doc.id;
            final title = doc.data()['title'] ?? 'Assignment';

            // Get all submissions for this assignment
            final submissionsSnap = await _db
                .collection('submissions')
                .where('assignmentId', isEqualTo: assignmentId)
                .get();

            if (submissionsSnap.docs.isEmpty) {
              performances.add({
                'label': title,
                'avg': '0%',
                'trend': Icons.trending_flat,
              });
              continue;
            }

            double totalScore = 0;
            for (var subDoc in submissionsSnap.docs) {
              totalScore += (subDoc.data()['score'] ?? 0).toDouble();
            }

            double avgScore = totalScore / submissionsSnap.docs.length;

            performances.add({
              'label': title,
              'avg': '${avgScore.round()}%',
              'trend': avgScore >= 75
                  ? Icons.trending_up
                  : (avgScore >= 50
                        ? Icons.trending_flat
                        : Icons.trending_down),
            });
          }

          return performances;
        });
  }

  Stream<List<Map<String, dynamic>>> getTrendStats() {
    return _db
        .collection('submissions')
        .snapshots() // In a real app, filter by teacher's students/class
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return [];

          int totalSubmissions = snapshot.docs.length;
          double totalScore = 0;
          int highScores = 0;

          for (var doc in snapshot.docs) {
            double score = (doc.data()['score'] ?? 0).toDouble();
            totalScore += score;
            if (score >= 75) highScores++;
          }

          double avgScore = totalScore / totalSubmissions;
          int conceptMastery = ((highScores / totalSubmissions) * 100).round();

          return [
            {
              'label': 'Avg. Performance',
              'value': '${avgScore.round()}%',
              'detail': 'overall class average',
              'color': Colors.teal[50],
            },
            {
              'label': 'Concept Mastery',
              'value': '$conceptMastery%',
              'detail': 'scored above 75%',
              'color': Colors.orange[50],
            },
            {
              'label': 'Submissions',
              'value': '$totalSubmissions',
              'detail': 'total tasks completed',
              'color': Colors.purple[50],
            },
            {
              'label': 'Participation',
              'value': '85%', // Placeholder as we don't track attendance yet
              'detail': 'active this week',
              'color': Colors.blue[50],
            },
          ];
        });
  }

  Future<List<TimelineEvent>> getTodayTimetable() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await _db
        .collection('timelines')
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs
        .map((doc) => TimelineEvent.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<bool> deleteAssignment(String assignmentId) async {
    saving = true;
    notifyListeners();
    try {
      await _db.collection('assignments').doc(assignmentId).delete();
      await loadDashboard();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
