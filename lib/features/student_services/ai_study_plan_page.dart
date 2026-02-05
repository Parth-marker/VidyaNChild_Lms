import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/student_services/gemini_provider.dart';
import 'package:lms_project/features/student_services/study_plan_provider.dart';
import 'package:lms_project/features/student_services/models/study_plan_model.dart';

class AIStudyPlanPage extends StatefulWidget {
  const AIStudyPlanPage({super.key});

  @override
  State<AIStudyPlanPage> createState() => _AIStudyPlanPageState();
}

class _AIStudyPlanPageState extends State<AIStudyPlanPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Smart Study Plan', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.teal,
          tabs: const [
            Tab(text: 'Generate Plan'),
            Tab(text: 'My Plans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_GeneratePlanTab(), _MyPlansTab()],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}

class _GeneratePlanTab extends StatefulWidget {
  const _GeneratePlanTab();

  @override
  State<_GeneratePlanTab> createState() => _GeneratePlanTabState();
}

class _GeneratePlanTabState extends State<_GeneratePlanTab> {
  final _formKey = GlobalKey<FormState>();

  // Form Values
  String _selectedTopic = 'Algebra';
  String _currentLevel = 'Beginner';
  double _hoursPerWeek = 5;
  int _durationWeeks = 4;
  String _learningStyle = 'Visual';

  // Options
  final List<String> _topics = [
    'Algebra',
    'Fractions',
    'Geometry',
    'Word Problems',
    'Decimals',
    'Percentages',
    'Ratios',
    'Statistics',
    'Trigonometry',
    'Calculus',
  ];
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _styles = ['Visual', 'Reading', 'Practice-based'];

  bool _isGenerating = false;

  Future<void> _generatePlan() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isGenerating = true);

    final geminiProvider = context.read<GeminiProvider>();
    final studyPlanProvider = context.read<StudyPlanProvider>();

    // Clear previous plan
    studyPlanProvider.clearGeneratedPlan();

    try {
      final generatedContent = await geminiProvider.generateMathStudyPlan(
        mathTopic: _selectedTopic,
        currentLevel: _currentLevel,
        hoursPerWeek: _hoursPerWeek.round(),
        durationWeeks: _durationWeeks,
        learningStyle: _learningStyle,
      );

      // Create plan object but don't save yet
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to save plans')),
          );
        }
        return;
      }

      final plan = studyPlanProvider.createPlanFromContent(
        userId: userId,
        mathTopic: _selectedTopic,
        currentLevel: _currentLevel,
        hoursPerWeek: _hoursPerWeek.round(),
        durationWeeks: _durationWeeks,
        learningStyle: _learningStyle,
        content: generatedContent,
      );

      studyPlanProvider.setGeneratedPlan(plan);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to see if we have a generated plan to show
    final studyPlanProvider = context.watch<StudyPlanProvider>();
    final plan = studyPlanProvider.generatedPlan;

    if (plan != null) {
      return _GeneratedPlanView(plan: plan);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customize Your Plan',
              style: AppTextStyles.h1Purple.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),

            _buildDropdown(
              label: 'Math Topic',
              value: _selectedTopic,
              items: _topics,
              onChanged: (val) => setState(() => _selectedTopic = val!),
            ),

            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Current Proficiency',
              value: _currentLevel,
              items: _levels,
              onChanged: (val) => setState(() => _currentLevel = val!),
            ),

            const SizedBox(height: 16),
            Text(
              'Study Time: ${_hoursPerWeek.round()} hours/week',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _hoursPerWeek,
              min: 1,
              max: 20,
              divisions: 19,
              activeColor: Colors.teal,
              label: '${_hoursPerWeek.round()} hours',
              onChanged: (val) => setState(() => _hoursPerWeek = val),
            ),

            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Duration (Weeks)',
              value: _durationWeeks.toString(),
              items: List.generate(8, (index) => (index + 1).toString()),
              onChanged: (val) =>
                  setState(() => _durationWeeks = int.parse(val!)),
            ),

            const SizedBox(height: 16),
            Text(
              'Learning Style',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _styles.map((style) {
                final isSelected = _learningStyle == style;
                return ChoiceChip(
                  label: Text(style),
                  selected: isSelected,
                  selectedColor: Colors.purple[100],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.purple[800] : Colors.black87,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _learningStyle = style);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generatePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isGenerating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Generate AI Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _GeneratedPlanView extends StatefulWidget {
  final StudyPlan plan;
  const _GeneratedPlanView({required this.plan});

  @override
  State<_GeneratedPlanView> createState() => _GeneratedPlanViewState();
}

class _GeneratedPlanViewState extends State<_GeneratedPlanView> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context
                          .read<StudyPlanProvider>()
                          .clearGeneratedPlan(),
                    ),
                    Expanded(
                      child: Text(
                        widget.plan.title,
                        style: AppTextStyles.h1Purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MarkdownWidget(
                  data: widget.plan.generatedPlan,
                  config: MarkdownConfig.defaultConfig,
                  shrinkWrap: true,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      setState(() => _isSaving = true);
                      try {
                        await context
                            .read<StudyPlanProvider>()
                            .saveCurrentPlan();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Plan saved successfully!'),
                            ),
                          );
                          // Switch to My Plans tab? Or just show success
                          context
                              .read<StudyPlanProvider>()
                              .clearGeneratedPlan();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save This Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MyPlansTab extends StatelessWidget {
  const _MyPlansTab();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Center(
        child: Text(
          'Please login to view saved plans',
          style: AppTextStyles.body,
        ),
      );
    }

    return StreamBuilder<List<StudyPlan>>(
      stream: context.read<StudyPlanProvider>().getUserPlans(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading plans', style: AppTextStyles.body),
          );
        }

        final plans = snapshot.data ?? [];

        if (plans.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No saved plans yet',
                  style: AppTextStyles.body.copyWith(color: Colors.black54),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  plan.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${plan.mathTopic} • ${plan.durationWeeks} Weeks',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      context.read<StudyPlanProvider>().deletePlan(
                        userId,
                        plan.id,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Plan'),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _PlanDetailScreen(plan: plan),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _PlanDetailScreen extends StatelessWidget {
  final StudyPlan plan;
  const _PlanDetailScreen({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(plan.title, style: AppTextStyles.h1Teal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownWidget(
          data: plan.generatedPlan,
          config: MarkdownConfig.defaultConfig,
          shrinkWrap: true,
        ),
      ),
    );
  }
}
