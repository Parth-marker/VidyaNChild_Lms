import 'package:flutter/material.dart';
import 'package:lms_project/theme/app_text_styles.dart';
import 'package:lms_project/theme/app_bottom_nav.dart';
import 'package:lms_project/features/home/search_provider.dart';
import 'package:provider/provider.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    final search = context.read<SearchProvider>();
    controller = TextEditingController(text: search.query);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<SearchProvider>();

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
                  hintText: 'Search topics or resources',
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
              Text('Top Results', style: AppTextStyles.h1Purple.copyWith(fontSize: 18)),
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
                          'No results yet. Try searching for "fractions" or "algebra".',
                          style: AppTextStyles.body,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView(
                      children: [
                        ...docs.take(3).map((d) => _ResultCard(
                              title: d['title'] as String? ?? 'Resource',
                              subtitle: d['type'] as String? ?? '',
                            )),
                        const SizedBox(height: 16),
                        const _SectionHeader(text: 'All Results'),
                        ...docs.skip(3).map((d) => _ResultCard(
                              title: d['title'] as String? ?? 'Resource',
                              subtitle: d['type'] as String? ?? '',
                            )),
                      ],
                    );
                  },
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
