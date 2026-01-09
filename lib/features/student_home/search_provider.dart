import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SearchProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  String _query = '';

  String get query => _query;

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  // Local assignment data
  static final List<Map<String, dynamic>> _assignments = [
    {
      'title': 'Integers',
      'type': 'Assignment',
      'category': 'assignment',
      'keywords': ['integers', 'integer', 'math', 'assignment'],
    },
    {
      'title': 'Fractions and Decimals',
      'type': 'Assignment',
      'category': 'assignment',
      'keywords': ['fractions', 'decimals', 'fraction', 'decimal', 'math', 'assignment'],
    },
    {
      'title': 'Data Handling',
      'type': 'Assignment',
      'category': 'assignment',
      'keywords': ['data', 'handling', 'statistics', 'math', 'assignment'],
    },
    {
      'title': 'Decimals Drill',
      'type': 'Submission',
      'category': 'submission',
      'keywords': ['decimals', 'decimal', 'drill', 'submission', 'math'],
    },
    {
      'title': 'Angles Worksheet',
      'type': 'Submission',
      'category': 'submission',
      'keywords': ['angles', 'angle', 'worksheet', 'geometry', 'submission', 'math'],
    },
    {
      'title': 'Syllabus resources',
      'type': 'Submission',
      'category': 'submission',
      'keywords': ['syllabus', 'resources', 'revision', 'math'],
    },
  ];

  Stream<List<Map<String, dynamic>>> get results {
    if (_query.isEmpty) return const Stream.empty();
    
    final queryLower = _query.toLowerCase();
    
    // Combine local assignments and Firebase results
    return Stream.fromFuture(_getCombinedResults(queryLower));
  }

  Future<List<Map<String, dynamic>>> _getCombinedResults(String queryLower) async {
    final results = <Map<String, dynamic>>[];
    
    // Check local assignments
    for (final assignment in _assignments) {
      final keywords = (assignment['keywords'] as List<String>).map((k) => k.toLowerCase()).toList();
      final title = (assignment['title'] as String).toLowerCase();
      
      // Check if query matches title or any keyword (partial match)
      final titleWords = title.split(' ');
      final queryWords = queryLower.split(' ');
      
      bool matches = false;
      
      // Exact title match
      if (title.contains(queryLower) || queryLower.contains(title)) {
        matches = true;
      }
      
      // Check if any query word matches any title word
      if (!matches) {
        for (final queryWord in queryWords) {
          if (titleWords.any((titleWord) => titleWord.contains(queryWord) || queryWord.contains(titleWord))) {
            matches = true;
            break;
          }
        }
      }
      
      // Check keywords
      if (!matches) {
        matches = keywords.any((keyword) => 
          keyword.contains(queryLower) || 
          queryLower.contains(keyword) ||
          queryWords.any((qw) => keyword.contains(qw) || qw.contains(keyword))
        );
      }
      
      if (matches) {
        results.add(assignment);
      }
    }
    
    // Get Firebase results
    try {
      final firebaseSnapshot = await _db
          .collection('resources')
          .where('keywords', arrayContains: queryLower)
          .get();
      
      for (final doc in firebaseSnapshot.docs) {
        // Avoid duplicates
        final docTitle = doc.data()['title'] as String? ?? '';
        if (!results.any((r) => (r['title'] as String?) == docTitle)) {
          results.add(doc.data());
        }
      }
    } catch (e) {
      // If Firebase fails, just return local results
    }
    
    return results;
  }
}
