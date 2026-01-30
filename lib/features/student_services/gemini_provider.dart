import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiProvider extends ChangeNotifier {
  GenerativeModel? _model;
  bool busy = false;
  String? error;
  bool _initialized = false;

  /// Initialize the Gemini model with API key from Firestore
  Future<void> _ensureInitialized() async {
    if (_initialized && _model != null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('gemini')
          .get();

      if (!doc.exists) {
        throw Exception('Gemini API key not found in Firestore config');
      }

      final apiKey = doc.data()?['apiKey'] as String?;
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API key is empty');
      }

      _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
      _initialized = true;
    } catch (e) {
      error = e.toString();
      rethrow;
    }
  }

  Future<String> generate(String prompt) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _ensureInitialized();
      final res = await _model!.generateContent([Content.text(prompt)]);
      return res.text ?? '';
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Stream<String> stream(String prompt) async* {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await _ensureInitialized();
      final stream = _model!.generateContentStream([Content.text(prompt)]);
      await for (final chunk in stream) {
        final text = chunk.text;
        if (text != null) yield text;
      }
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Generate a Math study plan based on parameters
  Future<String> generateMathStudyPlan({
    required String mathTopic,
    required String goal,
    required String currentLevel,
    required int hoursPerWeek,
    required int durationWeeks,
    required String learningStyle,
  }) async {
    final prompt =
        '''
You are an expert Math tutor. Create a detailed, personalized study plan for a student.

**Student Profile:**
- Math Topic: $mathTopic
- Goal: $goal
- Current Level: $currentLevel
- Available Study Time: $hoursPerWeek hours per week
- Plan Duration: $durationWeeks weeks
- Learning Style: $learningStyle

**Generate a structured study plan with:**
1. Week-by-week breakdown with specific topics and subtopics
2. Daily study activities based on their learning style
3. Practice exercises and problem sets
4. Milestones and checkpoints to track progress
5. Tips and strategies specific to the topic

Format the response as a clear, actionable plan that's easy to follow.
Use markdown formatting with headers, bullet points, and numbered lists.
''';

    return generate(prompt);
  }
}
