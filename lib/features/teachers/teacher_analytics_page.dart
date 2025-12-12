import 'package:flutter/material.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/features/teachers/teacher_provider.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class TeacherAnalyticsPage extends StatefulWidget {
  const TeacherAnalyticsPage({super.key});

  @override
  State<TeacherAnalyticsPage> createState() => _TeacherAnalyticsPageState();
}

class _TeacherAnalyticsPageState extends State<TeacherAnalyticsPage> {
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
              _TrendGrid(items: teacher.analytics),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ms. Riya Rao',
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text('Grade 7 • Mathematics',
                    style: AppTextStyles.body
                        .copyWith(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Card',
                style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  List<Map<String, dynamic>> get _tests => const [
        {'label': 'Unit Test 4', 'avg': '89%', 'trend': Icons.trending_up},
        {'label': 'Unit Test 3', 'avg': '82%', 'trend': Icons.trending_up},
        {'label': 'Unit Test 2', 'avg': '76%', 'trend': Icons.trending_flat},
        {'label': 'Unit Test 1', 'avg': '68%', 'trend': Icons.trending_down},
      ];

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
          Text('Last 4 Tests',
              style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ..._tests.map(
            (test) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(test['label'] as String,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600)),
                        Text('Class average',
                            style: AppTextStyles.body.copyWith(
                                fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Text(test['avg'] as String,
                      style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
                  const SizedBox(width: 8),
                  Icon(
                    test['trend'] as IconData,
                    color: Colors.teal[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendGrid extends StatelessWidget {
  const _TrendGrid({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final defaults = [
      {
        'label': 'Homework',
        'value': '92%',
        'detail': 'on-time submissions',
        'color': Colors.teal[50],
      },
      {
        'label': 'Concept Mastery',
        'value': '78%',
        'detail': 'scored above 75%',
        'color': Colors.orange[50],
      },
      {
        'label': 'Participation',
        'value': '68%',
        'detail': 'spoke up daily',
        'color': Colors.purple[50],
      },
      {
        'label': 'Interventions',
        'value': '5',
        'detail': 'students flagged',
        'color': Colors.red[50],
      },
    ];

    final rows = items.isNotEmpty ? items : defaults;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final item = rows[index];
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
              Text(item['label'] as String,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text(item['value'] as String,
                  style: AppTextStyles.h1Purple.copyWith(fontSize: 22)),
              Text(item['detail'] as String,
                  style: AppTextStyles.body
                      .copyWith(fontSize: 13, color: Colors.black54)),
            ],
          ),
        );
      },
    );
  }
}
