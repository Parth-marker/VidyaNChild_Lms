import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/games/quiz_storage.dart';
import 'package:lms_project/features/games/quiz_game_page.dart';

class QuickMathChallengePage extends StatefulWidget {
  const QuickMathChallengePage({super.key});

  @override
  State<QuickMathChallengePage> createState() => _QuickMathChallengePageState();
}

class _QuickMathChallengePageState extends State<QuickMathChallengePage> {
  int? bestTime;
  int? bestScore;
  String? bestBadge;

  @override
  void initState() {
    super.initState();
    _loadBestResult();
  }

  Future<void> _loadBestResult() async {
    final time = await QuizStorage.getBestTime();
    final score = await QuizStorage.getBestScore();
    final badge = await QuizStorage.getBestBadge();
    
    setState(() {
      bestTime = time;
      bestScore = score;
      bestBadge = badge;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Quick Math Challenge', style: AppTextStyles.h1Teal),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Icon/Title
              Icon(
                Icons.flash_on,
                size: 80,
                color: Colors.teal[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Rapid Fire Quiz',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '15 Questions • Beat the Clock!',
                style: AppTextStyles.body.copyWith(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Best Score Display
              if (bestTime != null && bestScore != null && bestBadge != null)
                _BestScoreCard(
                  time: bestTime!,
                  score: bestScore!,
                  badge: bestBadge!,
                )
              else
                _BestScoreCard(
                  time: null,
                  score: null,
                  badge: null,
                ),
              
              const SizedBox(height: 48),
              
              // Play Button
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const QuizGamePage(),
                    ),
                  );
                  
                  // Reload best result after game
                  if (result == true) {
                    _loadBestResult();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[400],
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Start Challenge',
                      style: AppTextStyles.buttonPrimary.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.teal[400], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'How to Play',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InstructionItem('Answer 15 random questions'),
                    _InstructionItem('Complete as fast as you can'),
                    _InstructionItem('Badges are based on performance: score × (1 + time bonus)'),
                    _InstructionItem('Gold: ≥22 • Silver: ≥15 • Bronze: ≥8'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BestScoreCard extends StatelessWidget {
  final int? time;
  final int? score;
  final String? badge;

  const _BestScoreCard({
    required this.time,
    required this.score,
    required this.badge,
  });

  Color _getBadgeColor() {
    if (badge == null) return const Color(0xFF808080); // Grey
    
    switch (badge!.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'bronze':
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF808080);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Best Round',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (time != null && score != null)
            Column(
              children: [
                Text(
                  '${score}/15',
                  style: AppTextStyles.h1Purple.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(time!),
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    badge!.toUpperCase(),
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            )
          else
            Text(
              'No record yet',
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String text;
  
  const _InstructionItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.teal[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

