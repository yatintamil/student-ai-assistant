import 'package:flutter/material.dart';

import '../../../habits/domain/entities/habit_entity.dart';
import '../../../habits/presentation/pages/edit_habit_page.dart';
import '../../../habits/presentation/pages/habit_list_page.dart';
import '../../../habits/presentation/widgets/habit_empty_state.dart';
import '../../../habits/presentation/widgets/habit_streak_chip.dart';

/// Displays today's habits sourced from real [HabitEntity] objects.
///
/// Each row shows a completion-toggle icon, the habit title, and its current
/// streak. Tapping a row navigates to [EditHabitPage]. [onToggle] is called
/// with the [HabitEntity] when the user taps the toggle icon. The "See all"
/// button navigates to [HabitListPage].
class HabitsCard extends StatelessWidget {
  /// Creates a [HabitsCard].
  const HabitsCard({
    super.key,
    required this.habits,
    required this.onToggle,
  });

  /// The habits to render. May be empty — [HabitEmptyState] is shown then.
  final List<HabitEntity> habits;

  /// Called with the [HabitEntity] whose today-completion was toggled.
  final void Function(HabitEntity habit) onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.loop_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Today's Habits",
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToHabitList(context),
                  child: const Text('See all'),
                ),
              ],
            ),

            // ── Habit rows or empty state ────────────────────────────────
            if (habits.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: HabitEmptyState(),
              )
            else
              ...habits.map(
                (habit) => _HabitRow(
                  habit: habit,
                  onToggle: () => onToggle(habit),
                  onTap: () => _navigateToEdit(context, habit),
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToHabitList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HabitListPage()),
    );
  }

  void _navigateToEdit(BuildContext context, HabitEntity habit) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EditHabitPage(habit: habit)),
    );
  }
}

// ---------------------------------------------------------------------------
// Private row widget
// ---------------------------------------------------------------------------

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.habit,
    required this.onToggle,
    required this.onTap,
    required this.textTheme,
    required this.colorScheme,
  });

  final HabitEntity habit;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDone = habit.isCompletedToday;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            // Toggle — separate gesture so it doesn't trigger onTap
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 22,
                color: isDone ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                habit.title,
                style: textTheme.bodyMedium?.copyWith(
                  color: isDone
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            HabitStreakChip(streak: habit.currentStreak),
          ],
        ),
      ),
    );
  }
}
