import 'package:flutter/material.dart';

import '../../domain/entities/task_entity.dart';

/// A compact chip that displays a [TaskStatus] label with a semantic colour.
class StatusChip extends StatelessWidget {
  /// Creates a [StatusChip] for the given [status].
  const StatusChip({super.key, required this.status});

  /// The status to display.
  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, background, onColor) = switch (status) {
      TaskStatus.pending => (
          'Pending',
          cs.secondaryContainer,
          cs.onSecondaryContainer,
        ),
      TaskStatus.completed => (
          'Completed',
          cs.primaryContainer,
          cs.onPrimaryContainer,
        ),
    };

    return Chip(
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: onColor,
            fontWeight: FontWeight.w600,
          ),
      backgroundColor: background,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
