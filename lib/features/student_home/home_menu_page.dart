import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_project/features/student_services/student_assignment_provider.dart';
import 'package:lms_project/features/games/quiz_storage.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/student_home/search_results_page.dart';
import 'package:lms_project/features/student_services/digitized_assignments_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeMenuPage extends StatefulWidget {
  const HomeMenuPage({super.key});

  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage> {
  Future<Map<String, dynamic>> _getLatestPuzzleScore() async {
    final quickScore = await QuizStorage.getBestScore();
    final quickTime = await QuizStorage.getBestTime();
    final quickBadge = await QuizStorage.getBestBadge();

    final seqScore = await QuizStorage.getSequenceBestScore();
    final seqBadge = await QuizStorage.getSequenceBestBadge();

    if (quickScore == null &&
        quickTime == null &&
        quickBadge == null &&
        seqScore == null &&
        seqBadge == null) {
      return {};
    }

    return {
      'quickScore': quickScore,
      'quickTime': quickTime,
      'quickBadge': quickBadge,
      'seqScore': seqScore,
      'seqBadge': seqBadge,
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: currentUser != null
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
                  return Text('Welcome back, $userName!', style: AppTextStyles.h1Teal);
                },
              )
            : Text('Welcome back!', style: AppTextStyles.h1Teal),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SearchBar(onSearchTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SearchResultsPage()),
                          );
                        }),
                        const SizedBox(height: 16),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _getLatestPuzzleScore(),
                          builder: (context, puzzleSnapshot) {
                            if (puzzleSnapshot.hasData && puzzleSnapshot.data != null) {
                              final puzzleData = puzzleSnapshot.data!;
                              if (puzzleData.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return _SectionCard(
                                title: 'Latest Puzzle Scores',
                                children: [
                                  _PuzzleScoreTile(
                                    quickScore: puzzleData['quickScore'] as int?,
                                    quickTime: puzzleData['quickTime'] as int?,
                                    quickBadge: puzzleData['quickBadge'] as String?,
                                    seqScore: puzzleData['seqScore'] as int?,
                                    seqBadge: puzzleData['seqBadge'] as String?,
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: context.read<StudentAssignmentProvider>().getMyQuizSubmissions(),
                          builder: (context, submissionsSnapshot) {
                            final submissions = submissionsSnapshot.data ?? [];
                            final last3Submissions = submissions.take(3).toList();

                            return _SectionCard(
                              title: 'Recent Submissions',
                              children: last3Submissions.isEmpty
                                  ? [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          'No submissions yet. Complete a quiz to see your results here!',
                                          style: AppTextStyles.body.copyWith(
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ]
                                  : last3Submissions.map((submission) {
                                      return _SubmissionTile(
                                        submission: submission,
                                        assignmentProvider: context.read<StudentAssignmentProvider>(),
                                      );
                                    }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: context.read<StudentAssignmentProvider>().getRecentWorksheetsAndLessons(),
                          builder: (context, assignmentsSnapshot) {
                            final assignments = assignmentsSnapshot.data ?? [];

                            return _SectionCard(
                              title: 'Recent Uploads',
                              children: assignments.isEmpty
                                  ? [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          'No recent worksheets or lessons available.',
                                          style: AppTextStyles.body.copyWith(
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ]
                                  : assignments.map((assignment) {
                                      return _RecentUploadTile(
                                        assignment: assignment,
                                      );
                                    }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

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
          Text(title, style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _SearchBar({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onSearchTap,
      decoration: InputDecoration(
        hintText: 'Search for math lesson materials',
        hintStyle: AppTextStyles.body.copyWith(color: Colors.black45, fontSize: 14),
        prefixIcon: IconButton(
          icon: const Icon(Icons.search, color: Colors.teal),
          onPressed: onSearchTap,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    );
  }
}



class _SubmissionTile extends StatelessWidget {
  final Map<String, dynamic> submission;
  final StudentAssignmentProvider assignmentProvider;

  const _SubmissionTile({
    required this.submission,
    required this.assignmentProvider,
  });

  String _formatDate(dynamic submittedAt) {
    if (submittedAt == null) return 'Unknown date';
    try {
      Timestamp timestamp;
      if (submittedAt is Timestamp) {
        timestamp = submittedAt;
      } else {
        return 'Invalid date';
      }
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentId = submission['assignmentId'] as String? ?? '';
    final score = submission['score'] as int?;
    final total = submission['totalQuestions'] as int?;
    final percentage = submission['percentage'] as double?;
    final submittedAt = submission['submittedAt'];

    return FutureBuilder<Map<String, dynamic>?>(
      future: assignmentProvider.getAssignment(assignmentId),
      builder: (context, snapshot) {
        final assignment = snapshot.data;
        final title = assignment?['title'] as String? ?? 'Quiz';

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.quiz, color: Colors.blue[600]),
          ),
          title: Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(submittedAt),
                style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
              ),
              if (score != null && total != null)
                Text(
                  'Score: $score/$total (${percentage?.toStringAsFixed(1)}%)',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: percentage! >= 80
                        ? Colors.green[700]
                        : percentage >= 60
                            ? Colors.blue[700]
                            : Colors.orange[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          trailing: Icon(Icons.check_circle, color: Colors.green[600]),
        );
      },
    );
  }
}

class _PuzzleScoreTile extends StatelessWidget {
  final int? quickScore;
  final int? quickTime;
  final String? quickBadge;
  final int? seqScore;
  final String? seqBadge;

  const _PuzzleScoreTile({
    required this.quickScore,
    required this.quickTime,
    required this.quickBadge,
    required this.seqScore,
    required this.seqBadge,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
    if ((quickScore == null || quickTime == null) && seqScore == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No puzzle scores yet. Try a math puzzle!',
          style: AppTextStyles.body.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.extension, color: Colors.purple[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Math Blitz',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (quickBadge != null && quickBadge!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(quickBadge).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getBadgeColor(quickBadge), width: 2),
                        ),
                        child: Text(
                          quickBadge!.toUpperCase(),
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getBadgeColor(quickBadge),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (quickScore != null && quickTime != null) ...[
                      Text(
                        'Score: $quickScore/15',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Time: ${_formatTime(quickTime!)}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ] else
                      Text(
                        'No score yet',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pattern Hunt',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (seqBadge != null && seqBadge!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getBadgeColor(seqBadge).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _getBadgeColor(seqBadge), width: 2),
                        ),
                        child: Text(
                          seqBadge!.toUpperCase(),
                          style: AppTextStyles.body.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getBadgeColor(seqBadge),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  seqScore != null ? 'Score: $seqScore/20' : 'No score yet',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentUploadTile extends StatelessWidget {
  final Map<String, dynamic> assignment;

  const _RecentUploadTile({required this.assignment});

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return 'Unknown date';
    try {
      Timestamp timestamp;
      if (createdAt is Timestamp) {
        timestamp = createdAt;
      } else {
        return 'Invalid date';
      }
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = assignment['title'] as String? ?? 'Untitled';
    final assignmentType = assignment['assignmentType'] as String? ?? '';
    final createdAt = assignment['createdAt'];

    IconData icon;
    Color iconColor;
    Color iconBgColor;

    if (assignmentType == 'Lesson') {
      icon = Icons.bookmark;
      iconColor = Colors.purple[600]!;
      iconBgColor = Colors.purple[50]!;
    } else {
      icon = Icons.description_outlined;
      iconColor = Colors.teal[600]!;
      iconBgColor = Colors.teal[50]!;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: iconBgColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            assignmentType,
            style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
          ),
          Text(
            _formatDate(createdAt),
            style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DigitizedAssignmentsPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[300],
          minimumSize: const Size(80, 38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('View', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
      ),
    );
  }
}

