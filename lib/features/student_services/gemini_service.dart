import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized && _model != null) return;

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

    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
    _initialized = true;
  }

  /// Get a streaming response from Gemini
  Stream<String> generateStream(String prompt) async* {
    await _initialize();

    final content = [Content.text(prompt)];
    final response = _model!.generateContentStream(content);

    await for (final chunk in response) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  /// Get a single response from Gemini (non-streaming)
  Future<String> generate(String prompt) async {
    await _initialize();

    final content = [Content.text(prompt)];
    final response = await _model!.generateContent(content);

    return response.text ?? 'No response generated';
  }
}
