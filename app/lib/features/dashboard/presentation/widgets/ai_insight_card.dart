import 'package:flutter/material.dart';

/// Displays an AI-generated insight for the day inside a visually distinct
/// [Card].
///
/// The [insight] text is provided by the caller. The card uses
/// [ColorScheme.primaryContainer] as a subtle tinted surface to differentiate
/// AI content from regular data cards — without introducing hardcoded colours.
class AiInsightCard extends StatelessWidget {
  /// Creates an [AiInsightCard].
  const AiInsightCard({super.key, required this.insight});

  /// The AI-generated insight text to display.
  final String insight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Don't render the card if there's no insight
    if (insight.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.auto_awesome_outlined,
                  size: 18,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insight',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
