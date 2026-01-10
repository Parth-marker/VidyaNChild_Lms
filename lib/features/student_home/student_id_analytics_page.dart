import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/student_services/ai_study_plan_page.dart';
import 'package:lms_project/features/auth/login_page.dart';
import 'package:provider/provider.dart';
import 'package:lms_project/features/auth/auth_provider/auth_provider.dart';

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
              _ScoreGrid(),
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

class _ScoreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {'subject': 'Integers', 'score': '92%'},
      {'subject': 'Fractions', 'score': '85%'},
      {'subject': 'Data Handling', 'score': '75%'},
      {'subject': 'Decimals Drill', 'score': '70%'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.8),
      itemBuilder: (context, index) {
        final subject = items[index]['subject']!;
        final score = items[index]['score']!;
        final isAlert = subject == 'Mastery';
        return Container(
          decoration: BoxDecoration(
            color: isAlert ? Colors.red[50] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(subject, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(score, style: AppTextStyles.h1Purple.copyWith(fontSize: 20)),
              ]),
              Icon(isAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: isAlert ? Colors.red : Colors.teal),
            ],
          ),
        );
      },
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


