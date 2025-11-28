import 'package:flutter/material.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/theme/app_text_styles.dart';

class TeacherTasksPage extends StatelessWidget {
  const TeacherTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                buttonLabel: 'Create',
                icon: Icons.add_task,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              Text('Drafts & Templates',
                  style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              const _AssignmentDraftTile(
                title: 'Integers Check-in',
                lastEdited: 'Edited 2 hrs ago',
                status: 'Awaiting publish',
              ),
              const _AssignmentDraftTile(
                title: 'Project Rubric',
                lastEdited: 'Edited yesterday',
                status: 'Ready to assign',
              ),
              const SizedBox(height: 16),
              Text('Completion Status',
                  style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              const _CompletionRow(
                title: 'Fractions Practice Set',
                submitted: '28 / 32 turned in',
                percent: 0.87,
              ),
              const _CompletionRow(
                title: 'Geometry Lab Report',
                submitted: '24 / 32 turned in',
                percent: 0.75,
              ),
              const _CompletionRow(
                title: 'Weekly Reflection',
                submitted: '19 / 32 turned in',
                percent: 0.59,
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
                Text(title,
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.body
                        .copyWith(fontSize: 13, color: Colors.black54)),
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
            child: Text(buttonLabel,
                style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
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
                Text(title,
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text('${(percent * 100).round()}%',
                    style: AppTextStyles.body.copyWith(color: Colors.teal[700])),
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
            Text(submitted,
                style: AppTextStyles.body
                    .copyWith(fontSize: 13, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

