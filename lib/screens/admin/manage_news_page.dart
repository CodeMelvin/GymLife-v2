import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/news_item.dart';
import '../../services/database_service.dart';
import '../../widgets/responsive_center.dart';

class ManageNewsPage extends StatefulWidget {
  const ManageNewsPage({super.key});

  @override
  State<ManageNewsPage> createState() => _ManageNewsPageState();
}

class _ManageNewsPageState extends State<ManageNewsPage> {
  String _category = newsCategories.first;

  Future<void> _openForm({NewsItem? item}) async {
    final isEdit = item != null;
    final titleCtrl = TextEditingController(text: item?.title ?? '');
    final contentCtrl = TextEditingController(text: item?.content ?? '');
    final currentCategory = item?.category;
    _category =
        (currentCategory != null && newsCategories.contains(currentCategory))
        ? currentCategory
        : newsCategories.first;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isEdit ? 'EDIT NEWS' : 'POST NEW NEWS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Category',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButton<String>(
                    value: _category,
                    dropdownColor: appBarColor,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white),
                    items: [
                      for (final c in newsCategories)
                        DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (v) => setSheetState(
                      () => _category = v ?? newsCategories.first,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildInput(titleCtrl, 'News Title', Icons.title),
                const SizedBox(height: 15),
                _buildInput(
                  contentCtrl,
                  'Content',
                  Icons.description,
                  maxLines: 4,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentRed,
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final content = contentCtrl.text.trim();
                      if (title.isEmpty || content.isEmpty) return;
                      if (isEdit) {
                        await DatabaseService.updateNews(
                          newsId: item.id,
                          title: title,
                          content: content,
                          category: _category,
                        );
                      } else {
                        await DatabaseService.addNews(
                          title: title,
                          content: content,
                          category: _category,
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      isEdit ? 'SAVE CHANGES' : 'PUBLISH',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
    titleCtrl.dispose();
    contentCtrl.dispose();
  }

  Future<void> _delete(NewsItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appBarColor,
        title: const Text('Delete News', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${item.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.deleteNews(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text('MANAGE NEWS')),
      body: StreamBuilder<DatabaseEvent>(
        stream: DatabaseService.newsStream(),
        builder: (context, snap) {
          if (!snap.hasData || snap.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                'No news yet.',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }
          final raw = Map<dynamic, dynamic>.from(
            snap.data!.snapshot.value as Map,
          );
          final items =
              raw.entries
                  .map(
                    (e) => NewsItem.fromRTDB(
                      e.key.toString(),
                      Map<dynamic, dynamic>.from(e.value as Map),
                    ),
                  )
                  .toList()
                ..sort((a, b) => b.date.compareTo(a.date));

          return ResponsiveCenter(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [for (final item in items) _buildNewsCard(item)],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: accentRed,
        icon: const Icon(Icons.add),
        label: const Text('New News'),
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.category,
                style: const TextStyle(
                  color: accentRed,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Text(
              DateFormat('dd MMM yyyy').format(item.date),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: appBarColor,
          onSelected: (value) {
            if (value == 'edit') {
              _openForm(item: item);
            } else if (value == 'delete') {
              _delete(item);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit', style: TextStyle(color: Colors.white)),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: accentRed, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
