import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms_project/features/student_home/home_provider.dart';
import 'package:lms_project/models/assignment_model.dart';
import 'package:lms_project/models/submission_model.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms_project/features/games/quiz_questions.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DigitizedAssignmentsPage extends StatelessWidget {
  final String? expandAssignment;

  const DigitizedAssignmentsPage({super.key, this.expandAssignment});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF9E6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text('Practice & Assignments', style: AppTextStyles.h1Teal),
          bottom: TabBar(
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black54,
            tabs: const [
              Tab(text: 'Assignments'),
              Tab(text: 'Practice'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AssignmentsTab(expandAssignment: expandAssignment),
            const _PracticeTab(),
          ],
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      ),
    );
  }
}

class _AssignmentsTab extends StatefulWidget {
  final String? expandAssignment;
  const _AssignmentsTab({this.expandAssignment});

  @override
  State<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<_AssignmentsTab> {
  Future<void> _showUploadDialog(List<Assignment> assignments) async {
    if (assignments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No assignments available to upload.')),
      );
      return;
    }

    Assignment selected = assignments.first;
    PlatformFile? pickedFile;
    String? error;
    bool uploading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickFile() async {
              final result = await FilePicker.platform.pickFiles();
              if (result == null || result.files.isEmpty) return;
              setSheetState(() {
                pickedFile = result.files.first;
                error = null;
              });
            }

            Future<void> upload() async {
              if (pickedFile == null || pickedFile?.path == null) {
                setSheetState(() {
                  error = 'Please select a file to upload.';
                });
                return;
              }
              setSheetState(() {
                uploading = true;
                error = null;
              });
              try {
                final studentId =
                    FirebaseAuth.instance.currentUser?.uid ?? 'demo';
                final upload = await context
                    .read<HomeProvider>()
                    .uploadSubmissionAttachment(
                      assignmentId: selected.id,
                      studentId: studentId,
                      file: File(pickedFile!.path!),
                      fileName: pickedFile!.name,
                    );

                final submission = Submission(
                  id: '',
                  assignmentId: selected.id,
                  assignmentTitle: selected.title,
                  subject: selected.subject,
                  studentId: studentId,
                  studentName: 'Student',
                  answers: const {},
                  score: 0,
                  submittedAt: DateTime.now(),
                  attachmentUrl: upload['url'],
                  attachmentName: upload['name'],
                );

                await context.read<HomeProvider>().submitAssignment(submission);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assignment uploaded successfully.'),
                    ),
                  );
                }
              } catch (e) {
                setSheetState(() {
                  error = 'Upload failed: $e';
                });
              } finally {
                setSheetState(() {
                  uploading = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upload Completed Assignment',
                    style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Assignment>(
                    value: selected,
                    items: assignments
                        .map(
                          (a) => DropdownMenuItem(
                            value: a,
                            child: Text(a.title),
                          ),
                        )
                        .toList(),
                    onChanged: uploading
                        ? null
                        : (value) {
                            if (value == null) return;
                            setSheetState(() {
                              selected = value;
                            });
                          },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pickedFile?.name ?? 'No file selected',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: uploading ? null : pickFile,
                        child: const Text('Choose File'),
                      ),
                    ],
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        error!,
                        style: AppTextStyles.body.copyWith(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: uploading ? null : upload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[400],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: uploading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Upload',
                            style: AppTextStyles.buttonPrimary,
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Math', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          StreamBuilder<List<Assignment>>(
            stream: context.watch<HomeProvider>().getAssignments(),
            builder: (context, snapshot) {
              final assignments = snapshot.data ?? [];
              if (assignments.isEmpty) {
                return Text(
                  'No assignments yet.',
                  style: AppTextStyles.body.copyWith(color: Colors.black54),
                );
              }
              return Column(
                children: assignments
                    .map(
                      (a) => _AssignmentTile(
                        assignment: a,
                        initiallyExpanded: widget.expandAssignment == a.title,
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          _LearningSummaryCard(),
          const SizedBox(height: 16),
          StreamBuilder<List<Assignment>>(
            stream: context.watch<HomeProvider>().getAssignments(),
            builder: (context, snapshot) {
              final assignments = snapshot.data ?? [];
              return ElevatedButton.icon(
                onPressed: assignments.isEmpty
                    ? null
                    : () => _showUploadDialog(assignments),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[400],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.upload_file, color: Colors.white),
                label: Text(
                  'Upload Completed Assignments',
                  style: AppTextStyles.buttonPrimary,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          Text(
            'Recent Submissions',
            style: AppTextStyles.h1Purple.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<Submission>>(
            stream: context.watch<HomeProvider>().getMySubmissions(),
            builder: (context, snapshot) {
              final submissions = snapshot.data ?? [];
              if (submissions.isEmpty) {
                return Text(
                  'No submissions yet.',
                  style: AppTextStyles.body.copyWith(color: Colors.black54),
                );
              }
              return Column(
                children: submissions
                    .map((s) {
                      final scoreLabel = s.score > 0
                          ? 'Score: ${s.score.round()}%'
                          : 'Pending grading';
                      final attachmentLabel = s.attachmentName != null
                          ? 'File: ${s.attachmentName}'
                          : null;
                      final subtitleParts = [
                        'Submitted on ${s.submittedAt.day}/${s.submittedAt.month}',
                        scoreLabel,
                        if (attachmentLabel != null) attachmentLabel,
                      ];
                      return _SubmissionTile(
                        title:
                            s.assignmentTitle.isNotEmpty ? s.assignmentTitle : 'Assignment',
                        subtitle: subtitleParts.join(' • '),
                      );
                    })
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LearningSummaryCard extends StatelessWidget {
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.insights, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Learning Summary',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final byteData = await rootBundle.load(
                'assets/files/Sample.docx',
              );
              // Get temporary directory
              final tempDir = await getTemporaryDirectory();
              final file = File('${tempDir.path}/Sample.docx');
              // Write file
              await file.writeAsBytes(byteData.buffer.asUint8List());
              // Open file using default app (Word, Google Docs, etc.)
              await OpenFile.open(file.path);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Open',
              style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeTab extends StatelessWidget {
  const _PracticeTab();

  @override
  Widget build(BuildContext context) {
    final chapters = QuizQuestions.getCategories();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return _ChapterTile(chapter: chapter);
      },
    );
  }
}

class _ChapterTile extends StatefulWidget {
  final String chapter;
  const _ChapterTile({required this.chapter});

  @override
  State<_ChapterTile> createState() => _ChapterTileState();
}

class _ChapterTileState extends State<_ChapterTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange[50],
              child: const Icon(Icons.menu_book, color: Colors.orange),
            ),
            title: Text(
              widget.chapter,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Practice Quiz',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded) _PracticeQuizContent(chapter: widget.chapter),
        ],
      ),
    );
  }
}

class _PracticeQuizContent extends StatefulWidget {
  final String chapter;
  const _PracticeQuizContent({required this.chapter});

  @override
  State<_PracticeQuizContent> createState() => _PracticeQuizContentState();
}

class _PracticeQuizContentState extends State<_PracticeQuizContent> {
  final Map<int, int> _answers = {};
  bool _submitted = false;
  double _score = 0;

  @override
  Widget build(BuildContext context) {
    final questions = QuizQuestions.getByChapter(widget.chapter);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_submitted) ...[
            Text(
              'Select the correct answer for each question:',
              style: AppTextStyles.body.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ...questions.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              return _QuestionWidget(
                questionNumber: idx + 1,
                question: q.question,
                options: q.options,
                selectedOptionIndex: _answers[idx],
                onChanged: (val) {
                  setState(() {
                    _answers[idx] = val;
                  });
                },
              );
            }).toList(),
            ElevatedButton(
              onPressed: () {
                if (_answers.length < questions.length) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please answer all questions'),
                    ),
                  );
                  return;
                }

                int correct = 0;
                for (int i = 0; i < questions.length; i++) {
                  if (_answers[i] == questions[i].correctAnswerIndex) {
                    correct++;
                  }
                }

                setState(() {
                  _score = (correct / questions.length) * 100;
                  _submitted = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Submit Practice Quiz'),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    'Practice Completed!',
                    style: AppTextStyles.h1Purple.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Score: ${_score.round()}%',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _submitted = false;
                        _answers.clear();
                      });
                    },
                    child: const Text('Try Again'),
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

class _AssignmentTile extends StatefulWidget {
  final Assignment assignment;
  final bool initiallyExpanded;
  const _AssignmentTile({
    required this.assignment,
    this.initiallyExpanded = false,
  });

  @override
  State<_AssignmentTile> createState() => _AssignmentTileState();
}

class _AssignmentTileState extends State<_AssignmentTile> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

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
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal[50],
              child: const Icon(Icons.description_outlined, color: Colors.teal),
            ),
            title: Text(
              widget.assignment.title,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Due: ${widget.assignment.dueDate.day}/${widget.assignment.dueDate.month} • ${widget.assignment.type}',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded) _WorksheetContent(assignment: widget.assignment),
        ],
      ),
    );
  }
}

class _WorksheetContent extends StatefulWidget {
  final Assignment assignment;

  const _WorksheetContent({required this.assignment});

  @override
  State<_WorksheetContent> createState() => _WorksheetContentState();
}

class _WorksheetContentState extends State<_WorksheetContent> {
  final Map<int, int> _answers = {};

  @override
  Widget build(BuildContext context) {
    final questions = widget.assignment.questions ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.assignment.description.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple[200]!),
              ),
              child: Text(
                widget.assignment.description,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple[900],
                ),
              ),
            ),

          if (widget.assignment.type == 'Syllabus resources')
            const _SyllabusTable()
          else if (questions.isNotEmpty)
            ...questions.asMap().entries.map((entry) {
              final idx = entry.key;
              final q = entry.value;
              return _QuestionWidget(
                questionNumber: idx + 1,
                question: q.questionText,
                options: q.options,
                selectedOptionIndex: _answers[idx],
                onChanged: (val) {
                  setState(() {
                    _answers[idx] = val;
                  });
                },
              );
            }).toList(),

          if (widget.assignment.type != 'Syllabus resources' &&
              questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton(
                onPressed: () async {
                  // Calculate score
                  int correct = 0;
                  final Map<String, int> submissionAnswers = {};
                  for (int i = 0; i < questions.length; i++) {
                    final selectedIndex = _answers[i];
                    if (selectedIndex != null) {
                      submissionAnswers[i.toString()] = selectedIndex;
                      if (selectedIndex == questions[i].correctOptionIndex) {
                        correct++;
                      }
                    }
                  }
                  double score = (questions.isNotEmpty)
                      ? (correct / questions.length) * 100
                      : 0;

                  final submission = Submission(
                    id: '',
                    assignmentId: widget.assignment.id,
                    assignmentTitle: widget.assignment.title,
                    subject: widget.assignment.subject,
                    studentId: FirebaseAuth.instance.currentUser?.uid ?? 'demo',
                    studentName:
                        'Student', // In real app, get from user profile
                    answers: submissionAnswers,
                    score: score,
                    submittedAt: DateTime.now(),
                  );

                  await context.read<HomeProvider>().submitAssignment(
                    submission,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Submission successful! Your score: ${score.round()}%',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit Assignment',
                  style: AppTextStyles.buttonPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionWidget extends StatelessWidget {
  final int questionNumber;
  final String question;
  final List<String> options;
  final int? selectedOptionIndex;
  final ValueChanged<int> onChanged;

  const _QuestionWidget({
    required this.questionNumber,
    required this.question,
    required this.options,
    this.selectedOptionIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$questionNumber. $question',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          ...options.asMap().entries.map(
            (entry) => RadioListTile<int>(
              title: Text(
                entry.value,
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
              value: entry.key,
              groupValue: selectedOptionIndex,
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyllabusTable extends StatelessWidget {
  const _SyllabusTable();

  @override
  Widget build(BuildContext context) {
    final syllabusData = [
      {
        'chapterNo': '1',
        'chapterName': 'Integers',
        'keyTopics':
            'Number line representation, addition and subtraction rules, properties (closure, commutative, associative, identity, inverse), multiplication and division of integers, word problems',
      },
      {
        'chapterNo': '2',
        'chapterName': 'Fractions and Decimals',
        'keyTopics':
            'Types of fractions, equivalent and simplest form, operations on fractions, decimal representation, terminating and non-terminating decimals, operations on decimals, word problems',
      },
      {
        'chapterNo': '3',
        'chapterName': 'Data Handling',
        'keyTopics':
            'Collection and organization of data, mean, median, mode, bar graphs, pictographs, interpretation of data, introduction to probability',
      },
      {
        'chapterNo': '4',
        'chapterName': 'Simple Equations',
        'keyTopics':
            'Algebraic expressions, formation of equations, solving one-step and two-step equations, verification, word problems',
      },
      {
        'chapterNo': '5',
        'chapterName': 'Lines and Angles',
        'keyTopics':
            'Basic terms, types of angles, angle pairs, parallel lines and transversals, corresponding and alternate angles',
      },
      {
        'chapterNo': '6',
        'chapterName': 'The Triangle and Its Properties',
        'keyTopics':
            'Types of triangles, medians, altitudes, angle sum property, exterior angle property, Pythagoras property (introduction)',
      },
      {
        'chapterNo': '7',
        'chapterName': 'Congruence of Triangles',
        'keyTopics':
            'Congruent figures, triangle congruence criteria (SSS, SAS, ASA, RHS), applications',
      },
      {
        'chapterNo': '8',
        'chapterName': 'Comparing Quantities',
        'keyTopics':
            'Ratio and proportion, percentages, increase and decrease percentage, profit and loss, simple interest, real-life applications',
      },
      {
        'chapterNo': '9',
        'chapterName': 'Rational Numbers',
        'keyTopics':
            'Definition, number line representation, standard form, comparison, operations, properties of rational numbers',
      },
      {
        'chapterNo': '10',
        'chapterName': 'Practical Geometry',
        'keyTopics':
            'Construction of triangles (SSS, SAS, ASA), use of ruler and compass',
      },
      {
        'chapterNo': '11',
        'chapterName': 'Perimeter and Area',
        'keyTopics':
            'Perimeter of square, rectangle and triangle, area of square and rectangle, word problems',
      },
      {
        'chapterNo': '12',
        'chapterName': 'Algebraic Expressions',
        'keyTopics':
            'Variables, constants, terms and coefficients, like and unlike terms, addition and subtraction, evaluation',
      },
      {
        'chapterNo': '13',
        'chapterName': 'Exponents and Powers',
        'keyTopics':
            'Laws of exponents, powers of 10, expressing large numbers, simplification',
      },
      {
        'chapterNo': '14',
        'chapterName': 'Symmetry',
        'keyTopics':
            'Line symmetry, symmetrical figures, lines of symmetry, introduction to rotational symmetry',
      },
      {
        'chapterNo': '15',
        'chapterName': 'Visualising Solid Shapes',
        'keyTopics':
            '3D shapes, faces, edges and vertices, nets, top, front and side views, polyhedrons',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.grey[300]!, width: 1),
          columnWidths: {
            0: const FixedColumnWidth(250),
            1: const FixedColumnWidth(600),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: Colors.teal[100]),
              children: [
                _TableCell(text: 'Chapter Name', isHeader: true),
                _TableCell(text: 'Key Topics covered', isHeader: true),
              ],
            ),
            // Data rows
            ...syllabusData.map(
              (data) => TableRow(
                decoration: BoxDecoration(color: Colors.white),
                children: [
                  _TableCell(
                    text: '${data['chapterNo']}. ${data['chapterName']}',
                    isHeader: false,
                  ),
                  _TableCell(text: data['keyTopics']!, isHeader: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell({required this.text, required this.isHeader});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      alignment: isHeader && text == 'Chapter No.'
          ? Alignment.center
          : Alignment.topLeft,
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
          fontSize: isHeader ? 14 : 13,
          color: isHeader ? Colors.teal[900] : Colors.black87,
        ),
        textAlign: isHeader && text == 'Chapter No.'
            ? TextAlign.center
            : TextAlign.left,
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SubmissionTile({required this.title, required this.subtitle});

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
          child: const Icon(Icons.check_circle_outline, color: Colors.purple),
        ),
        title: Text(
          title,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}
