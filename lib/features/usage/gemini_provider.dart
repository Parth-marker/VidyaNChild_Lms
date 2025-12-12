import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiProvider extends ChangeNotifier {
  GeminiProvider({String? apiKey})
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey ??
              const String.fromEnvironment('GEMINI_API_KEY', defaultValue: ''),
        );

  final GenerativeModel _model;
  bool busy = false;
  String? error;

  Future<String> generate(String prompt) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final res = await _model.generateContent([Content.text(prompt)]);
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
      final stream = _model.generateContentStream([Content.text(prompt)]);
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
}
