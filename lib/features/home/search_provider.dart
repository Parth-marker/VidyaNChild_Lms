import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  String _query = '';

  String get query => _query;

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  Stream<List<Map<String, dynamic>>> get results {
    if (_query.isEmpty) return const Stream.empty();
    return _db
        .collection('resources')
        .where('keywords', arrayContains: _query.toLowerCase())
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
