import 'package:shared_preferences/shared_preferences.dart';

class QuizStorage {
  static const String _bestTimeKey = 'quiz_best_time';
  static const String _bestScoreKey = 'quiz_best_score';
  static const String _bestBadgeKey = 'quiz_best_badge';

  // Save best round result
  static Future<void> saveBestResult({
    required int timeInSeconds,
    required int score,
    required String badge,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current best time (lower is better)
    final currentBestTime = prefs.getInt(_bestTimeKey);
    
    // Save if this is better (lower time) or if no previous record
    if (currentBestTime == null || timeInSeconds < currentBestTime) {
      await prefs.setInt(_bestTimeKey, timeInSeconds);
      await prefs.setInt(_bestScoreKey, score);
      await prefs.setString(_bestBadgeKey, badge);
    }
  }

  // Get best time
  static Future<int?> getBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestTimeKey);
  }

  // Get best score
  static Future<int?> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey);
  }

  // Get best badge
  static Future<String?> getBestBadge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_bestBadgeKey);
  }

  // Clear all records
  static Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bestTimeKey);
    await prefs.remove(_bestScoreKey);
    await prefs.remove(_bestBadgeKey);
  }
}

