import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class WorksheetSubmissionsPage extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;

  const WorksheetSubmissionsPage({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
  });

  @override
  State<WorksheetSubmissionsPage> createState() =>
      _WorksheetSubmissionsPageState();
}

class _WorksheetSubmissionsPageState extends State<WorksheetSubmissionsPage> {
  final _db = FirebaseFirestore.instance;
  final Map<String, TextEditingController> _scoreControllers = {};

  @override
  void dispose() {
    for (final controller in _scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file')),
      );
    }
  }

  Future<void> _saveScore(String submissionId, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    final score = double.tryParse(trimmed);
    if (score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for marks')),
      );
      return;
    }

    await _db.collection('submissions').doc(submissionId).update({
      'score': score,
      'markedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marks saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'Submissions • ${widget.assignmentTitle}',
          style: AppTextStyles.h1Teal,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('submissions')
            .where('assignmentId', isEqualTo: widget.assignmentId)
            .where('assignmentType', isEqualTo: 'Worksheet')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading submissions',
                  style: AppTextStyles.body,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No worksheet submissions yet.',
                  style: AppTextStyles.body.copyWith(color: Colors.black54),
                ),
              ),
            );
          }

          // Collect scores for simple bar chart
          final scores = docs
              .map((d) => (d.data() as Map<String, dynamic>)['score'])
              .where((value) => value is num)
              .map((value) => (value as num).toDouble())
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scores.isNotEmpty) ...[
                  Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Worksheet Marks Overview',
                          style: AppTextStyles.h1Purple
                              .copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 160,
                          child: _SimpleBarChart(values: scores),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Submissions',
                        style: AppTextStyles.h1Purple
                            .copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      ...docs.map((doc) {
                        final data =
                            doc.data() as Map<String, dynamic>? ?? {};
                        final submissionId = doc.id;
                        final studentId =
                            data['studentId'] as String? ?? '';
                        final fileName =
                            data['fileName'] as String? ?? 'File';
                        final fileUrl = data['fileUrl'] as String?;
                        final status =
                            data['status'] as String? ?? 'submitted';
                        final scoreValue = data['score'] as num?;

                        final controller =
                            _scoreControllers.putIfAbsent(
                          submissionId,
                          () => TextEditingController(
                            text: scoreValue != null
                                ? scoreValue.toString()
                                : '',
                          ),
                        );

                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          child: _SubmissionTile(
                            studentId: studentId,
                            fileName: fileName,
                            fileUrl: fileUrl,
                            status: status,
                            scoreController: controller,
                            onOpenFile: fileUrl != null
                                ? () => _openFile(fileUrl)
                                : null,
                            onSaveScore: () =>
                                _saveScore(submissionId, controller.text),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final String studentId;
  final String fileName;
  final String? fileUrl;
  final String status;
  final TextEditingController scoreController;
  final VoidCallback? onOpenFile;
  final VoidCallback onSaveScore;

  const _SubmissionTile({
    required this.studentId,
    required this.fileName,
    required this.fileUrl,
    required this.status,
    required this.scoreController,
    required this.onOpenFile,
    required this.onSaveScore,
  });

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.teal[50],
            child: Icon(Icons.person, color: Colors.teal[700]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: db.collection('users').doc(studentId).snapshots(),
                  builder: (context, snapshot) {
                    String name = 'Student';
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      name = data?['name'] as String? ?? 'Student';
                    }
                    return Text(
                      name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'submitted'
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == 'submitted'
                            ? 'Submitted'
                            : status,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 11,
                          color: status == 'submitted'
                              ? Colors.green[800]
                              : Colors.orange[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        fileName,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (fileUrl != null) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.open_in_new,
                          size: 18,
                        ),
                        onPressed: onOpenFile,
                        tooltip: 'Open file',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: scoreController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Marks',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onSaveScore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[400],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: AppTextStyles.buttonPrimary
                            .copyWith(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<double> values;

  const _SimpleBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Center(
        child: Text(
          'No marks yet',
          style: AppTextStyles.body.copyWith(color: Colors.black54),
        ),
      );
    }

    final maxValue = values.fold<double>(
      0,
      (prev, element) => element > prev ? element : prev,
    );
    final effectiveMax = maxValue > 0 ? maxValue : 10;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    values[i].toStringAsFixed(1),
                    style: AppTextStyles.body.copyWith(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 100 *
                        (values[i] / effectiveMax).clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: Colors.teal[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}


