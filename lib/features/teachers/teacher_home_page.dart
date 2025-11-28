import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text('Welcome back, Ms. Rao!', style: AppTextStyles.h1Teal),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TeacherSearchBar(),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Recent Uploads',
                children: const [
                  _TeacherUploadTile(
                    icon: Icons.description_outlined,
                    title: 'Grade 7 • Algebra Quiz',
                    subtitle: 'Uploaded 10 mins ago',
                  ),
                  _TeacherUploadTile(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'Geometry Slides',
                    subtitle: 'Uploaded yesterday',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Recent Submission %',
                children: const [
                  _SubmissionStatTile(
                    title: 'Fractions Practice',
                    detail: '28 of 32 students',
                    percent: 0.87,
                  ),
                  _SubmissionStatTile(
                    title: 'Geometry Lab',
                    detail: '24 of 32 students',
                    percent: 0.75,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Today\'s Timetable',
                children: const [
                  _ClassRow(time: '08:00', topic: 'Warm Up & Check-ins'),
                  _ClassRow(time: '08:40', topic: 'Algebra: Word Problems'),
                  _ClassRow(time: '09:20', topic: 'Group Project Feedback'),
                  _ClassRow(time: '10:00', topic: 'Quiz Review'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 0),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _TeacherSearchBar extends StatelessWidget {
  const _TeacherSearchBar();

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText: 'Search class resources, assignments, etc.',
        hintStyle:
            AppTextStyles.body.copyWith(color: Colors.black45, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    );
  }
}

class _TeacherUploadTile extends StatelessWidget {
  const _TeacherUploadTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.teal[50],
        child: Icon(icon, color: Colors.teal),
      ),
      title: Text(
        title,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54),
      ),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[300],
          minimumSize: const Size(80, 38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Review', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
      ),
    );
  }
}

class _SubmissionStatTile extends StatelessWidget {
  const _SubmissionStatTile({
    required this.title,
    required this.detail,
    required this.percent,
  });

  final String title;
  final String detail;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text('${(percent * 100).round()}%', style: AppTextStyles.body.copyWith(color: Colors.teal[700])),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            borderRadius: BorderRadius.circular(12),
            color: Colors.teal[400],
            backgroundColor: Colors.teal[50],
          ),
          const SizedBox(height: 4),
          Text(detail, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.time, required this.topic});

  final String time;
  final String topic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(time, style: AppTextStyles.body.copyWith(color: Colors.teal[800])),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}

