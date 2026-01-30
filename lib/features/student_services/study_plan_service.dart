import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_project/features/student_services/models/study_plan_model.dart';

class StudyPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> _getPlansCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('studyPlans');
  }

  // Save a new study plan
  Future<void> saveStudyPlan(StudyPlan plan) async {
    await _getPlansCollection(plan.userId).doc(plan.id).set(plan.toMap());
  }

  // Get all study plans for a user
  Stream<List<StudyPlan>> getUserStudyPlans(String userId) {
    return _getPlansCollection(
      userId,
    ).orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return StudyPlan.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Delete a study plan
  Future<void> deleteStudyPlan(String userId, String planId) async {
    await _getPlansCollection(userId).doc(planId).delete();
  }

  // Toggle active status
  Future<void> togglePlanStatus(
    String userId,
    String planId,
    bool isActive,
  ) async {
    await _getPlansCollection(
      userId,
    ).doc(planId).update({'isActive': isActive});
  }
}
