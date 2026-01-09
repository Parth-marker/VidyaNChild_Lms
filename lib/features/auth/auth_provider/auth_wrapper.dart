import 'package:flutter/material.dart';
import 'package:lms_project/features/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:lms_project/features/student_home/home_menu_page.dart';
import 'package:lms_project/features/teachers/teacher_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:lms_project/features/auth/auth_provider/auth_provider.dart';

//used for changing pages based on user authentication status
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    // Use Consumer to ensure proper rebuilds when auth state changes
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return StreamBuilder<User?>(
          stream: authProvider.authStateChanges,
          builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          // Use StreamBuilder to listen to Firestore changes for account type
          return StreamBuilder<DocumentSnapshot>(
            key: ValueKey('account_type_${user.uid}'),
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, accountTypeSnapshot) {
              // Show loading while waiting for initial data
              if (accountTypeSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (accountTypeSnapshot.hasError) {
                print('Error getting account type: ${accountTypeSnapshot.error}');
                return const HomeMenuPage(); // Default to student on error
              }
              
              // Firestore streams always emit, even if document doesn't exist
              if (!accountTypeSnapshot.hasData) {
                // This shouldn't happen, but handle it gracefully
                print('No snapshot data available, defaulting to student');
                return const HomeMenuPage();
              }
              
              final doc = accountTypeSnapshot.data!;
              String? accountType;
              
              if (doc.exists) {
                final data = doc.data() as Map<String, dynamic>?;
                accountType = data?['accountType'] as String?;
                print('Account type found: $accountType for user ${user.uid}');
              } else {
                // Document doesn't exist - default to student
                print('User document does not exist for ${user.uid}, defaulting to student');
                return const HomeMenuPage();
              }
              
              // Route based on account type
              print('Routing user ${user.uid} to ${accountType == 'teacher' ? 'teacher' : 'student'} home');
              if (accountType == 'teacher') {
                return const TeacherHomePage();
              } else {
                return const HomeMenuPage();
              }
            },
          );
        }
        return const LoginPage();
          },
        );
      },
    );
  }
}