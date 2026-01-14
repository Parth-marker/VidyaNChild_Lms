import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/games/quiz_questions.dart';
import 'package:lms_project/features/games/quiz_badge.dart';
import 'package:lms_project/features/games/quiz_storage.dart';

class QuizGamePage extends StatefulWidget {
  const QuizGamePage({super.key});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  late List<QuizQuestion> questions;
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  int correctAnswers = 0;
  int startTime = 0;
  int elapsedTime = 0;
  Timer? timer;
  bool isAnswered = false;
  bool gameFinished = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    // Get 15 random questions
    questions = QuizQuestions.getRandomQuestions(15);
    startTime = DateTime.now().millisecondsSinceEpoch;
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameFinished) {
        setState(() {
          elapsedTime = (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
        });
      }
    });
  }

  void _selectAnswer(int index) {
    if (isAnswered) return;

    setState(() {
      selectedAnswerIndex = index;
      isAnswered = true;
    });

    // Check if answer is correct
    if (index == questions[currentQuestionIndex].correctAnswerIndex) {
      correctAnswers++;
    }

    // Move to next question after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        isAnswered = false;
      });
    } else {
      _finishGame();
    }
  }

  Future<void> _finishGame() async {
    setState(() {
      gameFinished = true;
    });
    timer?.cancel();

    final badge = BadgeHelper.getBadge(correctAnswers, elapsedTime);
    final badgeString = BadgeHelper.getBadgeString(badge);

    // Save best result
    await QuizStorage.saveBestResult(
      timeInSeconds: elapsedTime,
      score: correctAnswers,
      badge: badgeString,
    );

    if (mounted) {
      Navigator.of(context).pop(true); // Return true to indicate game finished
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (gameFinished) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            timer?.cancel();
            Navigator.of(context).pop(false);
          },
        ),
        title: Text('Question ${currentQuestionIndex + 1}/${questions.length}', 
          style: AppTextStyles.h1Teal),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer and Progress
            Container(
              padding: const EdgeInsets.all(16),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Score: $correctAnswers/${currentQuestionIndex + 1}',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.purple[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
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

            // Question
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
                        currentQuestion.question,
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
                      final isSelected = selectedAnswerIndex == index;
                      final isCorrect = index == currentQuestion.correctAnswerIndex;
                      
                      Color? backgroundColor;
                      Color? borderColor;
                      Color? textColor = Colors.black87;

                      if (isAnswered) {
                        if (isCorrect) {
                          backgroundColor = Colors.green[50];
                          borderColor = Colors.green;
                          textColor = Colors.green[800];
                        } else if (isSelected && !isCorrect) {
                          backgroundColor = Colors.red[50];
                          borderColor = Colors.red;
                          textColor = Colors.red[800];
                        }
                      } else if (isSelected) {
                        backgroundColor = Colors.teal[50];
                        borderColor = Colors.teal;
                        textColor = Colors.teal[800];
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: backgroundColor ?? Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor ?? Colors.grey[300]!,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (borderColor ?? Colors.grey[300]!).withOpacity(0.3),
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
                                    color: borderColor ?? Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index), // A, B, C, D
                                      style: TextStyle(
                                        color: textColor,
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
                                      color: textColor,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isAnswered && isCorrect)
                                  Icon(Icons.check_circle, color: Colors.green, size: 24)
                                else if (isAnswered && isSelected && !isCorrect)
                                  Icon(Icons.cancel, color: Colors.red, size: 24),
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
          ],
        ),
      ),
    );
  }
}

