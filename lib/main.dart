import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lms_project/features/auth/login_page.dart';
import 'package:lms_project/features/auth/signup_page.dart';

import 'package:lms_project/features/home/home_menu_page.dart';
import 'package:lms_project/features/home/student_id_analytics_page.dart';
import 'package:lms_project/features/home/search_results_page.dart';

import 'package:lms_project/features/usage/ai_study_assistant_page.dart';
import 'package:lms_project/features/usage/ai_study_plan_page.dart';
import 'package:lms_project/features/usage/digitized_assignments_page.dart';
import 'package:lms_project/features/usage/math_puzzles_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeMenuPage(),
    );
  }
}

