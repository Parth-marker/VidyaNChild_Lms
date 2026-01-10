import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // Load drafts from assignments collection
      final draftsSnapshot = await _db
          .collection('assignments')
          .where('teacherId', isEqualTo: _uid)
          .where('status', isEqualTo: 'draft')
          .get();
      
      drafts = draftsSnapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
      
      // Load other teacher data
      final doc = await _db.collection('teachers').doc(_uid).get();
      final data = doc.data() ?? {};
      uploads = _asList(data['uploads']);
      analytics = _asList(data['analytics']);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Stream<List<Map<String, dynamic>>> completionStats() {
    return _db
        .collection('assignments')
        .where('teacherId', isEqualTo: _uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {
          ...d.data(),
          'id': d.id,
        }).toList());
  }

  Future<void> addUpload(Map<String, dynamic> upload) async {
    await _db.collection('teachers').doc(_uid).set(
      {'uploads': FieldValue.arrayUnion([upload])},
      SetOptions(merge: true),
    );
    uploads.add(upload);
    notifyListeners();
  }

  Future<String?> createAssignment(Map<String, dynamic> payload) async {
    saving = true;
    notifyListeners();
    try {
      final assignmentData = {
        ...payload,
        'teacherId': _uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Convert DateTime to Timestamp if present
      if (payload['submissionDate'] is DateTime) {
        assignmentData['submissionDate'] = Timestamp.fromDate(payload['submissionDate'] as DateTime);
      }
      
      final doc = await _db.collection('assignments').add(assignmentData);
      final assignmentId = doc.id;
      
      // Reload dashboard to get updated drafts
      await loadDashboard();
      
      notifyListeners();
      return assignmentId;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAssignment(String assignmentId, Map<String, dynamic> payload) async {
    saving = true;
    notifyListeners();
    try {
      final assignmentData = {
        ...payload,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Convert DateTime to Timestamp if present
      if (payload['submissionDate'] is DateTime) {
        assignmentData['submissionDate'] = Timestamp.fromDate(payload['submissionDate'] as DateTime);
      }
      
      await _db.collection('assignments').doc(assignmentId).update(assignmentData);
      
      // Reload dashboard to update drafts list (draft will be removed if published)
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
      await _db.collection('assignments').doc(assignmentId).update({
        'status': 'published',
        'publishedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Remove from drafts
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
      Query<Map<String, dynamic>> query = _db.collection('assignments').where('teacherId', isEqualTo: _uid);
      if (published != null) {
        query = query.where('status', isEqualTo: published ? 'published' : 'draft');
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    } catch (e) {
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

  Future<bool> deleteAssignment(String assignmentId) async {
    saving = true;
    notifyListeners();
    try {
      await _db.collection('assignments').doc(assignmentId).delete();
      // Reload dashboard to update lists
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
