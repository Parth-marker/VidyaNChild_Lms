import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:lms_project/models/assignment_model.dart';
import 'package:lms_project/models/submission_model.dart';
import 'package:lms_project/models/timeline_model.dart';

class HomeProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool loading = false;
  String? error;
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> timetable = [];
  List<Map<String, dynamic>> progress = [];

  String get _uid => _auth.currentUser?.uid ?? 'demo';

  List<Map<String, dynamic>> _asList(dynamic value) {
    return (value as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> loadHome() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      debugPrint('DEBUG: HomeProvider.loadHome for UID: $_uid');
      final doc = await _db.collection('students').doc(_uid).get();
      if (!doc.exists) {
        debugPrint('DEBUG: Student document does not exist for UID: $_uid');
      }
      final data = doc.data() ?? {};
      events = _asList(data['events']);
      timetable = _asList(data['timetable']);
      progress = _asList(data['progress']);
      debugPrint(
        'DEBUG: loadHome success. Timetable count: ${timetable.length}',
      );
    } catch (e) {
      debugPrint('ERROR: HomeProvider.loadHome: $e');
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> markProgress(Map<String, dynamic> item) async {
    await _db.collection('students').doc(_uid).set({
      'progress': FieldValue.arrayUnion([item]),
    }, SetOptions(merge: true));
    progress.add(item);
    notifyListeners();
  }

  // --- Assignments & Submissions ---

  Stream<List<Assignment>> getAssignments() {
    return _db
        .collection('assignments')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snap) {
          debugPrint(
            'DEBUG: HomeProvider.getAssignments found ${snap.docs.length} assignments',
          );
          return snap.docs
              .map((doc) => Assignment.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<Submission>> getMySubmissions() {
    return _db
        .collection('submissions')
        .where('studentId', isEqualTo: _uid)
        .snapshots()
        .map((snap) {
          debugPrint(
            'DEBUG: HomeProvider.getMySubmissions found ${snap.docs.length} submissions',
          );
          return snap.docs
              .map((doc) => Submission.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> submitAssignment(Submission submission) async {
    try {
      debugPrint(
        'DEBUG: HomeProvider.submitAssignment for assignment: ${submission.assignmentId}',
      );
      await _db.collection('submissions').add(submission.toMap());
      debugPrint('DEBUG: Submission successful');
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR: HomeProvider.submitAssignment: $e');
      rethrow;
    }
  }

  Future<Map<String, String>> uploadSubmissionAttachment({
    required String assignmentId,
    required String studentId,
    required File file,
    required String fileName,
  }) async {
    final safeFileName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final ref = FirebaseStorage.instance
        .ref()
        .child('submissions')
        .child(assignmentId)
        .child(studentId)
        .child('${DateTime.now().millisecondsSinceEpoch}_$safeFileName');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return {'url': url, 'name': fileName};
  }

  // --- Analytics ---

  Stream<Map<String, dynamic>> getAnalytics() {
    return getMySubmissions().map((submissions) {
      final scored = submissions
          .where((s) => s.answers.isNotEmpty || s.score > 0)
          .toList();

      if (scored.isEmpty) {
        return {
          'scores': <Map<String, String>>[],
          'mastery': '0%',
          'lowSubject': 'N/A',
        };
      }

      scored.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      final scores = scored
          .take(4)
          .map(
            (s) => {
              'subject': s.subject.isNotEmpty ? s.subject : 'General',
              'score': '${s.score.round()}%',
            },
          )
          .toList();

      final Map<String, List<double>> bySubject = {};
      for (final s in scored) {
        final subject = s.subject.isNotEmpty ? s.subject : 'General';
        bySubject.putIfAbsent(subject, () => []).add(s.score);
      }

      String lowSubject = 'N/A';
      double lowAvg = double.infinity;
      bySubject.forEach((subject, scores) {
        final avg =
            scores.reduce((a, b) => a + b) / (scores.isEmpty ? 1 : scores.length);
        if (avg < lowAvg) {
          lowAvg = avg;
          lowSubject = subject;
        }
      });

      double total = 0;
      for (var s in scored) {
        total += s.score;
      }
      double avg = total / scored.length;

      return {
        'scores': scores,
        'mastery': '${avg.round()}%',
        'lowSubject': avg < 70 ? lowSubject : 'None',
      };
    });
  }

  // --- Timetable ---

  Stream<List<TimelineEvent>> getTodayTimetable() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _db
        .collection('timelines')
        .where('userId', isEqualTo: _uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => TimelineEvent.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
