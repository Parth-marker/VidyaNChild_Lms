import 'package:flutter/material.dart';
import 'package:lms_project/features/home/home_menu_page.dart';
import 'package:lms_project/features/teachers/teacher_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const bool _showTeacherExperience = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _showTeacherExperience
          ? const TeacherHomePage()
          : const HomeMenuPage(),
    );
  }
}

