import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';

class AIStudyPlanPage extends StatelessWidget {
  const AIStudyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Your AI Study Plan', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlanTile(subject: 'Algebra Practice Sets', tag: 'Linear equations'),
            _PlanTile(subject: 'Fractions Drill', tag: 'Add/Subtract/Compare'),
            _PlanTile(subject: 'Geometry Proofs', tag: 'Angles & Triangles'),
            _PlanTile(subject: 'Word Problems', tag: 'Two-step problems'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[400], minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text('Start Plan', style: AppTextStyles.buttonPrimary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), side: BorderSide(color: Colors.purple[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text('Edit Plan', style: AppTextStyles.linkPurple),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String subject;
  final String tag;
  const _PlanTile({required this.subject, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
      ]),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.purple[50], child: const Icon(Icons.task_alt_rounded, color: Colors.purple)),
        title: Text(subject, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(tag, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        trailing: Switch(value: true, onChanged: (_) {}),
      ),
    );
  }
}


