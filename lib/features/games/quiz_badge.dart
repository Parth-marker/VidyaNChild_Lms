enum QuizBadge {
  none,
  bronze,
  silver,
  gold,
}

class BadgeHelper {
  // Badge thresholds (in seconds)
  // Gold: < 60 seconds (1 minute)
  // Silver: < 120 seconds (2 minutes)
  // Bronze: < 180 seconds (3 minutes)
  // None: >= 180 seconds
  
  static const int goldThreshold = 60;
  static const int silverThreshold = 120;
  static const int bronzeThreshold = 180;

  static QuizBadge getBadge(int timeInSeconds) {
    if (timeInSeconds < goldThreshold) {
      return QuizBadge.gold;
    } else if (timeInSeconds < silverThreshold) {
      return QuizBadge.silver;
    } else if (timeInSeconds < bronzeThreshold) {
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
        return 'None';
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
        return 'none';
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

