import 'package:flutter/material.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/features/teachers/teacher_provider.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class TeacherTasksPage extends StatefulWidget {
  const TeacherTasksPage({super.key});

  @override
  State<TeacherTasksPage> createState() => _TeacherTasksPageState();
}

class _TeacherTasksPageState extends State<TeacherTasksPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TeacherProvider>().loadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tasks & Assignments', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ActionCard(
                title: 'Create New Assignment',
                subtitle: 'Design a fresh worksheet, quiz, or project brief.',
                buttonLabel: teacher.saving ? 'Saving...' : 'Create',
                icon: Icons.add_task,
                onPressed: teacher.saving
                    ? () {}
                    : () async {
                        final id = await teacher.createAssignment({
                          'title': 'New Assignment',
                          'status': 'draft',
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                id == null
                                    ? 'Failed to create'
                                    : 'Draft created',
                              ),
                            ),
                          );
                        }
                      },
              ),
              const SizedBox(height: 16),
              Text(
                'Drafts & Templates',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ...(teacher.drafts.isNotEmpty
                      ? teacher.drafts
                      : [
                          {
                            'title': 'Integers Check-in',
                            'lastEdited': 'Edited 2 hrs ago',
                            'status': 'Awaiting publish',
                          },
                          {
                            'title': 'Project Rubric',
                            'lastEdited': 'Edited yesterday',
                            'status': 'Ready to assign',
                          },
                        ])
                  .map(
                    (d) => _AssignmentDraftTile(
                      title: d['title'] as String,
                      lastEdited: d['lastEdited'] as String? ?? '',
                      status: d['status'] as String? ?? '',
                    ),
                  ),
              const SizedBox(height: 16),
              Text(
                'Completion Status',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: teacher.completionStats(),
                builder: (context, snapshot) {
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Column(
                      children: const [
                        _CompletionRow(
                          title: 'Fractions Practice Set',
                          submitted: '28 / 32 turned in',
                          percent: 0.87,
                        ),
                        _CompletionRow(
                          title: 'Geometry Lab Report',
                          submitted: '24 / 32 turned in',
                          percent: 0.75,
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: items
                        .map(
                          (i) => _CompletionRow(
                            title: i['title'] as String? ?? 'Assignment',
                            submitted: i['submitted'] as String? ?? '',
                            percent: (i['percent'] as num?)?.toDouble() ?? 0.0,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 2),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.teal[600]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonLabel,
              style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentDraftTile extends StatelessWidget {
  const _AssignmentDraftTile({
    required this.title,
    required this.lastEdited,
    required this.status,
  });

  final String title;
  final String lastEdited;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal[50],
          child: const Icon(Icons.assignment_outlined, color: Colors.teal),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lastEdited,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            Text(
              status,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: Colors.teal[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {},
        ),
      ),
    );
  }
}

class _CompletionRow extends StatelessWidget {
  const _CompletionRow({
    required this.title,
    required this.submitted,
    required this.percent,
  });

  final String title;
  final String submitted;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(percent * 100).round()}%',
                  style: AppTextStyles.body.copyWith(color: Colors.teal[700]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.teal[400],
              backgroundColor: Colors.teal[50],
            ),
            const SizedBox(height: 6),
            Text(
              submitted,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
