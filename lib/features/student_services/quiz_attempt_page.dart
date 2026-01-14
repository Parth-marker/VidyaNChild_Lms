import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/teachers/widgets/quiz_question_builder.dart';
import 'package:lms_project/features/student_services/student_assignment_provider.dart';
import 'package:provider/provider.dart';

class QuizAttemptPage extends StatefulWidget {
  final Map<String, dynamic> assignment;

  const QuizAttemptPage({
    super.key,
    required this.assignment,
  });

  @override
  State<QuizAttemptPage> createState() => _QuizAttemptPageState();
}

class _QuizAttemptPageState extends State<QuizAttemptPage> {
  late List<QuizQuestion> questions;
  List<int?> selectedAnswers = [];
  int currentQuestionIndex = 0;
  int startTime = 0;
  int elapsedTime = 0;
  Timer? timer;
  bool isSubmitting = false;
  bool quizCompleted = false;
  Map<String, dynamic>? submissionResult;

  @override
  void initState() {
    super.initState();
    final provider = context.read<StudentAssignmentProvider>();
    questions = provider.parseQuizQuestions(
      widget.assignment['content'] as String? ?? '[]',
    );
    selectedAnswers = List.filled(questions.length, null);
    startTime = DateTime.now().millisecondsSinceEpoch;
    _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!quizCompleted && mounted) {
        setState(() {
          elapsedTime = (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int answerIndex) {
    if (quizCompleted) return;
    setState(() {
      selectedAnswers[currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  bool get _canSubmit {
    return selectedAnswers.every((answer) => answer != null);
  }

  Future<void> _submitQuiz() async {
    // Check if all questions are answered
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Confirm submission
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Quiz'),
        content: const Text('Are you sure you want to submit? You cannot change your answers after submitting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isSubmitting = true;
      quizCompleted = true;
    });
    timer?.cancel();

    final provider = context.read<StudentAssignmentProvider>();
    final teacherId = widget.assignment['teacherId'] as String? ?? '';
    final assignmentId = widget.assignment['id'] as String? ?? '';

    final result = await provider.submitQuiz(
      assignmentId: assignmentId,
      teacherId: teacherId,
      questions: questions,
      selectedAnswers: selectedAnswers.map((a) => a!).toList(),
      timeTaken: elapsedTime,
    );

    if (mounted) {
      if (result != null) {
        setState(() {
          submissionResult = result;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to submit quiz'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isSubmitting = false;
          quizCompleted = false;
        });
        _startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9E6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text('Quiz', style: AppTextStyles.h1Teal),
        ),
        body: const Center(
          child: Text('No questions found in this quiz'),
        ),
      );
    }

    if (submissionResult != null) {
      return _buildResultsScreen();
    }

    final currentQuestion = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;
    final selectedAnswer = selectedAnswers[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            if (quizCompleted) {
              Navigator.of(context).pop();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit Quiz?'),
                  content: const Text('Your progress will be lost if you exit now.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Exit', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        title: Text(
          widget.assignment['title'] as String? ?? 'Quiz',
          style: AppTextStyles.h1Teal,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header with timer and progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.teal[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: Colors.teal[800], size: 20),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(elapsedTime),
                              style: AppTextStyles.body.copyWith(
                                color: Colors.teal[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Question ${currentQuestionIndex + 1}/${questions.length}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[400]!),
                    ),
                  ),
                ],
              ),
            ),

            // Question and options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Text(
                        currentQuestion.questionText,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Answer options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      final isSelected = selectedAnswer == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.teal[50] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.teal : Colors.grey[300]!,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.teal : Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 16,
                                      color: isSelected ? Colors.teal[800] : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: Colors.teal, size: 24),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Navigation and submit buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: currentQuestionIndex > 0 ? _previousQuestion : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: currentQuestionIndex < questions.length - 1
                              ? _nextQuestion
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[400],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Next'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : (_canSubmit ? _submitQuiz : null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canSubmit ? Colors.purple[300] : Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Submit Quiz',
                              style: AppTextStyles.buttonPrimary,
                            ),
                    ),
                  ),
                  if (!_canSubmit)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Please answer all questions',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final score = submissionResult!['score'] as int;
    final total = submissionResult!['totalQuestions'] as int;
    final percentage = submissionResult!['percentage'] as double;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Quiz Results', style: AppTextStyles.h1Teal),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Score card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      percentage >= 80
                          ? Icons.celebration
                          : percentage >= 60
                              ? Icons.check_circle
                              : Icons.sentiment_dissatisfied,
                      size: 64,
                      color: percentage >= 80
                          ? Colors.green
                          : percentage >= 60
                              ? Colors.blue
                              : Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Score',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / $total',
                      style: AppTextStyles.h1Purple.copyWith(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: percentage >= 80
                            ? Colors.green
                            : percentage >= 60
                                ? Colors.blue
                                : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (elapsedTime > 0)
                      Text(
                        'Time taken: ${_formatTime(elapsedTime)}',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back to Assignments',
                    style: AppTextStyles.buttonPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

