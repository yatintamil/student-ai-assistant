import 'package:flutter/material.dart';

/// Answers the app's north-star question:
/// "What is the best thing I should do right now to get closer to my goals?"
class TopRecommendationCard extends StatelessWidget {
  const TopRecommendationCard({
    super.key,
    required this.recommendation,
    this.onAskAi,
  });

  final String recommendation;
  final VoidCallback? onAskAi;

  @override
  Widget build(BuildContext context) {
    if (recommendation.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: colorScheme.onPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'What to do right now',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimary,
                height: 1.4,
              ),
            ),
            if (onAskAi != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAskAi,
                  icon: Icon(Icons.smart_toy_outlined, color: colorScheme.onPrimary),
                  label: Text(
                    'Ask AI why',
                    style: TextStyle(color: colorScheme.onPrimary),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
