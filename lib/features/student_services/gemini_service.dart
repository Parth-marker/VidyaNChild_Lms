import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _geminiKeyDocPath = 'config/gemini';
  String? _geminiKey;
  Future<void>? _initFuture;

  Future<String> _loadGeminiKey() async {
    if (_geminiKey != null && _geminiKey!.isNotEmpty) {
      return _geminiKey!;
    }

    final snapshot = await _firestore.doc(_geminiKeyDocPath).get();
    if (!snapshot.exists) {
      throw StateError('Gemini API key missing at $_geminiKeyDocPath');
    }

    final data = snapshot.data();
    if (data == null) {
      throw StateError('Gemini API key document empty at $_geminiKeyDocPath');
    }

    final value = data['apiKey'];
    if (value is! String || value.trim().isEmpty) {
      throw StateError('Gemini API key is invalid at $_geminiKeyDocPath');
    }

    _geminiKey = value.trim();
    return _geminiKey!;
  }

  Future<void> _initialize() async {
    if (_model != null) return;
    if (_initFuture != null) return _initFuture!;
    _initFuture = () async {
      try {
        final apiKey = await _loadGeminiKey();
        _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
      } catch (e) {
        _initFuture = null;
        rethrow;
      }
    }();

    return _initFuture!;
  }

  Future<void> init() => _initialize();

  /// Get a streaming response from Gemini
  Stream<String> generateStream(String prompt) async* {
    await _initialize();

    final model = _model!;
    final content = [Content.text(prompt)];
    final response = model.generateContentStream(content);

    await for (final chunk in response) {
      if (chunk.text != null) {
        yield chunk.text!;
      }
    }
  }

  /// Get a single response from Gemini (non-streaming)
  Future<String> generate(String prompt) async {
    await _initialize();

    final model = _model!;
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response.text ?? 'No response generated';
  }

  void clearCachedKey() {
    _geminiKey = null;
  }
}
