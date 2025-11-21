import 'package:flutter/material.dart';
import 'package:lms_project/features/home/home_menu_page.dart';
import 'package:lms_project/features/home/student_id_analytics_page.dart';
import 'package:lms_project/features/usage/ai_study_assistant_page.dart';
import 'package:lms_project/features/usage/digitized_assignments_page.dart';
import 'package:lms_project/features/usage/math_puzzles_page.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavBar({super.key, required this.currentIndex});

  void _go(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomeMenuPage();
        break;
      case 1:
        page = const StudentIdAnalyticsPage();
        break;
      case 2:
        page = const AIStudyAssistantPage();
        break;
      case 3:
        page = const DigitizedAssignmentsPage();
        break;
      case 4:
      default:
        page = const MathPuzzlesPage();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: const Color.fromARGB(255, 26, 122, 111),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        unselectedIconTheme: const IconThemeData(color: Colors.white70),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        onTap: (i) => _go(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'AI Tutor'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.extension_outlined), label: 'Puzzles'),
        ],
      ),
    );
  }
}


