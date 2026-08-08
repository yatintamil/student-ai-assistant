import 'package:flutter/material.dart';

/// Displays a linear progress indicator showing how many of today's tasks
/// have been completed.
///
/// [progress] is a value in the range [0.0, 1.0].
class TodayProgressCard extends StatelessWidget {
  /// Creates a [TodayProgressCard].
  const TodayProgressCard({super.key, required this.progress});

  /// Fraction of tasks completed today, clamped to [0.0, 1.0].
  final double progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final clamped = progress.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Today\'s Progress',
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percent%',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _progressLabel(percent),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a contextual message based on [percent] completion.
  String _progressLabel(int percent) {
    if (percent == 0) return 'Nothing completed yet — you\'ve got this!';
    if (percent < 50) return 'Great start — keep the momentum going.';
    if (percent < 100) return 'More than halfway there — finish strong!';
    return 'All done for today. Outstanding work!';
  }
}
