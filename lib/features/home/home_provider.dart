import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      final doc = await _db.collection('students').doc(_uid).get();
      final data = doc.data() ?? {};
      events = _asList(data['events']);
      timetable = _asList(data['timetable']);
      progress = _asList(data['progress']);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> markProgress(Map<String, dynamic> item) async {
    await _db.collection('students').doc(_uid).set(
      {'progress': FieldValue.arrayUnion([item])},
      SetOptions(merge: true),
    );
    progress.add(item);
    notifyListeners();
  }
}
