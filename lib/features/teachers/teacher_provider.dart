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
      final doc = await _db.collection('teachers').doc(_uid).get();
      final data = doc.data() ?? {};
      uploads = _asList(data['uploads']);
      drafts = _asList(data['drafts']);
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
        .map((snap) => snap.docs.map((d) => d.data()).toList());
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
      final doc = await _db.collection('assignments').add({
        ...payload,
        'teacherId': _uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      drafts.add({...payload, 'id': doc.id});
      notifyListeners();
      return doc.id;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    } finally {
      saving = false;
      notifyListeners();
    }
  }
}
