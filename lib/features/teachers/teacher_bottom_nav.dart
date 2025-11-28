import 'package:flutter/material.dart';
import 'package:lms_project/features/teachers/teacher_home_page.dart';
import 'package:lms_project/features/teachers/teacher_ai_help_page.dart';
import 'package:lms_project/features/teachers/teacher_tasks_page.dart';
import 'package:lms_project/features/teachers/teacher_analytics_page.dart';

class TeacherBottomNavBar extends StatelessWidget {
  const TeacherBottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  void _go(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const TeacherHomePage();
        break;
      case 1:
        page = const TeacherAiHelpPage();
        break;
      case 2:
        page = const TeacherTasksPage();
        break;
      case 3:
      default:
        page = const TeacherAnalyticsPage();
        break;
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'AI Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

