import 'package:flutter/material.dart';
import 'package:lms_project/features/auth/login_page.dart';
import 'package:lms_project/features/auth/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms_project/features/home/home_menu_page.dart';

//used for changing pages based on user authentication status
class AuthWrapper extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return const HomeMenuPage();
        }
        return const LoginPage();
      },
    );
  }
}