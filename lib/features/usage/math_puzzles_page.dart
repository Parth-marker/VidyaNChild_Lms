import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/games/quick_math_challenge_page.dart';

class MathPuzzlesPage extends StatelessWidget {
  const MathPuzzlesPage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a game', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
            const SizedBox(height: 12),
            _PuzzleCard(
              title: 'Quick Math Challenge',
              description: 'Test your skills with a series of quick math problems. Score points for each correct answer.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const QuickMathChallengePage(),
                  ),
                );
              },
            ),
            const _PuzzleCard(
              title: 'Number Sequence',
              description: 'Complete the number sequence by finding the missing values.',
            ),
            const _PuzzleCard(
              title: 'Math Adventure',
              description: 'Embark on a math adventure with fun challenges and puzzles.',
            ),
            const SizedBox(height: 8),
            Text('Popular Categories', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: const [
                _CategoryChip('Algebra'),
                _CategoryChip('Fractions'),
                _CategoryChip('Geometry'),
                _CategoryChip('Word Problems'),
              ],
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
  final VoidCallback? onTap;
  const _PuzzleCard({required this.title, required this.description, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: Colors.teal[100], borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.extension_rounded, color: Colors.teal),
        ),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(description, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        trailing: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: Text('Play', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
        ),
      ),
    );
  }
}

// Removed legacy local BottomBar; shared AppBottomNavBar is used instead.

class _CategoryChip extends StatelessWidget {
  final String text;
  const _CategoryChip(this.text);
  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.teal[50],
      label: Text(text, style: AppTextStyles.body.copyWith(fontSize: 13)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}


