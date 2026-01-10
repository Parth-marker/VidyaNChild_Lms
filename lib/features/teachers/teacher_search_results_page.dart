import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/features/teachers/teacher_bottom_nav.dart';
import 'package:lms_project/features/teachers/teacher_search_provider.dart';
import 'package:lms_project/features/teachers/teacher_tasks_page.dart';
import 'package:provider/provider.dart';

class TeacherSearchResultsPage extends StatefulWidget {
  const TeacherSearchResultsPage({super.key});

  @override
  State<TeacherSearchResultsPage> createState() => _TeacherSearchResultsPageState();
}

class _TeacherSearchResultsPageState extends State<TeacherSearchResultsPage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final search = context.read<TeacherSearchProvider>();
    controller = TextEditingController(text: search.query);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<TeacherSearchProvider>();

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
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search tasks, assignments, and resources',
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: search.updateQuery,
              ),
              const SizedBox(height: 16),
              Text('Search Results', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: search.results,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No results found. Try searching for assignment titles, draft names, or upload titles.',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    
                    // Separate results by category
                    final assignments = docs.where((d) => d['category'] == 'assignment').toList();
                    final drafts = docs.where((d) => d['category'] == 'draft').toList();
                    final uploads = docs.where((d) => d['category'] == 'upload').toList();
                    
                    return ListView(
                      children: [
                        if (assignments.isNotEmpty) ...[
                          const _SectionHeader(text: 'Assignments'),
                          ...assignments.map((d) => _ResultCard(
                                title: d['title'] as String? ?? 'Assignment',
                                subtitle: 'Status: ${d['status'] as String? ?? 'Unknown'}',
                                category: 'assignment',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const TeacherTasksPage(),
                                    ),
                                  );
                                },
                              )),
                          if (drafts.isNotEmpty || uploads.isNotEmpty) const SizedBox(height: 16),
                        ],
                        if (drafts.isNotEmpty) ...[
                          if (assignments.isEmpty) const SizedBox(height: 0),
                          const _SectionHeader(text: 'Drafts'),
                          ...drafts.map((d) => _ResultCard(
                                title: d['title'] as String? ?? 'Draft',
                                subtitle: '${d['lastEdited'] as String? ?? d['status'] as String? ?? 'Draft'}',
                                category: 'draft',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const TeacherTasksPage(),
                                    ),
                                  );
                                },
                              )),
                          if (uploads.isNotEmpty) const SizedBox(height: 16),
                        ],
                        if (uploads.isNotEmpty) ...[
                          if (assignments.isEmpty && drafts.isEmpty) const SizedBox(height: 0),
                          const _SectionHeader(text: 'Uploads'),
                          ...uploads.map((d) => _ResultCard(
                                title: d['title'] as String? ?? 'Upload',
                                subtitle: d['subtitle'] as String? ?? '',
                                category: 'upload',
                                onTap: () {
                                  // Navigate to relevant page or show details
                                },
                              )),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const TeacherBottomNavBar(currentIndex: 0),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? category;
  final VoidCallback? onTap;
  const _ResultCard({required this.title, required this.subtitle, this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color bgColor;
    
    switch (category) {
      case 'assignment':
        icon = Icons.assignment;
        iconColor = Colors.teal;
        bgColor = Colors.teal[50]!;
        break;
      case 'draft':
        icon = Icons.edit_note;
        iconColor = Colors.orange;
        bgColor = Colors.orange[50]!;
        break;
      case 'upload':
        icon = Icons.upload_file;
        iconColor = Colors.purple;
        bgColor = Colors.purple[50]!;
        break;
      default:
        icon = Icons.description_outlined;
        iconColor = Colors.grey;
        bgColor = Colors.grey[50]!;
    }
    
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
        leading: CircleAvatar(
          backgroundColor: bgColor,
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTextStyles.body.copyWith(fontSize: 13, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap ?? () {},
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

