import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  late final GenerativeModel _model;
  bool _initialized = false;

  void _initialize() {
    if (_initialized) return;
    
    final apiKey = "AIzaSyDoY91IKMwZ7L7ObzNBO2ZC_ps-HWboyBk";
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
    _initialized = true;
  }

  /// Get a streaming response from Gemini
  Stream<String> generateStream(String prompt) async* {
    _initialize();
    
    final content = [Content.text(prompt)];
    final response = _model.generateContentStream(content);

    await for (final chunk in response) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  /// Get a single response from Gemini (non-streaming)
  Future<String> generate(String prompt) async {
    _initialize();
    
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    return response.text ?? 'No response generated';
  }
}
