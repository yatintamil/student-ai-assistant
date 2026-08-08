import 'package:flutter/material.dart';

/// A labelled linear progress bar showing how many of today's habits have
/// been completed.
///
/// [completed] and [total] are used to compute the fraction. When [total]
/// is zero the bar renders at 0 %.
class HabitProgressIndicator extends StatelessWidget {
  /// Creates a [HabitProgressIndicator].
  const HabitProgressIndicator({
    super.key,
    required this.completed,
    required this.total,
  });

  /// Number of habits completed today.
  final int completed;

  /// Total number of habits for today.
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fraction = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final percent = (fraction * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Today: $completed / $total',
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            Text(
              '$percent%',
              style: tt.labelMedium?.copyWith(
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: cs.surfaceContainerHighest,
            color: cs.tertiary,
          ),
        ),
      ],
    );
  }
}
