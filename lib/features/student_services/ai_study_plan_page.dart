import 'package:flutter/material.dart';
import 'package:lms_project/features/student_services/gemini_provider.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:provider/provider.dart';

class AIStudyPlanPage extends StatefulWidget {
  const AIStudyPlanPage({super.key});

  @override
  State<AIStudyPlanPage> createState() => _AIStudyPlanPageState();
}

class _AIStudyPlanPageState extends State<AIStudyPlanPage> {
  String? _generatedPlan;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _generatePlan();
    });
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    try {
      final gemini = context.read<GeminiProvider>();

      // Get some context from analytics to provide to Gemini
      final prompt =
          'Create a 4-item study plan for a student struggling with Math. Format each item as "Subject: Tagline".';

      final result = await gemini.generate(prompt);
      setState(() {
        _generatedPlan = result;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> planItems = [];
    if (_generatedPlan != null) {
      final lines = _generatedPlan!
          .split('\n')
          .where((l) => l.contains(':'))
          .toList();
      planItems = lines.map((l) {
        final parts = l.split(':');
        return {
          'subject': parts[0].replaceAll(RegExp(r'^\d+\.\s*'), '').trim(),
          'tag': parts.sublist(1).join(':').trim(),
        };
      }).toList();
    }

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
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (planItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'Failed to generate plan. Please try again.',
                    style: AppTextStyles.body,
                  ),
                ),
              )
            else
              ...planItems
                  .map(
                    (item) =>
                        _PlanTile(subject: item['subject']!, tag: item['tag']!),
                  )
                  .toList(),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Start Plan',
                      style: AppTextStyles.buttonPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isGenerating ? null : _generatePlan,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: BorderSide(color: Colors.purple[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text('Regenerate', style: AppTextStyles.linkPurple),
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
          backgroundColor: Colors.purple[50],
          child: const Icon(Icons.task_alt_rounded, color: Colors.purple),
        ),
        title: Text(
          subject,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          tag,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        trailing: Switch(value: true, onChanged: (_) {}),
      ),
    );
  }
}
