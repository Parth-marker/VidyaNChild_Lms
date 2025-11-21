import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Search', style: AppTextStyles.h1Teal),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Math',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Top Results', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: const [
                    _ResultCard(title: 'Algebra Basics', subtitle: 'Course'),
                    _ResultCard(title: 'Fractions Drill - Week 5', subtitle: 'Worksheet'),
                    _ResultCard(title: 'Chapter 3 Quiz - Decimals', subtitle: 'Quiz'),
                    SizedBox(height: 16),
                    _SectionHeader(text: 'All Results'),
                    _ResultCard(title: 'Geometry: Angles Practice', subtitle: 'Worksheet'),
                    _ResultCard(title: 'Number Patterns - Challenge', subtitle: 'Activity'),
                    _ResultCard(title: 'Algebra Review Set', subtitle: 'Worksheet'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ResultCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.purple[50], child: const Icon(Icons.bookmark_outline, color: Colors.purple)),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
      );
}


