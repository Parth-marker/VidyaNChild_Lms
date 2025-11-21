import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/home/search_results_page.dart';

class HomeMenuPage extends StatelessWidget {
  const HomeMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Welcome back, Parth!', style: AppTextStyles.h1Teal),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchBar(onSearchTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchResultsPage()),
                );
              }),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Today\'s Events',
                children: const [
                  _EventTile(icon: Icons.description_outlined, title: 'Math Worksheet', subtitle: 'Due today'),
                  _EventTile(icon: Icons.picture_as_pdf_outlined, title: 'Lesson Notes', subtitle: 'Due today'),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Where you left off',
                children: const [
                  _ProgressPreview(title: 'Fractions & Decimals', subtitle: 'Math • Page 36 of 90'),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Today\'s Timetable:',
                children: const [
                  _ClassRow(time: '08:00', topic: 'Algebra: Linear Equations'),
                  _ClassRow(time: '08:40', topic: 'Fractions & Decimals'),
                  _ClassRow(time: '09:20', topic: 'Geometry: Triangles'),
                  _ClassRow(time: '10:00', topic: 'Number Patterns'),
                  _ClassRow(time: '10:40', topic: 'Quick Practice & Recap'),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

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

class _SearchBar extends StatelessWidget {
  final VoidCallback onSearchTap;
  const _SearchBar({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onSearchTap,
      decoration: InputDecoration(
        hintText: 'Search for math lesson materials',
        hintStyle: AppTextStyles.body.copyWith(color: Colors.black45, fontSize: 14),
        prefixIcon: IconButton(
          icon: const Icon(Icons.search, color: Colors.teal),
          onPressed: onSearchTap,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EventTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: Colors.teal[50], child: Icon(icon, color: Colors.teal)),
      title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
      trailing: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[300], minimumSize: const Size(80, 38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text('Open', style: AppTextStyles.buttonPrimary.copyWith(fontSize: 14)),
      ),
    );
  }
}

class _ProgressPreview extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ProgressPreview({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(color: Colors.teal[100], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.menu_book_rounded, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
            ]),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.play_circle_outline, color: Colors.purple)),
        ],
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  final String time;
  final String topic;
  const _ClassRow({required this.time, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(10)),
            child: Text(time, style: AppTextStyles.body.copyWith(color: Colors.teal[800])),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(topic, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}


