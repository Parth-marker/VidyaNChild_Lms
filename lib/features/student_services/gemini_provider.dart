import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lms_project/features/student_services/gemini_service.dart';

class GeminiProvider extends ChangeNotifier {
  GeminiProvider({
    GeminiService? service,
  }) : _service = service ?? GeminiService();

  final GeminiService _service;
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
    initializing = true;
    error = null;
    _notifySafely();
    try {
      await _service.init();
    } catch (e) {
      error = e.toString();
    } finally {
      initializing = false;
      _notifySafely();
    }
  }

  Future<String> generate(String prompt) async {
    busy = true;
    error = null;
    _notifySafely();
    try {
      return await _service.generate(prompt);
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
      await for (final chunk in _service.generateStream(prompt)) {
        yield chunk;
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
