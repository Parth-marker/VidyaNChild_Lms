import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiProvider extends ChangeNotifier {
  GeminiProvider({
    String? apiKey,
    DatabaseReference? apiKeyRef,
  })  : _apiKey = apiKey,
        _apiKeyRef =
            apiKeyRef ?? FirebaseDatabase.instance.ref('config/gemini_api_key');

  final DatabaseReference _apiKeyRef;
  GenerativeModel? _model;
  String? _apiKey;
  bool initializing = false;
  bool busy = false;
  String? error;

  void _notifySafely() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
      return;
    }
    notifyListeners();
  }

  Future<void> init() async {
    if (_model != null) return;
    if ((_apiKey ?? '').isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: _apiKey!);
      return;
    }

    initializing = true;
    error = null;
    _notifySafely();
    try {
      final snapshot = await _apiKeyRef.get();
      final key = snapshot.value?.toString() ?? '';
      if (key.isEmpty) {
        error = 'Gemini API key not found in Realtime Database.';
        return;
      }
      _apiKey = key;
      _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: key);
    } catch (e) {
      error = 'Failed to load Gemini API key: $e';
    } finally {
      initializing = false;
      _notifySafely();
    }
  }

  Future<GenerativeModel> _ensureModel() async {
    if (_model != null) return _model!;
    await init();
    if (_model == null) {
      throw Exception(error ?? 'Gemini API key not available.');
    }
    return _model!;
  }

  Future<String> generate(String prompt) async {
    busy = true;
    error = null;
    _notifySafely();
    try {
      final model = await _ensureModel();
      final res = await model.generateContent([Content.text(prompt)]);
      return res.text ?? '';
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      busy = false;
      _notifySafely();
    }
  }

  Stream<String> stream(String prompt) async* {
    busy = true;
    error = null;
    _notifySafely();
    try {
      final model = await _ensureModel();
      final stream = model.generateContentStream([Content.text(prompt)]);
      await for (final chunk in stream) {
        final text = chunk.text;
        if (text != null) yield text;
      }
    } catch (e) {
      error = e.toString();
      rethrow;
    } finally {
      busy = false;
      _notifySafely();
    }
  }
}
