import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DigitizedAssignmentsPage extends StatelessWidget {
  final String? expandAssignment;
  
  const DigitizedAssignmentsPage({super.key, this.expandAssignment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Assignments', style: AppTextStyles.h1Teal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Math', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            _AssignmentTile(title: 'Integers', due: '2026-05-15', initiallyExpanded: expandAssignment == 'Integers'),
            _AssignmentTile(title: 'Fractions and Decimals', due: '2026-05-15', initiallyExpanded: expandAssignment == 'Fractions and Decimals'),
            _AssignmentTile(title: 'Data Handling', due: '2026-05-15', initiallyExpanded: expandAssignment == 'Data Handling'),
            _AssignmentTile(title: 'Syllabus resources', due: 'N/A', initiallyExpanded: expandAssignment == 'Syllabus resources'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ]),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.insights, color: Colors.teal),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Learning Summary', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),

                  ElevatedButton(
                    onPressed: () async {
                        final byteData = await rootBundle.load('assets/files/Sample.docx');
                        // Get temporary directory
                        final tempDir = await getTemporaryDirectory();
                        final file = File('${tempDir.path}/Sample.docx');
                        // Write file
                        await file.writeAsBytes(byteData.buffer.asUint8List());
                        // Open file using default app (Word, Google Docs, etc.)
                        await OpenFile.open(file.path);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Open', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[400],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: Text('Upload Completed Assignments', style: AppTextStyles.buttonPrimary),
            ),
            const SizedBox(height: 30),
            Text('Recent Submissions', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Column(
              children: const [
                _SubmissionTile(title: 'Decimals Drill', date: 'Submitted today'),
                _SubmissionTile(title: 'Angles Worksheet', date: 'Submitted 2 days ago'),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
    );
  }
}

class _AssignmentTile extends StatefulWidget {
  final String title;
  final String due;
  final bool initiallyExpanded;
  const _AssignmentTile({required this.title, required this.due, this.initiallyExpanded = false});

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
    final bool hasWorksheet = widget.title == 'Integers' || 
                              widget.title == 'Fractions and Decimals' || 
                              widget.title == 'Data Handling' ||
                              widget.title == 'Syllabus resources';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.teal[50], child: const Icon(Icons.description_outlined, color: Colors.teal)),
            title: Text(widget.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('Due: ${widget.due}', style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              if (hasWorksheet) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              }
            },
          ),
          if (_isExpanded && hasWorksheet) _WorksheetContent(assignmentTitle: widget.title),
        ],
      ),
    );
  }
}

class _WorksheetContent extends StatelessWidget {
  final String assignmentTitle;
  
  const _WorksheetContent({required this.assignmentTitle});

  String _getMessage() {
    if (assignmentTitle == 'Integers') {
      return 'Hello students. Please complete this worksheet on integers:';
    } else if (assignmentTitle == 'Fractions and Decimals') {
      return 'Hello students. Please complete this worksheet on fractions and decimals:';
    } else if (assignmentTitle == 'Data Handling') {
      return 'Hello students. Please complete this worksheet on data handling:';
    } else if (assignmentTitle == 'Syllabus resources') {
      return 'Hello students, please find your grade 7 mathematics syllabus and revision notes:';
    }
    return 'Hello students. Please complete this worksheet:';
  }

  List<_QuestionWidget> _getQuestions() {
    if (assignmentTitle == 'Integers') {
      return [
        _QuestionWidget(
          questionNumber: 1,
          question: 'What is the additive inverse of −9?',
          options: ['A) 9', 'B) −9', 'C) 0', 'D) 18'],
        ),
        _QuestionWidget(
          questionNumber: 2,
          question: 'Which of the following is the smallest integer?',
          options: ['A) −3', 'B) 0', 'C) 5', 'D) −7'],
        ),
        _QuestionWidget(
          questionNumber: 3,
          question: 'What is the value of (−6) + 10?',
          options: ['A) −16', 'B) −4', 'C) 4', 'D) 16'],
        ),
        _QuestionWidget(
          questionNumber: 4,
          question: 'The product of two negative integers is always:',
          options: ['A) Negative', 'B) Positive', 'C) Zero', 'D) Cannot be determined'],
        ),
        _QuestionWidget(
          questionNumber: 5,
          question: 'What is the result of (−4) × 7?',
          options: ['A) 28', 'B) −28', 'C) −11', 'D) 11'],
        ),
        _QuestionWidget(
          questionNumber: 6,
          question: 'Which of the following statements is true?',
          options: ['A) −8 > −3', 'B) −5 = 5', 'C) −2 < 0', 'D) 0 < −1'],
        ),
        _QuestionWidget(
          questionNumber: 7,
          question: 'What is the value of (−20) ÷ (−5)?',
          options: ['A) −4', 'B) 4', 'C) −15', 'D) 15'],
        ),
        _QuestionWidget(
          questionNumber: 8,
          question: 'Which integer lies between −6 and −2?',
          options: ['A) −7', 'B) −6', 'C) −4', 'D) −2'],
        ),
        _QuestionWidget(
          questionNumber: 9,
          question: 'What is the value of 15 − (−7)?',
          options: ['A) 8', 'B) −8', 'C) 22', 'D) −22'],
        ),
        _QuestionWidget(
          questionNumber: 10,
          question: 'Which property is shown by (−3) + 5 = 5 + (−3)?',
          options: ['A) Closure', 'B) Commutative', 'C) Associative', 'D) Distributive'],
        ),
      ];
    } else if (assignmentTitle == 'Fractions and Decimals') {
      return [
        _QuestionWidget(
          questionNumber: 1,
          question: 'Which of the following is a proper fraction?',
          options: ['A) 7/4', 'B) 5/5', 'C) 3/8', 'D) 9/6'],
        ),
        _QuestionWidget(
          questionNumber: 2,
          question: 'Which fraction is equivalent to 3/4?',
          options: ['A) 6/10', 'B) 9/12', 'C) 12/20', 'D) 15/25'],
        ),
        _QuestionWidget(
          questionNumber: 3,
          question: 'What is the decimal form of 7/10?',
          options: ['A) 0.7', 'B) 0.07', 'C) 7.0', 'D) 0.17'],
        ),
        _QuestionWidget(
          questionNumber: 4,
          question: 'Which of the following is the greatest?',
          options: ['A) 0.45', 'B) 4/10', 'C) 0.405', 'D) 0.5'],
        ),
        _QuestionWidget(
          questionNumber: 5,
          question: 'What is the value of 2/5 + 3/5?',
          options: ['A) 1', 'B) 5/10', 'C) 1/5', 'D) 5/25'],
        ),
        _QuestionWidget(
          questionNumber: 6,
          question: 'Which fraction is equal to 0.25?',
          options: ['A) 1/2', 'B) 1/3', 'C) 1/4', 'D) 3/4'],
        ),
        _QuestionWidget(
          questionNumber: 7,
          question: 'What is the value of 0.6 − 0.2?',
          options: ['A) 0.2', 'B) 0.4', 'C) 0.8', 'D) 0.6'],
        ),
        _QuestionWidget(
          questionNumber: 8,
          question: 'Which of the following is a terminating decimal?',
          options: ['A) 1/3', 'B) 2/9', 'C) 3/8', 'D) 7/11'],
        ),
        _QuestionWidget(
          questionNumber: 9,
          question: 'What is the value of 4/5 × 10?',
          options: ['A) 8', 'B) 2', 'C) 40', 'D) 0.8'],
        ),
        _QuestionWidget(
          questionNumber: 10,
          question: 'Which of the following is true?',
          options: ['A) 0.5 = 1/5', 'B) 0.25 = 25/100', 'C) 3/10 = 0.03', 'D) 0.75 = 1/2'],
        ),
      ];
    } else if (assignmentTitle == 'Data Handling') {
      return [
        _QuestionWidget(
          questionNumber: 1,
          question: 'The number of students present in a class for 5 days is:\n20, 22, 21, 23, 24\nWhat is the mean number of students?',
          options: ['A) 21', 'B) 22', 'C) 23', 'D) 24'],
        ),
        _QuestionWidget(
          questionNumber: 2,
          question: 'Find the mode of the data:\n3, 5, 7, 5, 9, 5, 11',
          options: ['A) 3', 'B) 5', 'C) 7', 'D) 9'],
        ),
        _QuestionWidget(
          questionNumber: 3,
          question: 'What is the median of the following data?\n8, 3, 5, 10, 6',
          options: ['A) 5', 'B) 6', 'C) 8', 'D) 10'],
        ),
        _QuestionWidget(
          questionNumber: 4,
          question: 'The range of the data 4, 9, 2, 7, 6 is:',
          options: ['A) 5', 'B) 6', 'C) 7', 'D) 9'],
        ),
        _QuestionWidget(
          questionNumber: 5,
          question: 'Which of the following graphs is best used to compare data?',
          options: ['A) Bar graph', 'B) Pie chart', 'C) Pictograph', 'D) Histogram'],
        ),
        _QuestionWidget(
          questionNumber: 6,
          question: 'If the number of chocolates sold on Monday is shown by 🍫🍫🍫🍫 and each 🍫 represents 5 chocolates, how many chocolates were sold?',
          options: ['A) 10', 'B) 15', 'C) 20', 'D) 25'],
        ),
        _QuestionWidget(
          questionNumber: 7,
          question: 'The mean of 5 numbers is 12. What is their total sum?',
          options: ['A) 60', 'B) 17', 'C) 12', 'D) 5'],
        ),
        _QuestionWidget(
          questionNumber: 8,
          question: 'Which measure of central tendency represents the middle value of the data?',
          options: ['A) Mean', 'B) Mode', 'C) Median', 'D) Range'],
        ),
        _QuestionWidget(
          questionNumber: 9,
          question: 'If the highest value in a data set is 50 and the lowest is 20, the range is:',
          options: ['A) 20', 'B) 25', 'C) 30', 'D) 70'],
        ),
        _QuestionWidget(
          questionNumber: 10,
          question: 'How many times does the number 6 occur in the data:\n2, 6, 4, 6, 8, 6, 9',
          options: ['A) 2', 'B) 3', 'C) 4', 'D) 6'],
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teacher message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple[200]!),
            ),
            child: Text(
              _getMessage(),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.deepPurple[900],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Show syllabus table for Syllabus resources, otherwise show questions
          if (assignmentTitle == 'Syllabus resources')
            _SyllabusTable()
          else
            ..._getQuestions(),
        ],
      ),
    );
  }
}

class _QuestionWidget extends StatelessWidget {
  final int questionNumber;
  final String question;
  final List<String> options;

  const _QuestionWidget({
    required this.questionNumber,
    required this.question,
    required this.options,
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
          ...options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  option,
                  style: AppTextStyles.body.copyWith(fontSize: 14),
                ),
              )),
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
      {'chapterNo': '1', 'chapterName': 'Integers', 'keyTopics': 'Number line representation, addition and subtraction rules, properties (closure, commutative, associative, identity, inverse), multiplication and division of integers, word problems'},
      {'chapterNo': '2', 'chapterName': 'Fractions and Decimals', 'keyTopics': 'Types of fractions, equivalent and simplest form, operations on fractions, decimal representation, terminating and non-terminating decimals, operations on decimals, word problems'},
      {'chapterNo': '3', 'chapterName': 'Data Handling', 'keyTopics': 'Collection and organization of data, mean, median, mode, bar graphs, pictographs, interpretation of data, introduction to probability'},
      {'chapterNo': '4', 'chapterName': 'Simple Equations', 'keyTopics': 'Algebraic expressions, formation of equations, solving one-step and two-step equations, verification, word problems'},
      {'chapterNo': '5', 'chapterName': 'Lines and Angles', 'keyTopics': 'Basic terms, types of angles, angle pairs, parallel lines and transversals, corresponding and alternate angles'},
      {'chapterNo': '6', 'chapterName': 'The Triangle and Its Properties', 'keyTopics': 'Types of triangles, medians, altitudes, angle sum property, exterior angle property, Pythagoras property (introduction)'},
      {'chapterNo': '7', 'chapterName': 'Congruence of Triangles', 'keyTopics': 'Congruent figures, triangle congruence criteria (SSS, SAS, ASA, RHS), applications'},
      {'chapterNo': '8', 'chapterName': 'Comparing Quantities', 'keyTopics': 'Ratio and proportion, percentages, increase and decrease percentage, profit and loss, simple interest, real-life applications'},
      {'chapterNo': '9', 'chapterName': 'Rational Numbers', 'keyTopics': 'Definition, number line representation, standard form, comparison, operations, properties of rational numbers'},
      {'chapterNo': '10', 'chapterName': 'Practical Geometry', 'keyTopics': 'Construction of triangles (SSS, SAS, ASA), use of ruler and compass'},
      {'chapterNo': '11', 'chapterName': 'Perimeter and Area', 'keyTopics': 'Perimeter of square, rectangle and triangle, area of square and rectangle, word problems'},
      {'chapterNo': '12', 'chapterName': 'Algebraic Expressions', 'keyTopics': 'Variables, constants, terms and coefficients, like and unlike terms, addition and subtraction, evaluation'},
      {'chapterNo': '13', 'chapterName': 'Exponents and Powers', 'keyTopics': 'Laws of exponents, powers of 10, expressing large numbers, simplification'},
      {'chapterNo': '14', 'chapterName': 'Symmetry', 'keyTopics': 'Line symmetry, symmetrical figures, lines of symmetry, introduction to rotational symmetry'},
      {'chapterNo': '15', 'chapterName': 'Visualising Solid Shapes', 'keyTopics': '3D shapes, faces, edges and vertices, nets, top, front and side views, polyhedrons'},
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
                _TableCell(
                  text: 'Chapter Name',
                  isHeader: true,
                ),
                _TableCell(
                  text: 'Key Topics covered',
                  isHeader: true,
                ),
              ],
            ),
            // Data rows
            ...syllabusData.map((data) => TableRow(
              decoration: BoxDecoration(color: Colors.white),
              children: [
                _TableCell(
                  text: '${data['chapterNo']}. ${data['chapterName']}',
                  isHeader: false,
                ),
                _TableCell(
                  text: data['keyTopics']!,
                  isHeader: false,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell({
    required this.text,
    required this.isHeader,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      alignment: isHeader && text == 'Chapter No.' ? Alignment.center : Alignment.topLeft,
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
          fontSize: isHeader ? 14 : 13,
          color: isHeader ? Colors.teal[900] : Colors.black87,
        ),
        textAlign: isHeader && text == 'Chapter No.' ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget {
  final String title;
  final String date;
  const _SubmissionTile({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.purple[50], child: const Icon(Icons.check_circle_outline, color: Colors.purple)),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}


