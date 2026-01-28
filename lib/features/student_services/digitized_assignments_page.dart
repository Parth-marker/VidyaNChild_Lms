import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/student_services/student_assignment_provider.dart';
import 'package:lms_project/features/student_services/quiz_attempt_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DigitizedAssignmentsPage extends StatelessWidget {
  final String? expandAssignment;
  
  const DigitizedAssignmentsPage({super.key, this.expandAssignment});

  @override
  Widget build(BuildContext context) {
    final assignmentProvider = context.read<StudentAssignmentProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Assignments', style: AppTextStyles.h1Teal),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: assignmentProvider.getPublishedAssignments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading assignments',
                      style: AppTextStyles.body.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: AppTextStyles.body.copyWith(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final assignments = snapshot.data ?? [];

          if (assignments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No assignments available',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for new assignments',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Group assignments by type
          final quizzes = assignments.where((a) => a['assignmentType'] == 'Quiz').toList();
          final worksheets = assignments.where((a) => a['assignmentType'] == 'Worksheet').toList();
          final lessons = assignments.where((a) => a['assignmentType'] == 'Lesson').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (quizzes.isNotEmpty) ...[
                  Text('Quizzes', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  ...quizzes.map((assignment) => _QuizAssignmentTile(
                    assignment: assignment,
                    initiallyExpanded: expandAssignment == assignment['title'],
                  )),
                  const SizedBox(height: 16),
                ],
                if (worksheets.isNotEmpty) ...[
                  Text('Worksheets', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  ...worksheets.map((assignment) => _WorksheetAssignmentTile(
                    assignment: assignment,
                    initiallyExpanded: expandAssignment == assignment['title'],
                  )),
                  const SizedBox(height: 16),
                ],
                if (lessons.isNotEmpty) ...[
                  Text('Lessons', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  ...lessons.map((assignment) => _LessonAssignmentTile(
                    assignment: assignment,
                    initiallyExpanded: expandAssignment == assignment['title'],
                  )),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: assignmentProvider.getMyQuizSubmissions(),
                  builder: (context, submissionsSnapshot) {
                    final submissions = submissionsSnapshot.data ?? [];
                    if (submissions.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recent Submissions', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
                        const SizedBox(height: 8),
                        ...submissions.take(5).map((submission) => _SubmissionTile(
                          submission: submission,
                        )),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _QuizAssignmentTile extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final bool initiallyExpanded;

  const _QuizAssignmentTile({
    required this.assignment,
    this.initiallyExpanded = false,
  });

  @override
  State<_QuizAssignmentTile> createState() => _QuizAssignmentTileState();
}

class _QuizAssignmentTileState extends State<_QuizAssignmentTile> {
  bool _isExpanded = false;
  Map<String, dynamic>? _quizScore;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _loadQuizScore();
  }

  Future<void> _loadQuizScore() async {
    final provider = context.read<StudentAssignmentProvider>();
    final assignmentId = widget.assignment['id'] as String? ?? '';
    final score = await provider.getQuizScore(assignmentId);
    if (mounted) {
      setState(() {
        _quizScore = score;
      });
    }
  }

  String _formatDueDate(dynamic submissionDate) {
    if (submissionDate == null) return 'No due date';
    try {
      Timestamp timestamp;
      if (submissionDate is Timestamp) {
        timestamp = submissionDate;
      } else {
        return 'Invalid date';
      }
      final date = timestamp.toDate();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.assignment['title'] as String? ?? 'Untitled Quiz';
    final submissionDate = widget.assignment['submissionDate'];
    final hasAttempted = _quizScore != null;
    final score = _quizScore?['score'] as int?;
    final total = _quizScore?['totalQuestions'] as int?;
    final percentage = _quizScore?['percentage'] as double?;

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
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: Icon(Icons.quiz, color: Colors.blue[600]),
            ),
            title: Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due: ${_formatDueDate(submissionDate)}',
                  style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
                ),
                if (hasAttempted && score != null && total != null)
                  Text(
                    'Score: $score/$total (${percentage?.toStringAsFixed(1)}%)',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      color: percentage! >= 80
                          ? Colors.green[700]
                          : percentage >= 60
                              ? Colors.blue[700]
                              : Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            trailing: hasAttempted
                ? Icon(Icons.check_circle, color: Colors.green[600])
                : Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.assignment['message'] != null &&
                      (widget.assignment['message'] as String).isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple[200]!),
                      ),
                      child: Text(
                        widget.assignment['message'] as String,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: hasAttempted
                          ? null
                          : () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => QuizAttemptPage(
                                    assignment: widget.assignment,
                                  ),
                                ),
                              );
                              if (result == true && mounted) {
                                await _loadQuizScore();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasAttempted ? Colors.grey[300] : Colors.blue[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        hasAttempted ? 'Already Attempted' : 'Start Quiz',
                        style: AppTextStyles.buttonPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorksheetAssignmentTile extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final bool initiallyExpanded;

  const _WorksheetAssignmentTile({
    required this.assignment,
    this.initiallyExpanded = false,
  });

  @override
  State<_WorksheetAssignmentTile> createState() => _WorksheetAssignmentTileState();
}

class _WorksheetAssignmentTileState extends State<_WorksheetAssignmentTile> {
  bool _isExpanded = false;
  bool _isSubmitting = false;
  bool _hasSubmitted = false;
  String? _existingFileName;
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _loadExistingSubmission();
  }

  String _formatDueDate(dynamic submissionDate) {
    if (submissionDate == null) return 'No due date';
    try {
      Timestamp timestamp;
      if (submissionDate is Timestamp) {
        timestamp = submissionDate;
      } else {
        return 'Invalid date';
      }
      final date = timestamp.toDate();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _loadExistingSubmission() async {
    final provider = context.read<StudentAssignmentProvider>();
    final assignmentId = widget.assignment['id'] as String? ?? '';
    if (assignmentId.isEmpty) return;

    final submission =
        await provider.getWorksheetSubmission(assignmentId);
    if (!mounted) return;

    if (submission != null) {
      setState(() {
        _hasSubmitted = true;
        _existingFileName = submission['fileName'] as String?;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withReadStream: false,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.path == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to access selected file path')),
      );
      return;
    }

    setState(() {
      _selectedFilePath = file.path;
      _selectedFileName = file.name;
    });
  }

  Future<void> _submitWorksheet() async {
    if (_selectedFilePath == null || _selectedFileName == null) return;

    final assignmentId = widget.assignment['id'] as String? ?? '';
    final teacherId = widget.assignment['teacherId'] as String? ?? '';
    if (assignmentId.isEmpty || teacherId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to submit: assignment information missing'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<StudentAssignmentProvider>();
    final result = await provider.submitWorksheet(
      assignmentId: assignmentId,
      teacherId: teacherId,
      localPath: _selectedFilePath!,
      fileName: _selectedFileName!,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (result != null) {
      setState(() {
        _hasSubmitted = true;
        _existingFileName = _selectedFileName;
        _selectedFileName = null;
        _selectedFilePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Worksheet submitted!')),
      );
    } else {
      final error = provider.error ?? 'Failed to submit worksheet';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.assignment['title'] as String? ?? 'Untitled Worksheet';
    final submissionDate = widget.assignment['submissionDate'];
    final content = widget.assignment['content'] as String? ?? '';
    final message = widget.assignment['message'] as String? ?? '';

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
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal[50],
              child: Icon(Icons.description_outlined, color: Colors.teal[600]),
            ),
            title: Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Due: ${_formatDueDate(submissionDate)}',
              style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple[200]!),
                      ),
                      child: Text(
                        message,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (content.isNotEmpty) ...[
                    Text(
                      'Content:',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        content,
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (_hasSubmitted) ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _existingFileName != null
                                ? 'Submitted: $_existingFileName'
                                : 'Worksheet already submitted',
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Submit your completed worksheet as a file from your phone.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSubmitting ? null : _pickFile,
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              _selectedFileName == null
                                  ? 'Upload file'
                                  : 'Change file',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.insert_drive_file,
                              size: 18, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _selectedFileName!,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitWorksheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[400],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Submit worksheet',
                                  style: AppTextStyles.buttonPrimary,
                                ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonAssignmentTile extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final bool initiallyExpanded;

  const _LessonAssignmentTile({
    required this.assignment,
    this.initiallyExpanded = false,
  });

  @override
  State<_LessonAssignmentTile> createState() => _LessonAssignmentTileState();
}

class _LessonAssignmentTileState extends State<_LessonAssignmentTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.assignment['title'] as String? ?? 'Untitled Lesson';
    final content = widget.assignment['content'] as String? ?? '';
    final message = widget.assignment['message'] as String? ?? '';

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
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[50],
              child: Icon(Icons.bookmark, color: Colors.purple[600]),
            ),
            title: Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Lesson - View only',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple[200]!),
                      ),
                      child: Text(
                        message,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (content.isNotEmpty) ...[
                    Text(
                      'Content:',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        content,
                        style: AppTextStyles.body.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final Map<String, dynamic> submission;

  const _SubmissionTile({required this.submission});

  String _formatDate(dynamic submittedAt) {
    if (submittedAt == null) return 'Unknown date';
    try {
      Timestamp timestamp;
      if (submittedAt is Timestamp) {
        timestamp = submittedAt;
      } else {
        return 'Invalid date';
      }
      final date = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Submitted today';
      } else if (difference.inDays == 1) {
        return 'Submitted yesterday';
      } else {
        return 'Submitted ${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignmentId = submission['assignmentId'] as String? ?? '';
    final score = submission['score'] as int?;
    final total = submission['totalQuestions'] as int?;
    final percentage = submission['percentage'] as double?;
    final submittedAt = submission['submittedAt'];

    return FutureBuilder<Map<String, dynamic>?>(
      future: context.read<StudentAssignmentProvider>().getAssignment(assignmentId),
      builder: (context, snapshot) {
        final assignment = snapshot.data;
        final title = assignment?['title'] as String? ?? 'Quiz';

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
              child: Icon(Icons.check_circle_outline, color: Colors.purple[600]),
            ),
            title: Text(
              title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(submittedAt),
                  style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
                ),
                if (score != null && total != null)
                  Text(
                    'Score: $score/$total (${percentage?.toStringAsFixed(1)}%)',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      color: percentage! >= 80
                          ? Colors.green[700]
                          : percentage >= 60
                              ? Colors.blue[700]
                              : Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        );
      },
    );
  }
}
