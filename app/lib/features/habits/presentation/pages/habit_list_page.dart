import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/entities/habit_entity.dart';
import '../providers/habit_providers.dart';
import '../states/habit_state.dart';
import '../widgets/habit_empty_state.dart';
import '../widgets/habit_progress_indicator.dart';
import '../widgets/habit_tile.dart';
import 'add_habit_page.dart';
import 'edit_habit_page.dart';

/// Displays the authenticated user's habit list.
///
/// - FAB navigates to [AddHabitPage].
/// - Tapping a tile navigates to [EditHabitPage].
/// - Tapping the leading icon toggles today's completion.
/// - Swiping a tile left reveals a delete action.
class HabitListPage extends ConsumerStatefulWidget {
  /// Creates the habit list page.
  const HabitListPage({super.key});

  @override
  ConsumerState<HabitListPage> createState() => _HabitListPageState();
}

class _HabitListPageState extends ConsumerState<HabitListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHabits());
  }

  String? get _uid => ref.read(authControllerProvider).user?.id;

  void _loadHabits() {
    final uid = _uid;
    if (uid == null) return;
    ref.read(habitControllerProvider.notifier).loadHabits(uid);
  }

  Future<void> _deleteHabit(HabitEntity habit) async {
    final uid = _uid;
    if (uid == null) return;
    await ref
        .read(habitControllerProvider.notifier)
        .deleteHabit(uid, habit.id);
  }

  Future<void> _toggleToday(HabitEntity habit) async {
    final uid = _uid;
    if (uid == null) return;
    await ref
        .read(habitControllerProvider.notifier)
        .toggleCompletedToday(uid, habit);
  }

  void _navigateToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddHabitPage()),
    );
  }

  void _navigateToEdit(HabitEntity habit) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditHabitPage(habit: habit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: <Widget>[
          if (habitState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(habitState, colorScheme),
      floatingActionButton: FloatingActionButton(
        heroTag: 'habitListFab',
        onPressed: _navigateToAdd,
        tooltip: 'Add habit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(HabitState habitState, ColorScheme colorScheme) {
    if (habitState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                habitState.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadHabits,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final habits = habitState.habits;

    if (!habitState.isLoading && habits.isEmpty) {
      return const HabitEmptyState();
    }

    final completedToday = habits.where((h) => h.isCompletedToday).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 16.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: <Widget>[
                // Progress bar header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: HabitProgressIndicator(
                    completed: completedToday,
                    total: habits.length,
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: 96,
                    ),
                    itemCount: habits.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return Dismissible(
                        key: ValueKey(habit.id),
                        direction: DismissDirection.endToStart,
                        background: _buildDismissBackground(colorScheme),
                        confirmDismiss: (_) => _confirmDelete(context),
                        onDismissed: (_) => _deleteHabit(habit),
                        child: HabitTile(
                          habit: habit,
                          onToggleToday: () => _toggleToday(habit),
                          onTap: () => _navigateToEdit(habit),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground(ColorScheme colorScheme) {
    return ColoredBox(
      color: colorScheme.errorContainer,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete_outline,
            color: colorScheme.onErrorContainer,
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit'),
        content: const Text('This habit and its history will be permanently deleted.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
