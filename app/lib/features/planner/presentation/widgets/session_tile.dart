import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/planner_session_entity.dart';
import 'timeline_indicator.dart';

/// A single row in the today-plan timeline.
///
/// Shows the session time range, title, type badge, and a completion toggle.
/// [onMarkCompleted] is called when the user taps the check icon.
class SessionTile extends StatelessWidget {
  /// Creates a [SessionTile].
  const SessionTile({
    super.key,
    required this.session,
    required this.isFirst,
    required this.isLast,
    required this.onMarkCompleted,
  });

  /// The session to display.
  final PlannerSessionEntity session;

  /// Whether this tile is the first in the list.
  final bool isFirst;

  /// Whether this tile is the last in the list.
  final bool isLast;

  /// Called when the user marks this session as completed.
  final VoidCallback onMarkCompleted;

  static final _timeFmt = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final isActive = session.isActive;
    final isCompleted = session.completed;
    final isPast = session.isPast;

    final titleColor = isCompleted || isPast
        ? cs.onSurfaceVariant
        : isActive
            ? cs.tertiary
            : cs.onSurface;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Timeline dot + connectors
          TimelineIndicator(
            session: session,
            isFirst: isFirst,
            isLast: isLast,
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Time range
                        Text(
                          '${_timeFmt.format(session.startTime)} – '
                          '${_timeFmt.format(session.endTime)}',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 2),
                        // Title
                        Text(
                          session.title,
                          style: tt.bodyMedium?.copyWith(
                            color: titleColor,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Type badge
                        _TypeBadge(type: session.type, cs: cs, tt: tt),
                      ],
                    ),
                  ),

                  // Completion toggle (hidden for completed / sleep sessions)
                  if (!isCompleted && session.type != SessionType.sleep)
                    IconButton(
                      onPressed: onMarkCompleted,
                      icon: const Icon(Icons.check_circle_outline),
                      color: cs.primary,
                      iconSize: 20,
                      tooltip: 'Mark as completed',
                      visualDensity: VisualDensity.compact,
                    ),

                  if (isCompleted)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: cs.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private badge
// ---------------------------------------------------------------------------

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.type,
    required this.cs,
    required this.tt,
  });

  final SessionType type;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color, Color) _resolve() => switch (type) {
        SessionType.study => ('Study', cs.primaryContainer, cs.onPrimaryContainer),
        SessionType.habit => ('Habit', cs.tertiaryContainer, cs.onTertiaryContainer),
        SessionType.breakTime => ('Break', cs.secondaryContainer, cs.onSecondaryContainer),
        SessionType.meal => ('Meal', cs.secondaryContainer, cs.onSecondaryContainer),
        SessionType.exercise => ('Exercise', cs.tertiaryContainer, cs.onTertiaryContainer),
        SessionType.sleep => ('Sleep', cs.surfaceContainerHighest, cs.onSurfaceVariant),
        SessionType.other => ('Other', cs.surfaceContainerHighest, cs.onSurfaceVariant),
      };
}
