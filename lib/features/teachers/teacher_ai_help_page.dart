import 'package:flutter/material.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/features/student_services/widgets/ai_assistant_view.dart';

class TeacherAiHelpPage extends StatelessWidget {
  const TeacherAiHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AiAssistantView(
      title: 'AI Help',
      welcomeMessage:
          "Hi! I'm your planning assistant. Ask for lesson hooks, rubric ideas, or quick explanations.",
      hintText: 'Ask for prep help, grading tips, or class summaries...',
      connectingLabel: 'Connecting to AI coach...',
      typingLabel: 'AI Help is drafting...',
      bottomNavigation: const TeacherBottomNavBar(currentIndex: 1),
    );
  }
}

