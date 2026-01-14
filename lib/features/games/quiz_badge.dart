enum QuizBadge {
  none,
  bronze,
  silver,
  gold,
}

class BadgeHelper {
  // Badge thresholds based on performance score
  // Performance = score * (1 + timeFactor)
  // timeFactor = (maxTime - timeTaken) / maxTime
  // Gold: performance >= 22
  // Silver: performance >= 15 AND performance < 22
  // Bronze: performance >= 8 AND performance < 15
  // Grey (none): performance < 8
  
  static const double goldThreshold = 22.0;
  static const double silverThreshold = 15.0;
  static const double bronzeThreshold = 8.0;
  static const int maxTime = 300; // 5 minutes maximum time for 15 questions

  /// Calculate badge based on score and time taken
  /// 
  /// [score] - Number of correct answers (out of 15)
  /// [timeInSeconds] - Time taken to complete the quiz
  /// 
  /// Returns the badge based on performance calculation:
  /// performance = score * (1 + timeFactor)
  /// where timeFactor = (maxTime - timeTaken) / maxTime
  static QuizBadge getBadge(int score, int timeInSeconds) {
    // Calculate time factor (0 to 1, where 1 is fastest)
    // Clamp timeInSeconds to maxTime to prevent negative timeFactor
    final clampedTime = timeInSeconds > maxTime ? maxTime : timeInSeconds;
    final timeFactor = (maxTime - clampedTime) / maxTime;
    
    // Calculate performance score
    final performance = score * (1 + timeFactor);
    
    // Determine badge based on performance thresholds
    if (performance >= goldThreshold) {
      return QuizBadge.gold;
    } else if (performance >= silverThreshold && performance < goldThreshold) {
      return QuizBadge.silver;
    } else if (performance >= bronzeThreshold && performance < silverThreshold) {
      return QuizBadge.bronze;
    } else {
      return QuizBadge.none;
    }
  }

  static String getBadgeName(QuizBadge badge) {
    switch (badge) {
      case QuizBadge.gold:
        return 'Gold';
      case QuizBadge.silver:
        return 'Silver';
      case QuizBadge.bronze:
        return 'Bronze';
      case QuizBadge.none:
        return 'Grey';
    }
  }

  static String getBadgeString(QuizBadge badge) {
    switch (badge) {
      case QuizBadge.gold:
        return 'gold';
      case QuizBadge.silver:
        return 'silver';
      case QuizBadge.bronze:
        return 'bronze';
      case QuizBadge.none:
        return 'grey';
    }
  }

  static int getBadgeColor(QuizBadge badge) {
    switch (badge) {
      case QuizBadge.gold:
        return 0xFFFFD700; // Gold
      case QuizBadge.silver:
        return 0xFFC0C0C0; // Silver
      case QuizBadge.bronze:
        return 0xFFCD7F32; // Bronze
      case QuizBadge.none:
        return 0xFF808080; // Grey
    }
  }
}

