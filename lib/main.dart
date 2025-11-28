import 'package:flutter/material.dart';
import 'package:lms_project/features/home/home_menu_page.dart';
import 'package:lms_project/features/teachers/teacher_home_page.dart';

import 'firebase_options.dart';
//git add . then git commit -m "commit message" then git push

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
