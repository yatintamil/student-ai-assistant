import 'package:flutter/material.dart';

import '../../domain/entities/planner_session_entity.dart';

/// A vertical timeline dot and connector drawn to the left of each
/// [SessionTile] in the plan list.
///
/// [isFirst] and [isLast] control whether the top / bottom connector lines
/// are drawn. [session] drives the colour of the dot.
class TimelineIndicator extends StatelessWidget {
  /// Creates a [TimelineIndicator].
  const TimelineIndicator({
    super.key,
    required this.session,
    required this.isFirst,
    required this.isLast,
  });

  /// The session this indicator represents.
  final PlannerSessionEntity session;

  /// Whether this is the first item in the list (hides the top line).
  final bool isFirst;

  /// Whether this is the last item in the list (hides the bottom line).
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dotColor = _dotColor(cs);
    final lineColor = cs.outlineVariant;
    const lineWidth = 2.0;
    const dotRadius = 7.0;

    return SizedBox(
      width: 24,
      child: Column(
        children: <Widget>[
          // Top connector
          Expanded(
            child: isFirst
                ? const SizedBox.shrink()
                : Center(
                    child: Container(
                      width: lineWidth,
                      color: lineColor,
                    ),
                  ),
          ),
          // Dot
          Container(
            width: dotRadius * 2,
            height: dotRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
              border: Border.all(
                color: cs.surface,
                width: 2,
              ),
            ),
          ),
          // Bottom connector
          Expanded(
            child: isLast
                ? const SizedBox.shrink()
                : Center(
                    child: Container(
                      width: lineWidth,
                      color: lineColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _dotColor(ColorScheme cs) {
    if (session.completed) return cs.primary;
    if (session.isActive) return cs.tertiary;
    if (session.isPast) return cs.outlineVariant;
    return _typeColor(cs);
  }

  Color _typeColor(ColorScheme cs) => switch (session.type) {
        SessionType.study => cs.primaryContainer,
        SessionType.habit => cs.tertiaryContainer,
        SessionType.breakTime => cs.secondaryContainer,
        SessionType.meal => cs.secondaryContainer,
        SessionType.exercise => cs.tertiaryContainer,
        SessionType.sleep => cs.surfaceContainerHighest,
        SessionType.other => cs.surfaceContainerHighest,
      };
}
