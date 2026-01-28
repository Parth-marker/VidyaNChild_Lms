import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/features/teachers/teacher_provider.dart';
import 'package:lms_project/features/teachers/widgets/assignment_form_dialog.dart';
import 'package:lms_project/features/teachers/widgets/quiz_question_builder.dart';
import 'package:lms_project/features/teachers/worksheet_submissions_page.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

class TeacherTasksPage extends StatefulWidget {
  const TeacherTasksPage({super.key});

  @override
  State<TeacherTasksPage> createState() => _TeacherTasksPageState();
}

class _TeacherTasksPageState extends State<TeacherTasksPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TeacherProvider>().loadDashboard());
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AssignmentFormDialog(),
    );

    if (result != null && mounted) {
      final teacher = context.read<TeacherProvider>();
      final assignmentId = await teacher.createAssignment(result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              assignmentId != null
                  ? (result['publish'] == true ? 'Assignment published!' : 'Draft saved!')
                  : 'Failed to create assignment',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> assignment) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AssignmentFormDialog(assignment: assignment),
    );

    if (result != null && mounted) {
      final teacher = context.read<TeacherProvider>();
      final assignmentId = assignment['id'] as String? ?? '';
      final success = await teacher.updateAssignment(assignmentId, result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? (result['publish'] == true ? 'Assignment published!' : 'Draft updated!')
                  : 'Failed to update assignment',
            ),
          ),
        );
      }
      
      if (success && result['publish'] == true) {
        // Reload dashboard to update lists
        teacher.loadDashboard();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teacher = context.watch<TeacherProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Tasks & Assignments', style: AppTextStyles.h1Teal),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: teacher.loading
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: teacher.completionStats(),
                builder: (context, assignmentsSnapshot) {
                  final publishedAssignments = assignmentsSnapshot.data
                          ?.where((a) => (a['status'] as String?) == 'published')
                          .toList() ??
                      [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ActionCard(
                          title: 'Create New Assignment',
                          subtitle: 'Design a fresh worksheet, quiz, or project brief.',
                          buttonLabel: teacher.saving ? 'Saving...' : 'Create',
                          icon: Icons.add_task,
                          onPressed: teacher.saving ? () {} : _showCreateDialog,
                        ),
                        const SizedBox(height: 16),
                        if (teacher.drafts.isNotEmpty) ...[
                          Text(
                            'Drafts',
                            style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          ...teacher.drafts.map(
                            (d) => _AssignmentDraftTile(
                              assignment: d,
                              onTap: () {
                                _showEditDialog(d);
                              },
                              onDelete: () async {
                                final assignmentId = d['id'] as String? ?? '';
                                if (assignmentId.isNotEmpty && mounted) {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Draft'),
                                      content: const Text('Are you sure you want to delete this draft? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && mounted) {
                                    final success = await teacher.deleteAssignment(assignmentId);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'Draft deleted!' : 'Failed to delete draft'),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (publishedAssignments.isNotEmpty) ...[
                          Text(
                            'Published Assignments',
                            style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          ...publishedAssignments.map(
                            (assignment) => _PublishedAssignmentTile(
                              assignment: assignment,
                              teacher: teacher,
                              onDelete: () async {
                                final assignmentId = assignment['id'] as String? ?? '';
                                if (assignmentId.isNotEmpty && mounted) {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Assignment'),
                                      content: const Text('Are you sure you want to delete this published assignment? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && mounted) {
                                    final success = await teacher.deleteAssignment(assignmentId);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'Assignment deleted!' : 'Failed to delete assignment'),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (teacher.drafts.isEmpty && publishedAssignments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'No assignments yet. Create your first assignment!',
                                style: AppTextStyles.body.copyWith(color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 2),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onPressed;

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.teal[600], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[300],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                buttonLabel,
                style: AppTextStyles.buttonPrimary.copyWith(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentDraftTile extends StatelessWidget {
  const _AssignmentDraftTile({
    required this.assignment,
    required this.onTap,
    required this.onDelete,
  });

  final Map<String, dynamic> assignment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData _getIcon(String? assignmentType) {
    if (assignmentType == 'Lesson') {
      return Icons.bookmark; // Bookmark icon for lesson drafts (orange)
    } else if (assignmentType == 'Quiz') {
      return Icons.quiz; // Quiz icon for quiz drafts (orange)
    }
    return Icons.edit_note; // Edit note icon for worksheet drafts (orange)
  }

  Color _getIconColor(String? assignmentType) {
    // For drafts, all types use orange
    return Colors.orange;
  }

  Color _getIconBgColor(String? assignmentType) {
    // For drafts, all types use orange background
    return Colors.orange[50]!;
  }

  @override
  Widget build(BuildContext context) {
    final title = assignment['title'] as String? ?? 'Untitled Assignment';
    final assignmentType = assignment['assignmentType'] as String? ?? '';
    String lastEdited = 'Draft';
    
    if (assignment['updatedAt'] != null) {
      if (assignment['updatedAt'] is Timestamp) {
        final date = (assignment['updatedAt'] as Timestamp).toDate();
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays > 0) {
          lastEdited = 'Edited ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
        } else if (difference.inHours > 0) {
          lastEdited = 'Edited ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
        } else if (difference.inMinutes > 0) {
          lastEdited = 'Edited ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
        } else {
          lastEdited = 'Just edited';
        }
      } else if (assignment['lastEdited'] is Timestamp) {
        final date = (assignment['lastEdited'] as Timestamp).toDate();
        final now = DateTime.now();
        final difference = now.difference(date);
        
        if (difference.inDays > 0) {
          lastEdited = 'Edited ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
        } else if (difference.inHours > 0) {
          lastEdited = 'Edited ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
        } else if (difference.inMinutes > 0) {
          lastEdited = 'Edited ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
        } else {
          lastEdited = 'Just edited';
        }
      }
    }

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
          backgroundColor: _getIconBgColor(assignmentType),
          child: Icon(_getIcon(assignmentType), color: _getIconColor(assignmentType)),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (assignmentType.isNotEmpty) ...[
              Text(
                assignmentType,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
            Text(
              lastEdited,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            Text(
              'Draft - Tap to edit',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: Colors.teal[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'edit') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _PublishedAssignmentTile extends StatefulWidget {
  const _PublishedAssignmentTile({
    required this.assignment,
    required this.teacher,
    required this.onDelete,
  });

  final Map<String, dynamic> assignment;
  final TeacherProvider teacher;
  final VoidCallback onDelete;

  @override
  State<_PublishedAssignmentTile> createState() => _PublishedAssignmentTileState();
}

class _PublishedAssignmentTileState extends State<_PublishedAssignmentTile> {
  bool _isExpanded = false;

  List<QuizQuestion> _parseQuizQuestions(String content) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((q) => QuizQuestion.fromMap(q))
            .toList();
      }
    } catch (_) {
      // If parsing fails, we'll fall back to showing raw content text
    }
    return [];
  }

  IconData _getIcon(String? assignmentType) {
    if (assignmentType == 'Lesson') {
      return Icons.bookmark;
    } else if (assignmentType == 'Quiz') {
      return Icons.quiz;
    }
    return Icons.assignment;
  }

  Color _getIconColor(String? assignmentType) {
    if (assignmentType == 'Lesson') {
      return Colors.purple;
    } else if (assignmentType == 'Quiz') {
      return Colors.blue;
    }
    return Colors.teal;
  }

  Color _getIconBgColor(String? assignmentType) {
    if (assignmentType == 'Lesson') {
      return Colors.purple[50]!;
    } else if (assignmentType == 'Quiz') {
      return Colors.blue[50]!;
    }
    return Colors.teal[50]!;
  }

  @override
  Widget build(BuildContext context) {
    final assignmentId = widget.assignment['id'] as String? ?? '';
    final title = widget.assignment['title'] as String? ?? 'Assignment';
    final assignmentType = widget.assignment['assignmentType'] as String? ?? '';
    final content = widget.assignment['content'] as String? ?? '';

    // Pre‑parse quiz questions (if applicable) so we can show them nicely in the details section
    final bool isQuiz = assignmentType == 'Quiz';
    final List<QuizQuestion> quizQuestions =
        (isQuiz && content.isNotEmpty) ? _parseQuizQuestions(content) : const [];
    final message = widget.assignment['message'] as String? ?? '';

    // Only get submission stats for Worksheets and Quizzes, not Lessons
    if (assignmentType == 'Lesson') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getIconBgColor(assignmentType),
                      child: Icon(_getIcon(assignmentType), color: _getIconColor(assignmentType)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (assignmentType.isNotEmpty)
                            Text(
                              assignmentType,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'view') {
                          setState(() => _isExpanded = !_isExpanded);
                        } else if (value == 'delete') {
                          widget.onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
                              const SizedBox(width: 8),
                              Text(_isExpanded ? 'Hide Details' : 'View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  if (message.isNotEmpty) ...[
                    Text(
                      'Message:',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (content.isNotEmpty) ...[
                    Text(
                      'Content:',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      );
    }

    // For Worksheets and Quizzes, show submission stats
    return StreamBuilder<Map<String, int>>(
      stream: widget.teacher.getSubmissionStats(assignmentId),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'total': 0, 'submitted': 0, 'percentage': 0};
        final total = stats['total'] ?? 0;
        final submitted = stats['submitted'] ?? 0;
        final percentage = stats['percentage'] ?? 0;
        final percent = total > 0 ? (submitted / total) : 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                setState(() => _isExpanded = !_isExpanded);
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getIconBgColor(assignmentType),
                        child: Icon(_getIcon(assignmentType), color: _getIconColor(assignmentType)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (assignmentType.isNotEmpty)
                              Text(
                                assignmentType,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: AppTextStyles.body.copyWith(color: Colors.teal[700]),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'view') {
                            setState(() => _isExpanded = !_isExpanded);
                          } else if (value == 'delete') {
                            widget.onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
                                const SizedBox(width: 8),
                                Text(_isExpanded ? 'Hide Details' : 'View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.teal[400],
                    backgroundColor: Colors.teal[50],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$submitted / $total submissions',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  if (assignmentType == 'Worksheet') ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorksheetSubmissionsPage(
                                assignmentId: assignmentId,
                                assignmentTitle: title,
                              ),
                            ),
                          );
                        },
                        child: const Text('View submissions'),
                      ),
                    ),
                  ],
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (message.isNotEmpty) ...[
                      Text(
                        'Message:',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isQuiz && quizQuestions.isNotEmpty) ...[
                      Text(
                        'Quiz Questions:',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...quizQuestions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${index + 1}. ${question.questionText}',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...question.options.asMap().entries.map((optEntry) {
                                final optIndex = optEntry.key;
                                final optionText = optEntry.value;
                                final bool isCorrect =
                                    optIndex == question.correctAnswerIndex;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        isCorrect
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 16,
                                        color: isCorrect ? Colors.green : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          optionText,
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 13,
                                            color: isCorrect
                                                ? Colors.green[800]
                                                : Colors.black87,
                                            fontWeight:
                                                isCorrect ? FontWeight.w600 : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ] else if (content.isNotEmpty) ...[
                      Text(
                        'Content:',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
