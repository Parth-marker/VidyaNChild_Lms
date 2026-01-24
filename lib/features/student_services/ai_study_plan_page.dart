import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms_project/features/student_services/gemini_provider.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class AIStudyPlanPage extends StatefulWidget {
  const AIStudyPlanPage({super.key});

  @override
  State<AIStudyPlanPage> createState() => _AIStudyPlanPageState();
}

class _AIStudyPlanPageState extends State<AIStudyPlanPage> {
  final _subjectController = TextEditingController();
  final _goalController = TextEditingController();
  final _examDateController = TextEditingController();
  final _hoursController = TextEditingController();
  final _weakTopicsController = TextEditingController();
  final _learningStyleController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _generatedPlan;
  String? _generatedRaw;
  bool _isGenerating = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _goalController.dispose();
    _examDateController.dispose();
    _hoursController.dispose();
    _weakTopicsController.dispose();
    _learningStyleController.dispose();
    super.dispose();
  }

  String _buildPrompt({
    required String subject,
    String? goal,
    String? examDate,
    String? hoursPerDay,
    String? weakTopics,
    String? learningStyle,
  }) {
    final buffer = StringBuffer()
      ..writeln('You are an expert study coach.')
      ..writeln('Create a study roadmap for: $subject.')
      ..writeln('Return ONLY valid JSON with this schema:')
      ..writeln('{')
      ..writeln('  "title": "...",')
      ..writeln('  "overview": "...",')
      ..writeln('  "roadmap": [')
      ..writeln('    {')
      ..writeln('      "label": "Phase 1",')
      ..writeln('      "duration": "1 week",')
      ..writeln('      "focus": "...",')
      ..writeln('      "tasks": ["...", "..."],')
      ..writeln('      "milestones": ["...", "..."]')
      ..writeln('    }')
      ..writeln('  ]')
      ..writeln('}')
      ..writeln('Make it actionable and aligned with the user context.')
      ..writeln('User context:');

    if (goal != null && goal.trim().isNotEmpty) {
      buffer.writeln('- Goal: ${goal.trim()}');
    }
    if (examDate != null && examDate.trim().isNotEmpty) {
      buffer.writeln('- Exam date: ${examDate.trim()}');
    }
    if (hoursPerDay != null && hoursPerDay.trim().isNotEmpty) {
      buffer.writeln('- Hours per day: ${hoursPerDay.trim()}');
    }
    if (weakTopics != null && weakTopics.trim().isNotEmpty) {
      buffer.writeln('- Weak topics: ${weakTopics.trim()}');
    }
    if (learningStyle != null && learningStyle.trim().isNotEmpty) {
      buffer.writeln('- Learning style: ${learningStyle.trim()}');
    }

    return buffer.toString();
  }

  Map<String, dynamic>? _parsePlan(String response) {
    final fenced = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = fenced.firstMatch(response);
    final jsonText = match != null ? match.group(1) : response;
    if (jsonText == null) return null;

    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  Future<void> _savePlan({
    required String subject,
    required String rawPlan,
    Map<String, dynamic>? parsedPlan,
  }) async {
    final uid = _auth.currentUser?.uid ?? 'demo';
    final title = (parsedPlan?['title'] as String?)?.trim();
    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('studyPlans')
        .doc();

    await doc.set({
      'subject': subject,
      'title': title?.isNotEmpty == true ? title : 'Study Plan - $subject',
      'rawPlan': rawPlan,
      'parsedPlan': parsedPlan,
      'createdAt': FieldValue.serverTimestamp(),
      'params': {
        'goal': _goalController.text.trim(),
        'examDate': _examDateController.text.trim(),
        'hoursPerDay': _hoursController.text.trim(),
        'weakTopics': _weakTopicsController.text.trim(),
        'learningStyle': _learningStyleController.text.trim(),
      },
    });
  }

  Future<void> _generatePlan() async {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    try {
      final gemini = context.read<GeminiProvider>();
      final prompt = _buildPrompt(
        subject: subject,
        goal: _goalController.text,
        examDate: _examDateController.text,
        hoursPerDay: _hoursController.text,
        weakTopics: _weakTopicsController.text,
        learningStyle: _learningStyleController.text,
      );

      final result = await gemini.generate(prompt);
      final parsed = _parsePlan(result);
      setState(() {
        _generatedRaw = result;
        _generatedPlan = parsed;
        _isGenerating = false;
      });

      await _savePlan(
        subject: subject,
        rawPlan: result,
        parsedPlan: parsed,
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate plan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid ?? 'demo';
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
            _InputCard(
              subjectController: _subjectController,
              goalController: _goalController,
              examDateController: _examDateController,
              hoursController: _hoursController,
              weakTopicsController: _weakTopicsController,
              learningStyleController: _learningStyleController,
            ),
            const SizedBox(height: 12),
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_generatedRaw != null)
              _GeneratedPlanCard(
                plan: _generatedPlan,
                rawPlan: _generatedRaw!,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generatePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Generate Plan',
                      style: AppTextStyles.buttonPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Saved Plans', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(uid)
                    .collection('studyPlans')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No saved plans yet.',
                        style: AppTextStyles.body,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return _SavedPlanTile(data: data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}

class _InputCard extends StatelessWidget {
  final TextEditingController subjectController;
  final TextEditingController goalController;
  final TextEditingController examDateController;
  final TextEditingController hoursController;
  final TextEditingController weakTopicsController;
  final TextEditingController learningStyleController;

  const _InputCard({
    required this.subjectController,
    required this.goalController,
    required this.examDateController,
    required this.hoursController,
    required this.weakTopicsController,
    required this.learningStyleController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan Inputs', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          TextField(
            controller: subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject *',
              hintText: 'e.g., Mathematics',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: goalController,
            decoration: const InputDecoration(
              labelText: 'Goal',
              hintText: 'e.g., Score 90% in finals',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: examDateController,
            decoration: const InputDecoration(
              labelText: 'Exam Date',
              hintText: 'e.g., 20 May 2025',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: hoursController,
            decoration: const InputDecoration(
              labelText: 'Hours per day',
              hintText: 'e.g., 2 hours',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: weakTopicsController,
            decoration: const InputDecoration(
              labelText: 'Weak topics',
              hintText: 'e.g., algebra, geometry',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: learningStyleController,
            decoration: const InputDecoration(
              labelText: 'Learning style',
              hintText: 'e.g., visual, practice-heavy',
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedPlanCard extends StatelessWidget {
  final Map<String, dynamic>? plan;
  final String rawPlan;

  const _GeneratedPlanCard({
    required this.plan,
    required this.rawPlan,
  });

  List<Widget> _buildRoadmap(Map<String, dynamic> plan) {
    final roadmap = plan['roadmap'];
    if (roadmap is! List) return [];
    return roadmap.map<Widget>((phase) {
      if (phase is! Map) return const SizedBox.shrink();
      final label = phase['label']?.toString() ?? 'Phase';
      final duration = phase['duration']?.toString() ?? '';
      final focus = phase['focus']?.toString() ?? '';
      final tasks = (phase['tasks'] is List)
          ? (phase['tasks'] as List).map((t) => t.toString()).toList()
          : <String>[];
      final milestones = (phase['milestones'] is List)
          ? (phase['milestones'] as List).map((t) => t.toString()).toList()
          : <String>[];

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F4FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label ${duration.isNotEmpty ? '• $duration' : ''}'.trim()),
            if (focus.isNotEmpty) Text(focus),
            if (tasks.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Tasks:', style: AppTextStyles.body),
              ...tasks.map((t) => Text('- $t')),
            ],
            if (milestones.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Milestones:', style: AppTextStyles.body),
              ...milestones.map((m) => Text('- $m')),
            ],
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = plan?['title']?.toString();
    final overview = plan?['overview']?.toString();
    final roadmapWidgets = plan == null ? <Widget>[] : _buildRoadmap(plan!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Latest Plan', style: AppTextStyles.h2),
          if (title != null) Text(title, style: AppTextStyles.body),
          if (overview != null) ...[
            const SizedBox(height: 6),
            Text(overview, style: AppTextStyles.body),
          ],
          if (roadmapWidgets.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...roadmapWidgets,
          ] else ...[
            const SizedBox(height: 8),
            Text(rawPlan, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}

class _SavedPlanTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SavedPlanTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Study Plan';
    final subject = data['subject']?.toString() ?? '';
    final parsed = data['parsedPlan'];
    final rawPlan = data['rawPlan']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(title, style: AppTextStyles.body),
        subtitle: subject.isNotEmpty
            ? Text(subject, style: AppTextStyles.body)
            : null,
        children: [
          if (parsed is Map<String, dynamic>)
            _GeneratedPlanCard(plan: parsed, rawPlan: rawPlan)
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(rawPlan, style: AppTextStyles.body),
            ),
        ],
      ),
    );
  }
}
