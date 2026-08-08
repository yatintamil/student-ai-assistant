import 'package:flutter/material.dart';

/// Displayed on [TodayPlanPage] when no plan has been generated yet.
class EmptyPlanWidget extends StatelessWidget {
  /// Creates an [EmptyPlanWidget].
  const EmptyPlanWidget({super.key, required this.onGenerate});

  /// Called when the user taps the generate button.
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.calendar_today_outlined,
              size: 72,
              color: cs.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'No plan for today',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a schedule from your tasks and habits.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Generate Today\'s Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
