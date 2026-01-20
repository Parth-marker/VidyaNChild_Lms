import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/teachers/widgets/quiz_question_builder.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AssignmentFormDialog extends StatefulWidget {
  final Map<String, dynamic>? assignment;
  const AssignmentFormDialog({super.key, this.assignment});

  @override
  State<AssignmentFormDialog> createState() => _AssignmentFormDialogState();
}

class _AssignmentFormDialogState extends State<AssignmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _messageController;
  late TextEditingController _contentController;
  late TextEditingController _submissionDateController;

  String _assignmentType = 'Worksheet';
  DateTime? _submissionDate;
  List<QuizQuestion>? _quizQuestions;
  GlobalKey<QuizQuestionBuilderState>? _quizBuilderKey;

  bool get isEditing => widget.assignment != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.assignment?['title'] ?? '',
    );
    _messageController = TextEditingController(
      text: widget.assignment?['message'] ?? '',
    );
    _assignmentType = widget.assignment?['assignmentType'] ?? 'Worksheet';

    // Initialize content based on assignment type
    if (_assignmentType == 'Quiz') {
      // Parse quiz questions from content if it exists
      final content = widget.assignment?['content'];
      if (content != null && content is String && content.isNotEmpty) {
        try {
          final List<dynamic> questionsJson = jsonDecode(content);
          _quizQuestions = questionsJson
              .map((q) => QuizQuestion.fromMap(Map<String, dynamic>.from(q)))
              .toList();
        } catch (e) {
          _quizQuestions = null;
        }
      }
      _quizBuilderKey ??= GlobalKey<QuizQuestionBuilderState>();
      _contentController = TextEditingController(); // Not used for Quiz
    } else {
      _contentController = TextEditingController(
        text: widget.assignment?['content'] ?? '',
      );
    }

    if (widget.assignment?['submissionDate'] != null) {
      final submissionDateValue = widget.assignment!['submissionDate'];
      if (submissionDateValue is Timestamp) {
        _submissionDate = submissionDateValue.toDate();
        _submissionDateController = TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(_submissionDate!),
        );
      } else if (submissionDateValue is DateTime) {
        _submissionDate = submissionDateValue;
        _submissionDateController = TextEditingController(
          text: DateFormat('yyyy-MM-dd').format(_submissionDate!),
        );
      } else {
        _submissionDateController = TextEditingController();
      }
    } else {
      _submissionDateController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    _contentController.dispose();
    _submissionDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _submissionDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _submissionDate = picked;
        _submissionDateController.text = DateFormat(
          'yyyy-MM-dd',
        ).format(picked);
      });
    }
  }

  void _submit({required bool publish}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate Quiz questions if Quiz type
    if (_assignmentType == 'Quiz') {
      if (_quizBuilderKey?.currentState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one quiz question'),
          ),
        );
        return;
      }

      if (!_quizBuilderKey!.currentState!.validateQuestions()) {
        return;
      }
    } else {
      // Validate content for non-Quiz types
      if (_contentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter assignment content')),
        );
        return;
      }
    }

    // Require submission date for Worksheets and Quizzes when publishing
    if ((_assignmentType == 'Worksheet' || _assignmentType == 'Quiz') &&
        _submissionDate == null &&
        publish) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a submission date for $_assignmentType'),
        ),
      );
      return;
    }

    // Prepare content based on assignment type
    String content;
    if (_assignmentType == 'Quiz') {
      final questions = _quizBuilderKey!.currentState!.getQuestions();
      final questionsJson = questions.map((q) => q.toMap()).toList();
      content = jsonEncode(questionsJson);
    } else {
      content = _contentController.text.trim();
    }

    Navigator.of(context).pop({
      'title': _nameController.text.trim(),
      'message': _messageController.text.trim(),
      'content': content,
      'assignmentType': _assignmentType,
      'submissionDate': _submissionDate, // Can be null for lessons
      'isPublished': publish,
      'publish': publish,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    isEditing ? 'Edit Assignment' : 'Create Assignment',
                    style: AppTextStyles.h1Teal.copyWith(fontSize: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Assignment Name *',
                          hintText: 'Enter assignment name',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter assignment name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Assignment Type *',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Worksheet'),
                              selected: _assignmentType == 'Worksheet',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _assignmentType = 'Worksheet';
                                    _quizBuilderKey = null;
                                  });
                                }
                              },
                              selectedColor: Colors.teal[100],
                              checkmarkColor: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Quiz'),
                              selected: _assignmentType == 'Quiz',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _assignmentType = 'Quiz';
                                    _contentController.clear();
                                    _quizBuilderKey =
                                        GlobalKey<QuizQuestionBuilderState>();
                                    _quizQuestions ??= [];
                                  });
                                }
                              },
                              selectedColor: Colors.blue[100],
                              checkmarkColor: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Lesson'),
                              selected: _assignmentType == 'Lesson',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _assignmentType = 'Lesson';
                                    _quizBuilderKey = null;
                                    // Clear submission date when switching to Lesson
                                    _submissionDate = null;
                                    _submissionDateController.clear();
                                  });
                                }
                              },
                              selectedColor: Colors.purple[100],
                              checkmarkColor: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Show submission date field for Worksheets and Quizzes
                      if (_assignmentType == 'Worksheet' ||
                          _assignmentType == 'Quiz') ...[
                        TextFormField(
                          controller: _submissionDateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          decoration: InputDecoration(
                            labelText: 'Submission Date *',
                            hintText: 'Select submission date',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          hintText: 'Enter message for students',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      // Show quiz builder for Quiz type, content field for others
                      if (_assignmentType == 'Quiz') ...[
                        if (_quizBuilderKey != null)
                          QuizQuestionBuilder(
                            key: _quizBuilderKey,
                            initialQuestions: _quizQuestions,
                          )
                        else
                          const SizedBox.shrink(),
                      ] else ...[
                        TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            labelText: 'Content *',
                            hintText: 'Enter assignment content/instructions',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter assignment content';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _submit(publish: false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Save as Draft',
                                  style: AppTextStyles.body.copyWith(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => _submit(publish: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[400],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Publish',
                                style: AppTextStyles.buttonPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
