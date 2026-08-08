import 'package:flutter/material.dart';

/// Displayed in [HabitListPage] when the habit list is empty.
class HabitEmptyState extends StatelessWidget {
  /// Creates a [HabitEmptyState].
  const HabitEmptyState({super.key});

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
              Icons.loop_rounded,
              size: 72,
              color: cs.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to build your first habit.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
