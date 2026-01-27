import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/games/quick_math_challenge_page.dart';
import 'package:lms_project/features/games/number_sequence_intro_page.dart';
import 'package:lms_project/features/games/quiz_storage.dart';

class MathPuzzlesPage extends StatefulWidget {
  const MathPuzzlesPage({super.key});

  @override
  State<MathPuzzlesPage> createState() => _MathPuzzlesPageState();
}

class _MathPuzzlesPageState extends State<MathPuzzlesPage> {
  int? bestScore;
  String? bestBadge;
  int? seqBestScore;
  String? seqBestBadge;

  @override
  void initState() {
    super.initState();
    _loadBestResult();
  }

  Future<void> _loadBestResult() async {
    final score = await QuizStorage.getBestScore();
    final badge = await QuizStorage.getBestBadge();
    final seqScore = await QuizStorage.getSequenceBestScore();
    final seqBadge = await QuizStorage.getSequenceBestBadge();
    
    setState(() {
      bestScore = score;
      bestBadge = badge;
      seqBestScore = seqScore;
      seqBestBadge = seqBadge;
    });
  }

  Color _getBadgeColor(String? badge) {
    switch (badge?.toLowerCase()) {
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey[400]!;
      case 'bronze':
        return Colors.brown[400]!;
      case 'grey':
      case 'none':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Puzzles', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a game', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            _PuzzleCard(
              title: 'Math Blitz',
              description: 'Test your skills with a series of quick math problems. Score points for each correct answer.',
              icon: Icons.flash_on,
              iconColor: Colors.teal,
              score: bestScore,
              badge: bestBadge,
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QuickMathChallengePage(),
                  ),
                );
                if (result == true) {
                  _loadBestResult();
                }
              },
              getBadgeColor: _getBadgeColor,
              maxScore: 15,
            ),
            const SizedBox(height: 16),
            _PuzzleCard(
              title: 'Pattern Hunt',
              description: 'Recognise patterns in number sequences and fill in the missing term.',
              icon: Icons.numbers,
              iconColor: Colors.purple,
              score: seqBestScore,
              badge: seqBestBadge,
              onTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NumberSequenceIntroPage(),
                  ),
                );
                if (result == true) {
                  _loadBestResult();
                }
              },
              getBadgeColor: _getBadgeColor,
              maxScore: 20,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4),
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final int? score;
  final String? badge;
  final VoidCallback? onTap;
  final Color Function(String?) getBadgeColor;
  final int maxScore;

  const _PuzzleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.score,
    this.badge,
    this.onTap,
    required this.getBadgeColor,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Image/Icon and Name | Score with Badge
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Puzzle image/icon and name
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Score with badge
                if (score != null && badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: getBadgeColor(badge).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: getBadgeColor(badge), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score/$maxScore',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: getBadgeColor(badge),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getBadgeColor(badge),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!.toUpperCase(),
                            style: AppTextStyles.body.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Play button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Play',
                  style: AppTextStyles.buttonPrimary.copyWith(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              description,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
