import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/games/quiz_storage.dart';

enum SequenceDifficulty { medium, hard }

class NumberSequenceQuestion {
  final List<int> sequence;
  final int hiddenIndex; // 1, 2 or 3
  final int correctAnswer;
  final List<int> options;
  final SequenceDifficulty difficulty;

  NumberSequenceQuestion({
    required this.sequence,
    required this.hiddenIndex,
    required this.correctAnswer,
    required this.options,
    required this.difficulty,
  });

  String get displaySequence {
    return List<String>.generate(sequence.length, (i) {
      if (i == hiddenIndex) {
        return '?';
      }
      return sequence[i].toString();
    }).join(', ');
  }
}

class NumberSequenceGamePage extends StatefulWidget {
  const NumberSequenceGamePage({super.key});

  @override
  State<NumberSequenceGamePage> createState() => _NumberSequenceGamePageState();
}

class _NumberSequenceGamePageState extends State<NumberSequenceGamePage> {
  late final List<NumberSequenceQuestion> questions;
  int currentIndex = 0;
  int? selectedAnswer;
  bool isAnswered = false;
  bool gameFinished = false;

  int totalMarks = 0;
  int startTime = 0;
  int elapsedTime = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    questions = _generateQuestions();
    _startGame();
  }

  List<NumberSequenceQuestion> _generateQuestions() {
    final List<NumberSequenceQuestion> result = [];
    final random = Random();

    // First 12 medium questions
    for (int i = 0; i < 12; i++) {
      result.add(_generateQuestion(random, SequenceDifficulty.medium));
    }

    // Last 8 hard questions
    for (int i = 0; i < 8; i++) {
      result.add(_generateQuestion(random, SequenceDifficulty.hard));
    }

    return result;
  }

  NumberSequenceQuestion _generateQuestion(
      Random random, SequenceDifficulty difficulty) {
    List<int> sequence;

    if (difficulty == SequenceDifficulty.medium) {
      // Weight patterns to reduce pure square sequences
      int patternType = random.nextInt(5); // 0-4
      if (patternType == 2 && random.nextBool()) {
        // Replace some square/cube questions with other types
        patternType = random.nextInt(4); // 0-3 (no halving/doubling change)
      }
      switch (patternType) {
        case 0:
          sequence = _generateArithmetic(random, isHard: false);
          break;
        case 1:
          sequence = _generateGeometric(random, isHard: false);
          break;
        case 2:
          sequence = _generateSquaresOrCubes(random, cubes: false);
          break;
        case 3:
          sequence = _generateFibonacciLike(random);
          break;
        case 4:
        default:
          sequence = _generateDoublingOrHalving(random);
          break;
      }
    } else {
      final patternType = random.nextInt(4); // 0-3
      switch (patternType) {
        case 0:
          sequence = _generateSquarePlusConstant(random);
          break;
        case 1:
          sequence = _generateIncreasingDifferences(random);
          break;
        case 2:
          sequence = _generateMixedOddEven(random);
          break;
        case 3:
        default:
          sequence = _generateMultiplyThenAdd(random);
          break;
      }
    }

    // Hide one term at index 1, 2 or 3
    final hiddenIndex = random.nextInt(3) + 1;
    final correctAnswer = sequence[hiddenIndex];

    // Generate options: correct answer + 3 nearby distinct distractors
    final Set<int> optionsSet = {correctAnswer};
    while (optionsSet.length < 4) {
      final delta = random.nextInt(7) - 3; // -3 to +3
      int option = correctAnswer + delta;
      if (option <= 0 || option == correctAnswer) {
        option = correctAnswer + (delta >= 0 ? delta + 4 : delta - 4);
      }
      if (option > 0) {
        optionsSet.add(option);
      }
    }
    final options = optionsSet.toList()..shuffle(random);

    return NumberSequenceQuestion(
      sequence: sequence,
      hiddenIndex: hiddenIndex,
      correctAnswer: correctAnswer,
      options: options,
      difficulty: difficulty,
    );
  }

  List<int> _generateArithmetic(Random random, {required bool isHard}) {
    // Allow both increasing and decreasing AP, but keep terms positive
    int diff = random.nextInt(10) + 1; // 1–10
    final bool negative = random.nextBool();
    if (negative) {
      diff = -diff;
    }

    int start;
    if (diff < 0) {
      // Ensure the last term stays >= 1
      final minStart = 1 - 4 * diff; // because diff is negative
      final maxStart = isHard ? 40 : 30;
      start = minStart + random.nextInt(maxStart - minStart + 1);
    } else {
      start = random.nextInt(isHard ? 30 : 40) + 1;
    }

    return List<int>.generate(5, (i) => start + i * diff);
  }

  List<int> _generateGeometric(Random random, {required bool isHard}) {
    final start = random.nextInt(isHard ? 5 : 8) + 1;
    final ratio = random.nextInt(3) + 2; // 2-4
    final List<int> seq = [];
    int current = start;
    for (int i = 0; i < 5; i++) {
      seq.add(current);
      current *= ratio;
    }
    return seq;
  }

  List<int> _generateSquaresOrCubes(Random random, {required bool cubes}) {
    if (cubes) {
      final startN = random.nextInt(3) + 1; // 1-3
      return List<int>.generate(5, (i) {
        final n = startN + i;
        return n * n * n;
      });
    } else {
      // Less frequent perfect square runs: restrict starting n
      final startN = random.nextInt(4) + 2; // 2-5
      return List<int>.generate(5, (i) {
        final n = startN + i;
        return n * n;
      });
    }
  }

  List<int> _generateFibonacciLike(Random random) {
    int a = random.nextInt(10) + 1;
    int b = random.nextInt(10) + 1;
    final List<int> seq = [a, b];
    while (seq.length < 5) {
      seq.add(a + b);
      a = b;
      b = seq.last;
    }
    return seq;
  }

  List<int> _generateDoublingOrHalving(Random random) {
    final isDoubling = random.nextBool();
    if (isDoubling) {
      // Doubling from all bases 1–9
      final base = random.nextInt(9) + 1; // 1–9
      int current = base;
      final List<int> seq = [];
      for (int i = 0; i < 5; i++) {
        seq.add(current);
        current *= 2;
      }
      return seq;
    } else {
      // Halving down to all bases 1–9: start at base * 16
      final base = random.nextInt(9) + 1; // 1–9
      int current = base * 16;
      final List<int> seq = [];
      for (int i = 0; i < 5; i++) {
        seq.add(current);
        current ~/= 2;
      }
      return seq;
    }
  }

  List<int> _generateSquarePlusConstant(Random random) {
    // Hard pattern: n² + 1 or n² + 2
    final c = random.nextBool() ? 1 : 2;
    final startN = random.nextInt(5) + 1; // 1-5
    return List<int>.generate(5, (i) {
      final n = startN + i;
      final base = n * n;
      return base + c;
    });
  }

  List<int> _generateIncreasingDifferences(Random random) {
    final start = random.nextInt(15) + 1;
    final firstDiff = random.nextInt(5) + 1;
    final List<int> seq = [start];
    int current = start;
    int diff = firstDiff;
    for (int i = 0; i < 4; i++) {
      current += diff;
      seq.add(current);
      diff += 1;
    }
    return seq;
  }

  List<int> _generateMixedOddEven(Random random) {
    final start = random.nextInt(15) + 1;
    final addOdd = random.nextInt(6) + 2; // 2-7
    final addEven = random.nextInt(6) + 4; // 4-9
    final List<int> seq = [start];
    int current = start;
    for (int i = 1; i < 5; i++) {
      if (i.isOdd) {
        current += addOdd;
      } else {
        current += addEven;
      }
      seq.add(current);
    }
    return seq;
  }

  List<int> _generateMultiplyThenAdd(Random random) {
    final start = random.nextInt(10) + 1;
    final k = random.nextInt(3) + 2; // 2-4
    final c = random.nextInt(6) + 1; // 1-6
    final List<int> seq = [start];
    int current = start;
    for (int i = 1; i < 5; i++) {
      if (i.isOdd) {
        current *= k;
      } else {
        current += c;
      }
      seq.add(current);
    }
    return seq;
  }

  void _startGame() {
    startTime = DateTime.now().millisecondsSinceEpoch;
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameFinished) {
        setState(() {
          elapsedTime =
              (DateTime.now().millisecondsSinceEpoch - startTime) ~/ 1000;
        });
      }
    });
  }

  void _selectAnswer(int value) {
    if (isAnswered || gameFinished) return;

    setState(() {
      selectedAnswer = value;
      isAnswered = true;
    });

    final question = questions[currentIndex];
    final isCorrect = value == question.correctAnswer;

    // 1 mark per correct question (out of 20)
    if (isCorrect) {
      totalMarks += 1;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
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

    final int T = elapsedTime == 0 ? 1 : elapsedTime;

    // Score is simply number of correct answers out of 20
    final int finalScore = totalMarks.clamp(0, 20);

    final String badge = _getMedalFromScore(finalScore, T);

    await QuizStorage.saveSequenceBestResult(
      timeInSeconds: elapsedTime,
      score: finalScore,
      badge: badge,
    );

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  String _getMedalFromScore(int correct, int timeSeconds) {
    // Time limits:
    // Gold  : ≤ 5 minutes (300s)
    // Silver: ≤ 8 minutes (480s)
    // Bronze: ≤ 10 minutes (600s)
    if (correct >= 18 && timeSeconds <= 300) {
      return 'gold';
    }
    if (correct >= 15 && timeSeconds <= 480) {
      return 'silver';
    }
    if (correct >= 12 && timeSeconds <= 600) {
      return 'bronze';
    }
    return 'grey';
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

    final question = questions[currentIndex];
    final progress = (currentIndex + 1) / questions.length;

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
        title: Text(
          'Question ${currentIndex + 1}/${questions.length}',
          style: AppTextStyles.h1Teal,
        ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.teal[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer,
                                color: Colors.teal[800], size: 20),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Marks: $totalMarks',
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.teal[400]!),
                    ),
                  ),
                ],
              ),
            ),

            // Question + options
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fill in the missing term:',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.displaySequence,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...question.options.map((option) {
                      final bool isSelected = selectedAnswer == option;
                      final bool isCorrect =
                          option == question.correctAnswer;

                      Color? backgroundColor;
                      Color borderColor = Colors.grey[300]!;
                      Color textColor = Colors.black87;

                      if (isAnswered) {
                        if (isCorrect) {
                          backgroundColor = Colors.green[50];
                          borderColor = Colors.green;
                          textColor = Colors.green[800]!;
                        } else if (isSelected && !isCorrect) {
                          backgroundColor = Colors.red[50];
                          borderColor = Colors.red;
                          textColor = Colors.red[800]!;
                        }
                      } else if (isSelected) {
                        backgroundColor = Colors.teal[50];
                        borderColor = Colors.teal;
                        textColor = Colors.teal[800]!;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectAnswer(option),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: backgroundColor ?? Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: borderColor
                                            .withOpacity(0.3),
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
                                    color: borderColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      option.toString(),
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (isAnswered && isCorrect)
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 24)
                                else if (isAnswered &&
                                    isSelected &&
                                    !isCorrect)
                                  const Icon(Icons.cancel,
                                      color: Colors.red, size: 24),
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


