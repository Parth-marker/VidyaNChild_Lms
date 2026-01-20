import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/features/teachers/teacher_provider.dart';
import 'package:lms_project/features/teachers/teacher_search_results_page.dart';
import 'package:lms_project/features/teachers/teacher_tasks_page.dart';
import 'package:lms_project/models/timeline_model.dart';
import 'package:provider/provider.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TeacherProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: currentUser != null
            ? StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String userName = 'Teacher';
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    userName = data?['name'] as String? ?? 'Teacher';
                  }
                  return Text(
                    'Welcome back, $userName!',
                    style: AppTextStyles.h1Teal,
                  );
                },
              )
            : Text('Welcome back, Teacher!', style: AppTextStyles.h1Teal),
      ),
      body: SafeArea(
        child: teacher.loading
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: teacher.completionStats(),
                builder: (context, assignmentsSnapshot) {
                  // Get last 2 published worksheet assignments
                  final publishedWorksheets =
                      (assignmentsSnapshot.data ?? [])
                          .where(
                            (a) =>
                                (a['isPublished'] == true) &&
                                (a['type'] as String?) == 'Worksheet',
                          )
                          .toList()
                        ..sort((a, b) {
                          final aDate = a['publishedAt'] as Timestamp?;
                          final bDate = b['publishedAt'] as Timestamp?;
                          if (aDate == null && bDate == null) return 0;
                          if (aDate == null) return 1;
                          if (bDate == null) return -1;
                          return bDate.compareTo(aDate);
                        });

                  final last2Worksheets = publishedWorksheets.take(2).toList();

                  // Get last 2 drafts (sorted by updatedAt or createdAt)
                  final sortedDrafts =
                      List<Map<String, dynamic>>.from(teacher.drafts)
                        ..sort((a, b) {
                          final aDate =
                              a['updatedAt'] as Timestamp? ??
                              a['createdAt'] as Timestamp?;
                          final bDate =
                              b['updatedAt'] as Timestamp? ??
                              b['createdAt'] as Timestamp?;
                          if (aDate == null && bDate == null) return 0;
                          if (aDate == null) return 1;
                          if (bDate == null) return -1;
                          return bDate.compareTo(aDate);
                        });

                  final last2Drafts = sortedDrafts.take(2).toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TeacherSearchBar(
                          onSearchTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TeacherSearchResultsPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Recent Drafts',
                          children: last2Drafts.isEmpty
                              ? [
                                  Text(
                                    'No drafts yet. Create your first assignment!',
                                    style: AppTextStyles.body,
                                    textAlign: TextAlign.center,
                                  ),
                                ]
                              : last2Drafts.map((draft) {
                                  final assignmentType =
                                      draft['type'] as String? ?? '';
                                  IconData icon;
                                  if (assignmentType == 'Lesson') {
                                    icon = Icons.bookmark;
                                  } else {
                                    icon = Icons.edit_note;
                                  }

                                  String subtitle = 'Draft';
                                  if (draft['updatedAt'] is Timestamp) {
                                    final date =
                                        (draft['updatedAt'] as Timestamp)
                                            .toDate();
                                    final now = DateTime.now();
                                    final difference = now.difference(date);

                                    if (difference.inDays > 0) {
                                      subtitle =
                                          'Edited ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
                                    } else if (difference.inHours > 0) {
                                      subtitle =
                                          'Edited ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
                                    } else if (difference.inMinutes > 0) {
                                      subtitle =
                                          'Edited ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
                                    } else {
                                      subtitle = 'Just edited';
                                    }
                                  }

                                  return _TeacherDraftTile(
                                    icon: icon,
                                    title:
                                        draft['title'] as String? ??
                                        'Untitled Assignment',
                                    subtitle: subtitle,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TeacherTasksPage(),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Recent Submission %',
                          children: last2Worksheets.isEmpty
                              ? [
                                  Text(
                                    'No published worksheets yet.',
                                    style: AppTextStyles.body,
                                    textAlign: TextAlign.center,
                                  ),
                                ]
                              : last2Worksheets
                                    .map(
                                      (assignment) => _SubmissionStatTile(
                                        assignment: assignment,
                                        teacher: teacher,
                                      ),
                                    )
                                    .toList(),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Today\'s Timetable',
                          children: [
                            FutureBuilder<List<TimelineEvent>>(
                              future: teacher.getTodayTimetable(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final events = snapshot.data ?? [];
                                if (events.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      'No classes scheduled for today.',
                                      style: AppTextStyles.body.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: events.map((event) {
                                    final time =
                                        '${event.date.hour.toString().padLeft(2, '0')}:${event.date.minute.toString().padLeft(2, '0')}';
                                    return _ClassRow(
                                      time: time,
                                      topic: event.title,
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 0),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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

class _TeacherSearchBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _TeacherSearchBar({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onSearchTap,
      decoration: InputDecoration(
        hintText: 'Search class resources, assignments, etc.',
        hintStyle: AppTextStyles.body.copyWith(
          color: Colors.black45,
          fontSize: 14,
        ),
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
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 18,
        ),
      ),
    );
  }
}

class _TeacherDraftTile extends StatelessWidget {
  const _TeacherDraftTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.orange[50],
        child: Icon(icon, color: Colors.orange),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
      ),
      trailing: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[300],
          minimumSize: const Size(80, 38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Edit',
          style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14),
        ),
      ),
    );
  }
}

class _SubmissionStatTile extends StatelessWidget {
  const _SubmissionStatTile({required this.assignment, required this.teacher});

  final Map<String, dynamic> assignment;
  final TeacherProvider teacher;

  @override
  Widget build(BuildContext context) {
    final assignmentId = assignment['id'] as String? ?? '';
    final title = assignment['title'] as String? ?? 'Assignment';

    return StreamBuilder<Map<String, int>>(
      stream: teacher.getSubmissionStats(assignmentId),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ?? {'total': 0, 'submitted': 0, 'percentage': 0};
        final total = stats['total'] ?? 0;
        final submitted = stats['submitted'] ?? 0;
        final percentage = stats['percentage'] ?? 0;
        final percent = total > 0 ? (submitted / total) : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: AppTextStyles.body.copyWith(color: Colors.teal[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percent,
                minHeight: 10,
                borderRadius: BorderRadius.circular(12),
                color: Colors.teal[400],
                backgroundColor: Colors.teal[50],
              ),
              const SizedBox(height: 4),
              Text(
                '$submitted / $total submissions',
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.time, required this.topic});

  final String time;
  final String topic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              time,
              style: AppTextStyles.body.copyWith(color: Colors.teal[800]),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
