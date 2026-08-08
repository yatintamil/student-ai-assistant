import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/journal_entity.dart';
import '../providers/journal_providers.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntries();
    });
  }

  void _loadEntries() {
    final uid = ref.read(authControllerProvider).user?.id;
    if (uid != null) {
      ref.read(journalControllerProvider.notifier).loadJournalEntries(uid);
    }
  }

  void _showNewReflectionDialog() {
    MoodLevel selectedMood = MoodLevel.good;
    double energyValue = 7.0;
    final reflectionController = TextEditingController();
    final winController = TextEditingController();
    final lessonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Daily Reflection & Mood Log'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How are you feeling today?', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<MoodLevel>(
                      initialValue: selectedMood,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: MoodLevel.values.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(m.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedMood = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Current Energy Level: ${energyValue.toInt()}/10'),
                    Slider(
                      value: energyValue,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: energyValue.toInt().toString(),
                      onChanged: (val) => setDialogState(() => energyValue = val),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: winController,
                      decoration: const InputDecoration(
                        labelText: 'Win of the Day (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lessonController,
                      decoration: const InputDecoration(
                        labelText: 'Lesson Learned (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reflectionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Reflection Notes',
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
                    if (uid == null) return;

                    final entry = JournalEntity(
                      id: const Uuid().v4(),
                      date: DateTime.now(),
                      mood: selectedMood,
                      energyLevel: energyValue.toInt(),
                      wins: winController.text.trim().isNotEmpty ? [winController.text.trim()] : [],
                      lessonsLearned: lessonController.text.trim().isNotEmpty ? [lessonController.text.trim()] : [],
                      reflectionText: reflectionController.text.trim(),
                      createdAt: DateTime.now(),
                    );

                    await ref.read(journalControllerProvider.notifier).saveJournalEntry(uid, entry);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Save Entry'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal & Daily Reflections'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'journalFab',
        onPressed: _showNewReflectionDialog,
        icon: const Icon(Icons.edit_note),
        label: const Text('Log Today'),
      ),
      body: journalState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : journalState.entries.isEmpty
              ? _buildEmptyState(theme)
              : _buildEntryList(journalState.entries, theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No Reflections Logged Yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your energy, mood, wins, and reflections daily. Your AI Chief of Staff uses this data to optimize future schedules and recommendations.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showNewReflectionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Log First Reflection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryList(List<JournalEntity> entries, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
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
                    Text(
                      '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      avatar: Icon(_getMoodIcon(entry.mood), size: 16),
                      label: Text('Energy: ${entry.energyLevel}/10'),
                    ),
                  ],
                ),
                if (entry.reflectionText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(entry.reflectionText, style: theme.textTheme.bodyMedium),
                ],
                if (entry.wins.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('🏆 Win: ${entry.wins.join(", ")}', style: theme.textTheme.bodySmall),
                ],
                if (entry.lessonsLearned.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('💡 Lesson: ${entry.lessonsLearned.join(", ")}', style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getMoodIcon(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.great:
        return Icons.sentiment_very_satisfied;
      case MoodLevel.good:
        return Icons.sentiment_satisfied;
      case MoodLevel.okay:
        return Icons.sentiment_neutral;
      case MoodLevel.low:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.bad:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}
