import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/planner_session_entity.dart';
import '../pages/today_plan_page.dart';

/// Displays the current or next planner session on the dashboard.
///
/// Shows the currently active session (if any) or the next upcoming session.
/// A "View Plan" button navigates to [TodayPlanPage]. When there is no plan at
/// all, a prompt to generate one is shown instead.
class CurrentSessionCard extends StatelessWidget {
  /// Creates a [CurrentSessionCard].
  const CurrentSessionCard({
    super.key,
    required this.currentSession,
    required this.nextSession,
    required this.onMarkCompleted,
  });

  /// The session that is currently active, or `null`.
  final PlannerSessionEntity? currentSession;

  /// The next upcoming session, or `null`.
  final PlannerSessionEntity? nextSession;

  /// Called when the user marks the current session as completed.
  final VoidCallback onMarkCompleted;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final displayed = currentSession ?? nextSession;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ── Header ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.schedule_outlined,
                      size: 18,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentSession != null
                          ? 'Current Session'
                          : 'Up Next',
                      style: tt.titleSmall
                          ?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _openPlanPage(context),
                  child: const Text('View Plan'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Session content or empty prompt ──────────────────────────
            if (displayed == null)
              _NoPlanPrompt(tt: tt, cs: cs, onTap: () => _openPlanPage(context))
            else
              _SessionContent(
                session: displayed,
                isActive: currentSession != null,
                onMarkCompleted:
                    currentSession != null ? onMarkCompleted : null,
                tt: tt,
                cs: cs,
              ),
          ],
        ),
      ),
    );
  }

  void _openPlanPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TodayPlanPage()),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _SessionContent extends StatelessWidget {
  const _SessionContent({
    required this.session,
    required this.isActive,
    required this.onMarkCompleted,
    required this.tt,
    required this.cs,
  });

  final PlannerSessionEntity session;
  final bool isActive;
  final VoidCallback? onMarkCompleted;
  final TextTheme tt;
  final ColorScheme cs;

  static final _timeFmt = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                session.title,
                style: tt.titleSmall?.copyWith(
                  color: isActive ? cs.tertiary : cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_timeFmt.format(session.startTime)} – '
                '${_timeFmt.format(session.endTime)} '
                '(${session.duration.inMinutes} min)',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (onMarkCompleted != null)
          FilledButton.tonal(
            onPressed: onMarkCompleted,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Done'),
          ),
      ],
    );
  }
}

class _NoPlanPrompt extends StatelessWidget {
  const _NoPlanPrompt({
    required this.tt,
    required this.cs,
    required this.onTap,
  });

  final TextTheme tt;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.add_circle_outline,
            size: 20,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'No plan yet — tap to generate',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
