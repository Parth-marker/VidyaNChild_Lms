import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/student_services/ai_study_plan_page.dart';
import 'package:lms_project/features/auth/login_page.dart';
import 'package:provider/provider.dart';
import 'package:lms_project/features/auth/auth_provider/auth_provider.dart';
import 'package:lms_project/features/student_services/student_assignment_provider.dart';
import 'package:lms_project/features/games/quiz_storage.dart';

class StudentIdAnalyticsPage extends StatelessWidget {
  const StudentIdAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Student ID & Analytics', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _ProfileHeader(),
              const SizedBox(height: 16),
              const _StudentQuizBarChartCard(),
              const SizedBox(height: 16),
              const _StudentSubmissionStatsCard(),
              const SizedBox(height: 16),
              const _PuzzleSummaryCard(),
              const SizedBox(height: 16),
              _AlertCard(
                title: 'Decimals',
                message:
                    'Unit 2 scores are trending down. Focus on decimal concepts and data handlingis recommended to build a stronger foundation.',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ]),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(radius: 28, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: currentUser != null
                ? StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String userName = 'Student';
                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        userName = data?['name'] as String? ?? 'Student';
                      }
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(userName, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                        Text(currentUser.email ?? '', style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
                      ]);
                    },
                  )
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Student', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('', style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
                  ]),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Log out', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _StudentQuizBarChartCard extends StatelessWidget {
  const _StudentQuizBarChartCard();

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = context.read<StudentAssignmentProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: assignmentProvider.getMyQuizSubmissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard(title: 'Your Quiz Performance');
        }

        final submissions = snapshot.data ?? [];

        if (submissions.isEmpty) {
          return _EmptyCard(
            title: 'Your Quiz Performance',
            message:
                'No quiz submissions yet. Complete a quiz to see your score trend.',
          );
        }

        // Sort by submittedAt ascending
        submissions.sort((a, b) {
          final aTime = a['submittedAt'] as Timestamp?;
          final bTime = b['submittedAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return -1;
          if (bTime == null) return 1;
          return aTime.compareTo(bTime);
        });

        final values = submissions
            .map((s) => (s['percentage'] as num?)?.toDouble() ?? 0)
            .toList();

        return Container(
          width: double.infinity,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Quiz Performance',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: _SimpleBarChart(values: values),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentSubmissionStatsCard extends StatelessWidget {
  const _StudentSubmissionStatsCard();

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = context.read<StudentAssignmentProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: assignmentProvider.getPublishedAssignments(),
      builder: (context, assignmentsSnapshot) {
        final assignments = assignmentsSnapshot.data ?? [];

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: assignmentProvider.getMySubmissions(),
          builder: (context, submissionsSnapshot) {
            final submissions = submissionsSnapshot.data ?? [];

            final quizzes = assignments
                .where((a) => a['assignmentType'] == 'Quiz')
                .toList();
            final worksheets = assignments
                .where((a) => a['assignmentType'] == 'Worksheet')
                .toList();

            final quizSubmissions = submissions
                .where((s) => s['assignmentType'] == 'Quiz')
                .toList();
            final worksheetSubmissions = submissions
                .where((s) => s['assignmentType'] == 'Worksheet')
                .toList();

            final quizPercentage = quizzes.isEmpty
                ? 0
                : ((quizSubmissions.length / quizzes.length) * 100)
                    .round();
            final worksheetPercentage = worksheets.isEmpty
                ? 0
                : ((worksheetSubmissions.length / worksheets.length) * 100)
                    .round();

            return Container(
              width: double.infinity,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Submissions',
                    style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _SubmissionStatRow(
                    label: 'Quizzes submitted',
                    percentage: quizPercentage,
                  ),
                  const SizedBox(height: 8),
                  _SubmissionStatRow(
                    label: 'Worksheets submitted',
                    percentage: worksheetPercentage,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SubmissionStatRow extends StatelessWidget {
  final String label;
  final int percentage;

  const _SubmissionStatRow({
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$percentage%',
          style: AppTextStyles.h1Teal.copyWith(fontSize: 18),
        ),
      ],
    );
  }
}

class _PuzzleSummaryCard extends StatelessWidget {
  const _PuzzleSummaryCard();

  Future<Map<String, dynamic>> _loadPuzzleScores() async {
    final bestScore = await QuizStorage.getBestScore();
    final bestBadge = await QuizStorage.getBestBadge();
    final seqScore = await QuizStorage.getSequenceBestScore();
    final seqBadge = await QuizStorage.getSequenceBestBadge();

    // For now only Quick Math Challenge has persisted scores.
    return {
      'quickMathScore': bestScore,
      'quickMathBadge': bestBadge,
      'sequenceScore': seqScore,
      'sequenceBadge': seqBadge,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadPuzzleScores(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final quickMathScore = data['quickMathScore'] as int?;
        final quickMathBadge = data['quickMathBadge'] as String?;
        final sequenceScore = data['sequenceScore'] as int?;
        final sequenceBadge = data['sequenceBadge'] as String?;

        return Container(
          width: double.infinity,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Latest Puzzle Scores',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              _PuzzleScoreRow(
                title: 'Math Blitz',
                score: quickMathScore,
                badge: quickMathBadge,
                maxScore: 15,
              ),
              const SizedBox(height: 8),
              _PuzzleScoreRow(
                title: 'Pattern Hunt',
                score: sequenceScore,
                badge: sequenceBadge,
                maxScore: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PuzzleScoreRow extends StatelessWidget {
  final String title;
  final int? score;
  final String? badge;
  final int maxScore;

  const _PuzzleScoreRow({
    required this.title,
    required this.score,
    required this.badge,
    required this.maxScore,
  });

  Color _getBadgeColor(String? badge) {
    switch (badge?.toLowerCase()) {
      case 'gold':
        return Colors.amber;
      case 'silver':
        return Colors.grey;
      case 'bronze':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (score != null)
          Text(
            '$score/$maxScore',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Text(
            'No score yet',
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        const SizedBox(width: 8),
        if (badge != null && badge!.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getBadgeColor(badge).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge!.toUpperCase(),
              style: AppTextStyles.body.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getBadgeColor(badge),
              ),
            ),
          ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String message;
  const _AlertCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ]),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Areas for Improvement', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.trending_down, color: Colors.red),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Text(message, style: AppTextStyles.body.copyWith(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AIStudyPlanPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 26, 122, 111),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text('Create AI Study Plan', style: AppTextStyles.buttonPrimary),
        ),
      ]),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String title;

  const _LoadingCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyCard({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.body
                .copyWith(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<double> values;

  const _SimpleBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Center(
        child: Text(
          'No data',
          style: AppTextStyles.body.copyWith(color: Colors.black54),
        ),
      );
    }

    final maxValue = values.fold<double>(
        0, (previousValue, element) => element > previousValue ? element : previousValue);
    final effectiveMax = maxValue > 0 ? maxValue : 100;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${values[i].toStringAsFixed(0)}%',
                    style: AppTextStyles.body
                        .copyWith(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height:
                        100 * (values[i] / effectiveMax).clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: Colors.teal[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Q${i + 1}',
                    style: AppTextStyles.body
                        .copyWith(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

