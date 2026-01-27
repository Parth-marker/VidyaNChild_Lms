import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/games/quiz_storage.dart';
import 'package:lms_project/features/games/number_sequence_game_page.dart';

class NumberSequenceIntroPage extends StatefulWidget {
  const NumberSequenceIntroPage({super.key});

  @override
  State<NumberSequenceIntroPage> createState() =>
      _NumberSequenceIntroPageState();
}

class _NumberSequenceIntroPageState extends State<NumberSequenceIntroPage> {
  int? bestTime;
  int? bestScore;
  String? bestBadge;

  @override
  void initState() {
    super.initState();
    _loadBestResult();
  }

  Future<void> _loadBestResult() async {
    final time = await QuizStorage.getSequenceBestTime();
    final score = await QuizStorage.getSequenceBestScore();
    final badge = await QuizStorage.getSequenceBestBadge();

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
        title: Text('Pattern Hunt', style: AppTextStyles.h1Teal),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                Icons.question_mark,
                size: 80,
                color: Colors.purple[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Pattern Hunt',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 28),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '20 questions • Spot the missing term!',
                style: AppTextStyles.body
                    .copyWith(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Best Score Display
              _BestSequenceScoreCard(
                time: bestTime,
                score: bestScore,
                badge: bestBadge,
              ),

              const SizedBox(height: 48),

              // Play Button
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NumberSequenceGamePage(),
                    ),
                  );

                  if (result == true) {
                    _loadBestResult();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[400],
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Start Puzzle',
                      style: AppTextStyles.buttonPrimary.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Instructions / Medal requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.purple[400], size: 20),
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
                    _InstructionItem('Answer 20 pattern-recognition questions'),
                    _InstructionItem(
                        'First 12 are medium, last 8 are hard difficulty'),
                    _InstructionItem(
                        'Each correct answer gives 1 point (max 20)'),
                    const SizedBox(height: 12),
                    Text(
                      'Medal Requirements',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InstructionItem(
                        'Gold: ≥18 correct AND finished in ≤5 minutes'),
                    _InstructionItem(
                        'Silver: ≥15 correct AND finished in ≤8 minutes'),
                    _InstructionItem(
                        'Bronze: ≥12 correct AND finished in ≤10 minutes'),
                    _InstructionItem('Below this: Grey'),
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BestSequenceScoreCard extends StatelessWidget {
  final int? time;
  final int? score;
  final String? badge;

  const _BestSequenceScoreCard({
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
            'Best Attempt',
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
                  '${score}/20',
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
              color: Colors.purple[400],
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


