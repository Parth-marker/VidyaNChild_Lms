import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/student_services/widgets/ai_assistant_view.dart';

class AIStudyAssistantPage extends StatelessWidget {
  const AIStudyAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AiAssistantView(
      title: 'AI Tutor',
      welcomeMessage:
          "Ask me anything! I'm an AI tutor trained to help with your studies.",
      bottomNavigation: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
