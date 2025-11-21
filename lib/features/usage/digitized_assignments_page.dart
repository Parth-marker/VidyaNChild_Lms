import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';

class DigitizedAssignmentsPage extends StatelessWidget {
  const DigitizedAssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Assignments', style: AppTextStyles.h1Teal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Math', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            const _AssignmentTile(title: 'Fractions', due: '2024-05-15'),
            const _AssignmentTile(title: 'Geometry', due: '2024-05-15'),
            const _AssignmentTile(title: 'Algebra', due: '2024-05-15'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ]),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: Colors.teal),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Learning Summary', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Open', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[400],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: Text('Upload Completed Assignments', style: AppTextStyles.buttonPrimary),
            ),
            const SizedBox(height: 30),
            Text('Recent Submissions', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  _SubmissionTile(title: 'Decimals Drill', date: 'Submitted today'),
                  _SubmissionTile(title: 'Angles Worksheet', date: 'Submitted 2 days ago'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final String title;
  final String due;
  const _AssignmentTile({required this.title, required this.due});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.teal[50], child: const Icon(Icons.description_outlined, color: Colors.teal)),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('Due: $due', style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final String title;
  final String date;
  const _SubmissionTile({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.purple[50], child: const Icon(Icons.check_circle_outline, color: Colors.purple)),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}


