import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/features/teachers/teacher_provider.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:lms_project/features/auth/login_page.dart';
import 'package:lms_project/features/auth/auth_provider/auth_provider.dart';

class TeacherAnalyticsPage extends StatefulWidget {
  const TeacherAnalyticsPage({super.key});

  @override
  State<TeacherAnalyticsPage> createState() => _TeacherAnalyticsPageState();
}

class _TeacherAnalyticsPageState extends State<TeacherAnalyticsPage> {
  String? _currentStudentId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TeacherProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;
    final teacherId = currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Class Analytics', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _TeacherAccountCard(),
              const SizedBox(height: 16),
              if (teacherId != null)
                _LastQuizzesCard(teacherId: teacherId)
              else
                const _StaticFallbackPerformanceCard(),
              const SizedBox(height: 16),
              if (teacherId != null)
                _LatestAssignmentsParticipationCard(teacherId: teacherId),
              const SizedBox(height: 16),
              if (teacherId != null)
                _StudentQuizBarChartSection(
                  teacherId: teacherId,
                  currentStudentId: _currentStudentId,
                  onStudentChanged: (id) {
                    setState(() {
                      _currentStudentId = id;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 3),
    );
  }
}

class _TeacherAccountCard extends StatelessWidget {
  const _TeacherAccountCard();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return Container(
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            child: Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: currentUser != null
                ? StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String userName = 'Teacher';
                      if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        userName = data?['name'] as String? ?? 'Teacher';
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                          Text(FirebaseAuth.instance.currentUser?.email ?? '',
                              style: AppTextStyles.body
                                  .copyWith(fontSize: 13, color: Colors.black54)),
                        ],
                      );
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teacher',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      Text('Grade 7 • Mathematics',
                          style: AppTextStyles.body
                              .copyWith(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Log out',
                style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _StaticFallbackPerformanceCard extends StatelessWidget {
  const _StaticFallbackPerformanceCard();

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
          Text('Recent Quiz Performance',
              style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            'Sign in to see live quiz analytics for your class.',
            style: AppTextStyles.body
                .copyWith(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _LastQuizzesCard extends StatelessWidget {
  final String teacherId;

  const _LastQuizzesCard({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('quizSubmissions')
          .where('teacherId', isEqualTo: teacherId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard(title: 'Last 5 Quizzes');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyCard(
            title: 'Last 5 Quizzes',
            message:
                'No quiz submissions yet. Once students submit quizzes, you\'ll see class averages here.',
          );
        }

        final docs = snapshot.data!.docs;

        // Group by assignmentId
        final Map<String, List<QueryDocumentSnapshot>> byAssignment = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final assignmentId = data['assignmentId'] as String? ?? '';
          if (assignmentId.isEmpty) continue;
          byAssignment.putIfAbsent(assignmentId, () => []).add(doc);
        }

        // Sort assignments by latest submission time
        final assignments = byAssignment.entries.toList();
        assignments.sort((a, b) {
          Timestamp? getLatest(List<QueryDocumentSnapshot> list) {
            Timestamp? latest;
            for (final d in list) {
              final data = d.data() as Map<String, dynamic>;
              final ts = data['submittedAt'] as Timestamp?;
              if (ts == null) continue;
              if (latest == null || ts.compareTo(latest) > 0) {
                latest = ts;
              }
            }
            return latest;
          }

          final aTime = getLatest(a.value);
          final bTime = getLatest(b.value);
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        final lastFive = assignments.take(5).toList();

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
              Text('Last 5 Quizzes',
                  style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
              const SizedBox(height: 12),
              ...lastFive.map((entry) {
                final assignmentId = entry.key;
                final submissions = entry.value;

                double totalPercentage = 0;
                int count = 0;
                for (final doc in submissions) {
                  final data = doc.data() as Map<String, dynamic>;
                  final p = (data['percentage'] as num?)?.toDouble();
                  if (p != null) {
                    totalPercentage += p;
                    count++;
                  }
                }
                final avg = count > 0 ? (totalPercentage / count) : 0.0;

                return _QuizAverageTile(
                  assignmentId: assignmentId,
                  averagePercentage: avg,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _QuizAverageTile extends StatelessWidget {
  final String assignmentId;
  final double averagePercentage;

  const _QuizAverageTile({
    required this.assignmentId,
    required this.averagePercentage,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return FutureBuilder<DocumentSnapshot>(
      future: db.collection('assignments').doc(assignmentId).get(),
      builder: (context, snapshot) {
        String title = 'Quiz';
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          title = data?['title'] as String? ?? 'Quiz';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text('Class average',
                        style: AppTextStyles.body.copyWith(
                            fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
              Text(
                '${averagePercentage.toStringAsFixed(1)}%',
                style:
                    AppTextStyles.h1Purple.copyWith(fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LatestAssignmentsParticipationCard extends StatelessWidget {
  final String teacherId;

  const _LatestAssignmentsParticipationCard({required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('assignments')
          .where('teacherId', isEqualTo: teacherId)
          .where('status', isEqualTo: 'published')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard(title: 'Latest Assignments');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyCard(
            title: 'Latest Assignments',
            message:
                'Publish assignments to start tracking participation percentages.',
          );
        }

        // Filter to only quizzes and worksheets, then sort and take latest 3
        var docs = snapshot.data!.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final type = data['assignmentType'] as String? ?? '';
          return type == 'Quiz' || type == 'Worksheet';
        }).toList();

        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = aData['createdAt'] as Timestamp?;
          final bTime = bData['createdAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });
        docs = docs.take(3).toList();

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
                'Latest Assignments Participation',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] as String? ?? 'Assignment';
                final assignmentId = doc.id;
                final assignmentType =
                    data['assignmentType'] as String? ?? 'Worksheet';

                IconData icon;
                Color iconColor;
                Color iconBgColor;

                if (assignmentType == 'Quiz') {
                  icon = Icons.quiz;
                  iconColor = Colors.blue[600]!;
                  iconBgColor = Colors.blue[50]!;
                } else if (assignmentType == 'Worksheet') {
                  icon = Icons.assignment;
                  iconColor = Colors.teal[600]!;
                  iconBgColor = Colors.teal[50]!;
                } else {
                  icon = Icons.bookmark;
                  iconColor = Colors.purple[600]!;
                  iconBgColor = Colors.purple[50]!;
                }

                return StreamBuilder<Map<String, int>>(
                  stream: context
                      .read<TeacherProvider>()
                      .getSubmissionStats(assignmentId),
                  builder: (context, statsSnapshot) {
                    final stats = statsSnapshot.data;
                    final percentage = stats?['percentage'] ?? 0;
                    final submitted = stats?['submitted'] ?? 0;
                    final total = stats?['total'] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: iconBgColor,
                            child: Icon(icon, color: iconColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$assignmentType • $submitted of $total submitted',
                                  style: AppTextStyles.body.copyWith(
                                      fontSize: 13, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: AppTextStyles.h1Teal
                                .copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _StudentQuizBarChartSection extends StatelessWidget {
  final String teacherId;
  final String? currentStudentId;
  final ValueChanged<String?> onStudentChanged;

  const _StudentQuizBarChartSection({
    required this.teacherId,
    required this.currentStudentId,
    required this.onStudentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('quizSubmissions')
          .where('teacherId', isEqualTo: teacherId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard(title: 'Student Quiz Performance');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyCard(
            title: 'Student Quiz Performance',
            message:
                'No quiz submissions yet. Student score graphs will appear here once they submit quizzes.',
          );
        }

        final docs = snapshot.data!.docs;

        // Group submissions by studentId
        final Map<String, List<Map<String, dynamic>>> byStudent = {};
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final studentId = data['studentId'] as String? ?? '';
          if (studentId.isEmpty) continue;
          byStudent.putIfAbsent(studentId, () => []).add({
            ...data,
            'id': doc.id,
          });
        }

        if (byStudent.isEmpty) {
          return _EmptyCard(
            title: 'Student Quiz Performance',
            message:
                'No quiz submissions yet. Student score graphs will appear here once they submit quizzes.',
          );
        }

        final studentIds = byStudent.keys.toList();
        studentIds.sort();

        String effectiveStudentId = currentStudentId ?? studentIds.first;
        if (!byStudent.containsKey(effectiveStudentId)) {
          effectiveStudentId = studentIds.first;
        }

        final currentIndex = studentIds.indexOf(effectiveStudentId);
        final submissions = byStudent[effectiveStudentId]!;

        // Sort submissions by submittedAt ascending
        submissions.sort((a, b) {
          final aTime = a['submittedAt'] as Timestamp?;
          final bTime = b['submittedAt'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return -1;
          if (bTime == null) return 1;
          return aTime.compareTo(bTime);
        });

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Student Quiz Performance',
                      style:
                          AppTextStyles.h1Purple.copyWith(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    onPressed: currentIndex > 0
                        ? () => onStudentChanged(
                            studentIds[currentIndex - 1])
                        : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  IconButton(
                    onPressed: currentIndex < studentIds.length - 1
                        ? () => onStudentChanged(
                            studentIds[currentIndex + 1])
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StudentHeader(studentId: effectiveStudentId),
              const SizedBox(height: 12),
              if (submissions.isEmpty)
                Text(
                  'No quiz submissions for this student yet.',
                  style: AppTextStyles.body
                      .copyWith(color: Colors.black54),
                )
              else
                SizedBox(
                  height: 180,
                  child: _SimpleBarChart(
                    values: submissions
                        .map((s) =>
                            (s['percentage'] as num?)?.toDouble() ?? 0)
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StudentHeader extends StatelessWidget {
  final String studentId;

  const _StudentHeader({required this.studentId});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return StreamBuilder<DocumentSnapshot>(
      stream: db.collection('users').doc(studentId).snapshots(),
      builder: (context, snapshot) {
        String name = 'Student';
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          name = data?['name'] as String? ?? 'Student';
        }

        return Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.teal[50],
              child: Icon(Icons.person, color: Colors.teal[700]),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.body
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
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
                    height: 100 * (values[i] / effectiveMax).clamp(0.0, 1.0),
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
