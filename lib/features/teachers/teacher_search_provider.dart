import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class TeacherSearchProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _query = '';

  String get query => _query;

  String get _uid => _auth.currentUser?.uid ?? 'teacher-demo';

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  Stream<List<Map<String, dynamic>>> get results {
    if (_query.isEmpty) return const Stream.empty();
    
    final queryLower = _query.toLowerCase();
    
    return Stream.fromFuture(_getCombinedResults(queryLower));
  }

  Future<List<Map<String, dynamic>>> _getCombinedResults(String queryLower) async {
    final results = <Map<String, dynamic>>[];
    
    // Search in assignments collection (Firestore)
    try {
      final assignmentsSnapshot = await _db
          .collection('assignments')
          .where('teacherId', isEqualTo: _uid)
          .get();
      
      for (final doc in assignmentsSnapshot.docs) {
        final data = doc.data();
        final title = (data['title'] as String? ?? '').toLowerCase();
        final status = (data['status'] as String? ?? '').toLowerCase();
        
        // Check if query matches title or status
        if (title.contains(queryLower) || 
            queryLower.contains(title) ||
            status.contains(queryLower) ||
            _matchesQuery(queryLower, title)) {
          results.add({
            ...data,
            'id': doc.id,
            'category': 'assignment',
            'type': 'Assignment',
            'source': 'firestore',
          });
        }
      }
    } catch (e) {
      // If Firebase fails, continue with other sources
      print('Error searching assignments: $e');
    }
    
    // Search in teachers collection (drafts and uploads)
    try {
      final teacherDoc = await _db.collection('teachers').doc(_uid).get();
      if (teacherDoc.exists) {
        final data = teacherDoc.data() ?? {};
        
        // Search drafts
        final drafts = (data['drafts'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        
        for (final draft in drafts) {
          final title = (draft['title'] as String? ?? '').toLowerCase();
          final status = (draft['status'] as String? ?? '').toLowerCase();
          
          if (title.contains(queryLower) || 
              queryLower.contains(title) ||
              status.contains(queryLower) ||
              _matchesQuery(queryLower, title)) {
            // Avoid duplicates
            if (!results.any((r) => 
                r['title'] == draft['title'] && 
                r['category'] == 'draft')) {
              results.add({
                ...draft,
                'category': 'draft',
                'type': 'Draft',
                'source': 'local',
              });
            }
          }
        }
        
        // Search uploads
        final uploads = (data['uploads'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        
        for (final upload in uploads) {
          final title = (upload['title'] as String? ?? '').toLowerCase();
          final subtitle = (upload['subtitle'] as String? ?? '').toLowerCase();
          
          if (title.contains(queryLower) || 
              queryLower.contains(title) ||
              subtitle.contains(queryLower) ||
              _matchesQuery(queryLower, title)) {
            // Avoid duplicates
            if (!results.any((r) => 
                r['title'] == upload['title'] && 
                r['category'] == 'upload')) {
              results.add({
                ...upload,
                'category': 'upload',
                'type': 'Upload',
                'source': 'local',
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error searching teacher data: $e');
    }
    
    return results;
  }

  bool _matchesQuery(String queryLower, String text) {
    final queryWords = queryLower.split(' ').where((w) => w.isNotEmpty).toList();
    final textWords = text.split(' ').where((w) => w.isNotEmpty).toList();
    
    // Check if any query word matches any text word (partial match)
    for (final queryWord in queryWords) {
      if (textWords.any((textWord) => 
          textWord.contains(queryWord) || 
          queryWord.contains(textWord))) {
        return true;
      }
    }
    return false;
  }
}

