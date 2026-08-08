import 'package:flutter/material.dart';

import '../../domain/entities/habit_entity.dart';
import 'habit_streak_chip.dart';

/// A list tile that represents a single [HabitEntity].
///
/// Provides a completion-toggle icon for today, a chevron for navigation, and
/// exposes [onTap] to open the edit page. Swipe-to-dismiss is handled by the
/// parent list.
class HabitTile extends StatelessWidget {
  /// Creates a [HabitTile] for [habit].
  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggleToday,
    this.onTap,
  });

  /// The habit to display.
  final HabitEntity habit;

  /// Called when the completion icon is tapped.
  final VoidCallback onToggleToday;

  /// Called when the tile body is tapped (typically opens edit page).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isDone = habit.isCompletedToday;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: GestureDetector(
        onTap: onToggleToday,
        child: Icon(
          isDone
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked,
          size: 26,
          color: isDone ? cs.tertiary : cs.onSurfaceVariant,
        ),
      ),
      title: Text(
        habit.title,
        style: tt.bodyLarge?.copyWith(
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isDone ? cs.onSurfaceVariant : cs.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: <Widget>[
          Icon(Icons.repeat, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(
            _frequencyLabel(habit.frequency),
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          HabitStreakChip(streak: habit.currentStreak),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
    );
  }

  String _frequencyLabel(HabitFrequency f) => switch (f) {
        HabitFrequency.daily => 'Daily',
        HabitFrequency.weekly => 'Weekly',
      };
}
