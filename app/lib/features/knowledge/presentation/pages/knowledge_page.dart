import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/knowledge_entity.dart';
import '../providers/knowledge_providers.dart';

class KnowledgePage extends ConsumerStatefulWidget {
  const KnowledgePage({super.key});

  @override
  ConsumerState<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends ConsumerState<KnowledgePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotes();
    });
  }

  void _loadNotes() {
    final uid = ref.read(authControllerProvider).user?.id;
    if (uid != null) {
      ref.read(knowledgeControllerProvider.notifier).loadNotes(uid);
    }
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Knowledge / Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated e.g. Strategy, Ideas)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Document Content',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final uid = ref.read(authControllerProvider).user?.id;
                if (uid == null || titleController.text.trim().isEmpty) return;

                final tags = tagController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                final note = KnowledgeEntity(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  tags: tags,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await ref.read(knowledgeControllerProvider.notifier).saveNote(uid, note);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save Note'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(knowledgeControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Knowledge & Notes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'knowledgeFab',
        onPressed: _showAddNoteDialog,
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Add Note'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notes.isEmpty
              ? _buildEmptyState(theme)
              : _buildNoteList(state.notes, theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No Knowledge Notes Stored',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Store personal notes, strategic ideas, project plans, and knowledge here for quick access and AI Assistant retrieval.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddNoteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create First Note'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteList(List<KnowledgeEntity> notes, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () async {
                        final uid = ref.read(authControllerProvider).user?.id;
                        if (uid != null) {
                          await ref.read(knowledgeControllerProvider.notifier).deleteNote(uid, note.id);
                        }
                      },
                    ),
                  ],
                ),
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(note.content, maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: note.tags.map((t) => Chip(label: Text('#$t', style: const TextStyle(fontSize: 10)))).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
