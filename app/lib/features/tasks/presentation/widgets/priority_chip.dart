import 'package:flutter/material.dart';

import '../../domain/entities/task_entity.dart';

/// A compact chip that displays a [TaskPriority] label with a semantic colour.
class PriorityChip extends StatelessWidget {
  /// Creates a [PriorityChip] for the given [priority].
  const PriorityChip({super.key, required this.priority});

  /// The priority level to display.
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve(context);
    return Chip(
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      label: Text(label),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color.onColor,
            fontWeight: FontWeight.w600,
          ),
      backgroundColor: color.background,
      side: BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  (String, _ChipColor) _resolve(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (priority) {
      TaskPriority.low => (
          'Low',
          _ChipColor(
            background: cs.surfaceContainerHighest,
            onColor: cs.onSurfaceVariant,
          ),
        ),
      TaskPriority.medium => (
          'Medium',
          _ChipColor(
            background: cs.tertiaryContainer,
            onColor: cs.onTertiaryContainer,
          ),
        ),
      TaskPriority.high => (
          'High',
          _ChipColor(
            background: cs.errorContainer,
            onColor: cs.onErrorContainer,
          ),
        ),
    };
  }
}

class _ChipColor {
  const _ChipColor({required this.background, required this.onColor});
  final Color background;
  final Color onColor;
}
