import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';

class QuizQuestion {
  String questionText;
  List<String> options;
  int correctAnswerIndex;

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      questionText: map['questionText'] as String? ?? '',
      options: List<String>.from(map['options'] as List? ?? []),
      correctAnswerIndex: map['correctAnswerIndex'] as int? ?? 0,
    );
  }
}

class QuizQuestionBuilder extends StatefulWidget {
  final List<QuizQuestion>? initialQuestions;
  
  const QuizQuestionBuilder({
    super.key,
    this.initialQuestions,
  });

  @override
  State<QuizQuestionBuilder> createState() => QuizQuestionBuilderState();
}

class QuizQuestionBuilderState extends State<QuizQuestionBuilder> {
  final List<QuizQuestion> _questions = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuestions != null && widget.initialQuestions!.isNotEmpty) {
      _questions.addAll(widget.initialQuestions!);
    } else {
      // Start with one empty question
      _addQuestion();
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuizQuestion(
        questionText: '',
        options: ['', '', ''],
        correctAnswerIndex: 0,
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      // Ensure at least one question exists
      if (_questions.isEmpty) {
        _addQuestion();
      }
    });
  }

  void _addOption(int questionIndex) {
    if (_questions[questionIndex].options.length < 4) {
      setState(() {
        _questions[questionIndex].options.add('');
      });
    }
  }

  void _removeOption(int questionIndex, int optionIndex) {
    if (_questions[questionIndex].options.length > 2) {
      setState(() {
        _questions[questionIndex].options.removeAt(optionIndex);
        // Adjust correct answer index if needed
        if (_questions[questionIndex].correctAnswerIndex >= 
            _questions[questionIndex].options.length) {
          _questions[questionIndex].correctAnswerIndex = 
              _questions[questionIndex].options.length - 1;
        }
      });
    }
  }

  List<QuizQuestion> getQuestions() {
    return _questions;
  }

  bool validateQuestions() {
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      if (question.questionText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1}: Please enter question text')),
        );
        return false;
      }
      
      // Check that all options are filled
      for (int j = 0; j < question.options.length; j++) {
        if (question.options[j].trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question ${i + 1}, Option ${j + 1}: Please enter option text')),
          );
          return false;
        }
      }
      
      // Check that correct answer is selected (index is valid)
      if (question.correctAnswerIndex < 0 || 
          question.correctAnswerIndex >= question.options.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question ${i + 1}: Please select correct answer')),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quiz Questions *',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[400],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _QuestionCard(
              questionIndex: index,
              question: question,
              onQuestionChanged: (updatedQuestion) {
                setState(() {
                  _questions[index] = updatedQuestion;
                });
              },
              onRemove: () => _removeQuestion(index),
              onAddOption: () => _addOption(index),
              onRemoveOption: (optionIndex) => _removeOption(index, optionIndex),
            );
          }),
          if (_questions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No questions yet. Click "Add Question" to get started.',
                  style: AppTextStyles.body.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatefulWidget {
  final int questionIndex;
  final QuizQuestion question;
  final Function(QuizQuestion) onQuestionChanged;
  final VoidCallback onRemove;
  final VoidCallback onAddOption;
  final Function(int) onRemoveOption;

  const _QuestionCard({
    required this.questionIndex,
    required this.question,
    required this.onQuestionChanged,
    required this.onRemove,
    required this.onAddOption,
    required this.onRemoveOption,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  int _selectedCorrectAnswer = 0;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.questionText);
    _optionControllers = widget.question.options
        .map((opt) => TextEditingController(text: opt))
        .toList();
    _selectedCorrectAnswer = widget.question.correctAnswerIndex;
    
    _questionController.addListener(_updateQuestion);
    for (var controller in _optionControllers) {
      controller.addListener(_updateQuestion);
    }
  }

  @override
  void didUpdateWidget(_QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      _questionController.text = widget.question.questionText;
      // Update option controllers if options changed
      if (oldWidget.question.options.length != widget.question.options.length) {
        for (var controller in _optionControllers) {
          controller.dispose();
        }
        _optionControllers = widget.question.options
            .map((opt) => TextEditingController(text: opt))
            .toList();
        for (var controller in _optionControllers) {
          controller.addListener(_updateQuestion);
        }
      } else {
        for (int i = 0; i < _optionControllers.length; i++) {
          _optionControllers[i].text = widget.question.options[i];
        }
      }
      _selectedCorrectAnswer = widget.question.correctAnswerIndex;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateQuestion() {
    final updatedQuestion = QuizQuestion(
      questionText: _questionController.text,
      options: _optionControllers.map((c) => c.text).toList(),
      correctAnswerIndex: _selectedCorrectAnswer,
    );
    widget.onQuestionChanged(updatedQuestion);
  }

  void _setCorrectAnswer(int index) {
    setState(() {
      _selectedCorrectAnswer = index;
    });
    _updateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Question ${widget.questionIndex + 1}',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[900],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: widget.onRemove,
                tooltip: 'Remove question',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: 'Question Text *',
              hintText: 'Enter your question',
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Options * (Select correct answer)',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ..._optionControllers.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final controller = entry.value;
            final isCorrect = _selectedCorrectAnswer == optionIndex;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Option ${optionIndex + 1}',
                        hintText: 'Enter option text',
                        filled: true,
                        fillColor: isCorrect ? Colors.green[50] : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isCorrect ? Colors.green : Colors.grey[300]!,
                            width: isCorrect ? 2 : 1,
                          ),
                        ),
                        prefixIcon: Radio<int>(
                          value: optionIndex,
                          groupValue: _selectedCorrectAnswer,
                          onChanged: (value) => _setCorrectAnswer(value!),
                          activeColor: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  if (_optionControllers.length > 2)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => widget.onRemoveOption(optionIndex),
                      tooltip: 'Remove option',
                    ),
                ],
              ),
            );
          }),
          if (_optionControllers.length < 4)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: widget.onAddOption,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Option'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

