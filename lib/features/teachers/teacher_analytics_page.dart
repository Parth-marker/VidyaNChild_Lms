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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TeacherProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              const _PerformanceCard(),
              const SizedBox(height: 16),
              const _TrendCard(),
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
          const CircleAvatar(radius: 28, child: Icon(Icons.person_outline)),
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
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        userName = data?['name'] as String? ?? 'Teacher';
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ?? '',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teacher',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Grade 7 • Mathematics',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
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
            child: Text(
              'Log out',
              style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: teacher.getClassPerformance(),
      builder: (context, snapshot) {
        final performances = snapshot.data ?? [];

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
                'Recent Assignments Performance',
                style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),
              if (performances.isEmpty)
                Text(
                  'No assignment data yet.',
                  style: AppTextStyles.body.copyWith(color: Colors.black54),
                ),
              ...performances.map(
                (test) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test['label'] as String,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Class average',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        test['avg'] as String,
                        style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Icon(test['trend'] as IconData, color: Colors.teal[600]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherProvider>();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: teacher.getTrendStats(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (items.isEmpty) return const SizedBox.shrink();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              decoration: BoxDecoration(
                color: item['color'] as Color?,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['label'] as String,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item['value'] as String,
                    style: AppTextStyles.h1Purple.copyWith(fontSize: 22),
                  ),
                  Text(
                    item['detail'] as String,
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
      },
    );
  }
}
