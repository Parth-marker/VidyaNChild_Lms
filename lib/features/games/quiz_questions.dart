class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex; // 0-based index
  final String category;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
  });
}

class QuizQuestions {
  static final List<QuizQuestion> allQuestions = [
    // Integers (10 questions)
    QuizQuestion(
      question: 'What is the additive inverse of −9?',
      options: ['A) 9', 'B) −9', 'C) 0', 'D) 18'],
      correctAnswerIndex: 0,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'Which of the following is the smallest integer?',
      options: ['A) −3', 'B) 0', 'C) 5', 'D) −7'],
      correctAnswerIndex: 3,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'What is the value of (−6) + 10?',
      options: ['A) −16', 'B) −4', 'C) 4', 'D) 16'],
      correctAnswerIndex: 2,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'The product of two negative integers is always:',
      options: [
        'A) Negative',
        'B) Positive',
        'C) Zero',
        'D) Cannot be determined',
      ],
      correctAnswerIndex: 1,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'What is the result of (−4) × 7?',
      options: ['A) 28', 'B) −28', 'C) −11', 'D) 11'],
      correctAnswerIndex: 1,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'Which of the following statements is true?',
      options: ['A) −8 > −3', 'B) −5 = 5', 'C) −2 < 0', 'D) 0 < −1'],
      correctAnswerIndex: 2,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'What is the value of (−20) ÷ (−5)?',
      options: ['A) −4', 'B) 4', 'C) −15', 'D) 15'],
      correctAnswerIndex: 1,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'Which integer lies between −6 and −2?',
      options: ['A) −7', 'B) −6', 'C) −4', 'D) −2'],
      correctAnswerIndex: 2,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'What is the value of 15 − (−7)?',
      options: ['A) 8', 'B) −8', 'C) 22', 'D) −22'],
      correctAnswerIndex: 2,
      category: 'Integers',
    ),
    QuizQuestion(
      question: 'Which property is shown by (−3) + 5 = 5 + (−3)?',
      options: [
        'A) Closure',
        'B) Commutative',
        'C) Associative',
        'D) Distributive',
      ],
      correctAnswerIndex: 1,
      category: 'Integers',
    ),

    // Fractions and Decimals (10 questions)
    QuizQuestion(
      question: 'Which of the following is a proper fraction?',
      options: ['A) 7/4', 'B) 5/5', 'C) 3/8', 'D) 9/6'],
      correctAnswerIndex: 2,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'Which fraction is equivalent to 3/4?',
      options: ['A) 6/10', 'B) 9/12', 'C) 12/20', 'D) 15/25'],
      correctAnswerIndex: 1,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'What is the decimal form of 7/10?',
      options: ['A) 0.7', 'B) 0.07', 'C) 7.0', 'D) 0.17'],
      correctAnswerIndex: 0,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'Which of the following is the greatest?',
      options: ['A) 0.45', 'B) 4/10', 'C) 0.405', 'D) 0.5'],
      correctAnswerIndex: 3,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'What is the value of 2/5 + 3/5?',
      options: ['A) 1', 'B) 5/10', 'C) 1/5', 'D) 5/25'],
      correctAnswerIndex: 0,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'Which fraction is equal to 0.25?',
      options: ['A) 1/2', 'B) 1/3', 'C) 1/4', 'D) 3/4'],
      correctAnswerIndex: 2,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'What is the value of 0.6 − 0.2?',
      options: ['A) 0.2', 'B) 0.4', 'C) 0.8', 'D) 0.6'],
      correctAnswerIndex: 1,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'Which of the following is a terminating decimal?',
      options: ['A) 1/3', 'B) 2/9', 'C) 3/8', 'D) 7/11'],
      correctAnswerIndex: 2,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'What is the value of 4/5 × 10?',
      options: ['A) 8', 'B) 2', 'C) 40', 'D) 0.8'],
      correctAnswerIndex: 0,
      category: 'Fractions and Decimals',
    ),
    QuizQuestion(
      question: 'Which of the following is true?',
      options: [
        'A) 0.5 = 1/5',
        'B) 0.25 = 25/100',
        'C) 3/10 = 0.03',
        'D) 0.75 = 1/2',
      ],
      correctAnswerIndex: 1,
      category: 'Fractions and Decimals',
    ),

    // Data Handling (10 questions)
    QuizQuestion(
      question:
          'The number of students present in a class for 5 days is:\n20, 22, 21, 23, 24\nWhat is the mean number of students?',
      options: ['A) 21', 'B) 22', 'C) 23', 'D) 24'],
      correctAnswerIndex: 1,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question: 'Find the mode of the data:\n3, 5, 7, 5, 9, 5, 11',
      options: ['A) 3', 'B) 5', 'C) 7', 'D) 9'],
      correctAnswerIndex: 1,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question: 'What is the median of the following data?\n8, 3, 5, 10, 6',
      options: ['A) 5', 'B) 6', 'C) 8', 'D) 10'],
      correctAnswerIndex: 1,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question: 'The range of the data 4, 9, 2, 7, 6 is:',
      options: ['A) 5', 'B) 6', 'C) 7', 'D) 9'],
      correctAnswerIndex: 2,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question: 'Which of the following graphs is best used to compare data?',
      options: [
        'A) Bar graph',
        'B) Pie chart',
        'C) Pictograph',
        'D) Histogram',
      ],
      correctAnswerIndex: 0,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question:
          'If the number of chocolates sold on Monday is shown by 🍫🍫🍫🍫 and each 🍫 represents 5 chocolates, how many chocolates were sold?',
      options: ['A) 10', 'B) 15', 'C) 20', 'D) 25'],
      correctAnswerIndex: 2,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question: 'The mean of 5 numbers is 12. What is their total sum?',
      options: ['A) 60', 'B) 17', 'C) 12', 'D) 5'],
      correctAnswerIndex: 0,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question:
          'Which measure of central tendency represents the middle value of the data?',
      options: ['A) Mean', 'B) Mode', 'C) Median', 'D) Range'],
      correctAnswerIndex: 2,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question:
          'If the highest value in a data set is 50 and the lowest is 20, the range is:',
      options: ['A) 20', 'B) 25', 'C) 30', 'D) 70'],
      correctAnswerIndex: 2,
      category: 'Data Handling',
    ),
    QuizQuestion(
      question:
          'How many times does the number 6 occur in the data:\n2, 6, 4, 6, 8, 6, 9',
      options: ['A) 2', 'B) 3', 'C) 4', 'D) 6'],
      correctAnswerIndex: 1,
      category: 'Data Handling',
    ),
  ];

  static List<QuizQuestion> getRandomQuestions(int count) {
    final shuffled = List<QuizQuestion>.from(allQuestions)..shuffle();
    return shuffled.take(count).toList();
  }

  static List<QuizQuestion> getByChapter(String chapter) {
    return allQuestions.where((q) => q.category == chapter).toList();
  }

  static List<String> getCategories() {
    return allQuestions.map((q) => q.category).toSet().toList();
  }
}
