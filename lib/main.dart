import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lms_project/features/auth/provider/auth_provider.dart';
import 'package:lms_project/features/home/home_menu_page.dart';
import 'package:lms_project/features/teachers/teacher_home_page.dart';

//providers for auth
import 'package:provider/provider.dart';
import 'package:lms_project/features/auth/provider/auth_provider.dart';
import 'package:lms_project/features/auth/provider/auth_wrapper.dart';

import 'firebase_options.dart';
//git add . then git commit -m "commit message" then git push

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await dotenv.load(fileName: ".env");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AuthProvider(),),
    ],
    child: const MyApp(),
  ),);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const bool showTeacherExperience = true;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child:MaterialApp(
        //home: _showTeacherExperience
        //  ? const TeacherHomePage()
        //  : const HomeMenuPage(),
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}
