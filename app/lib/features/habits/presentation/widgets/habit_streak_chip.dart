import 'package:flutter/material.dart';

/// A compact chip that displays a habit's current streak count.
class HabitStreakChip extends StatelessWidget {
  /// Creates a [HabitStreakChip] for [streak] days.
  const HabitStreakChip({super.key, required this.streak});

  /// The number of consecutive days the habit has been completed.
  final int streak;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (bg, fg) = streak > 0
        ? (cs.tertiaryContainer, cs.onTertiaryContainer)
        : (cs.surfaceContainerHighest, cs.onSurfaceVariant);

    return Chip(
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      avatar: Icon(Icons.local_fire_department, size: 14, color: fg),
      label: Text('$streak day${streak == 1 ? '' : 's'}'),
      labelStyle: tt.labelSmall?.copyWith(
        color: fg,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: bg,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
