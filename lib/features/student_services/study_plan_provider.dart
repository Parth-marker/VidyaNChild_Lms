import 'package:flutter/material.dart';
import 'package:lms_project/features/student_services/models/study_plan_model.dart';
import 'package:lms_project/features/student_services/study_plan_service.dart';
import 'package:uuid/uuid.dart';

class StudyPlanProvider extends ChangeNotifier {
  final StudyPlanService _service = StudyPlanService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  StudyPlan? _generatedPlan;
  StudyPlan? get generatedPlan => _generatedPlan;

  // Stream of user's saved plans
  Stream<List<StudyPlan>> getUserPlans(String userId) {
    return _service.getUserStudyPlans(userId);
  }

  // Set the generated plan (called after Gemini generates it)
  void setGeneratedPlan(StudyPlan plan) {
    _generatedPlan = plan;
    notifyListeners();
  }

  // Clear current generated plan
  void clearGeneratedPlan() {
    _generatedPlan = null;
    notifyListeners();
  }

  // Create a StudyPlan object from generated content
  StudyPlan createPlanFromContent({
    required String userId,
    required String mathTopic,
    required String currentLevel,
    required int hoursPerWeek,
    required int durationWeeks,
    required String learningStyle,
    required String content,
  }) {
    final title = '$mathTopic Plan ($durationWeeks weeks)';
    return StudyPlan(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      mathTopic: mathTopic,
      currentLevel: currentLevel,
      hoursPerWeek: hoursPerWeek,
      durationWeeks: durationWeeks,
      learningStyle: learningStyle,
      generatedPlan: content,
      createdAt: DateTime.now(),
    );
  }

  // Save the generated plan to Firestore
  Future<void> saveCurrentPlan() async {
    if (_generatedPlan == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveStudyPlan(_generatedPlan!);
      // Don't clearGeneratedPlan here, allow UI to navigate or show success first
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a plan
  Future<void> deletePlan(String userId, String planId) async {
    try {
      await _service.deleteStudyPlan(userId, planId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
