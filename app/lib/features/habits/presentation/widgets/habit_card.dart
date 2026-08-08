import 'package:flutter/material.dart';

import '../../domain/entities/habit_entity.dart';
import 'habit_streak_chip.dart';

/// A card that presents a summary of a [HabitEntity].
///
/// [onTap] is called when the card body is tapped (typically opens edit page).
/// [onToggleToday] is called when the completion icon is tapped.
class HabitCard extends StatelessWidget {
  /// Creates a [HabitCard] for [habit].
  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleToday,
  });

  /// The habit to display.
  final HabitEntity habit;

  /// Called when the card body is tapped.
  final VoidCallback? onTap;

  /// Called when the today-completion icon is tapped.
  final VoidCallback? onToggleToday;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isDone = habit.isCompletedToday;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Completion toggle
                  GestureDetector(
                    onTap: onToggleToday,
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      size: 26,
                      color: isDone ? cs.tertiary : cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      habit.title,
                      style: tt.titleSmall?.copyWith(
                        decoration:
                            isDone ? TextDecoration.lineThrough : null,
                        color: isDone
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  HabitStreakChip(streak: habit.currentStreak),
                ],
              ),
              if (habit.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 38),
                  child: Text(
                    habit.description,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 38),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.repeat,
                      size: 13,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _frequencyLabel(habit.frequency),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 13,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Best: ${habit.longestStreak}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _frequencyLabel(HabitFrequency f) => switch (f) {
        HabitFrequency.daily => 'Daily',
        HabitFrequency.weekly => 'Weekly',
      };
}
