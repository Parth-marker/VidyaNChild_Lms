import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lms_project/features/auth/auth_provider/auth_provider.dart';
import 'package:lms_project/features/auth/auth_provider/auth_wrapper.dart';
import 'package:lms_project/features/student_home/home_provider.dart';
import 'package:lms_project/features/student_home/search_provider.dart';
import 'package:lms_project/features/teachers/teacher_provider.dart';
import 'package:lms_project/features/student_services/gemini_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => GeminiProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

//obscure text (toggle), provider updates, acct type, sign out f + button, content,