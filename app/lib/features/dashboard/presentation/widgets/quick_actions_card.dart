import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/router/route_names.dart';
import '../../../goals/presentation/pages/goal_list_page.dart';
import '../../../tasks/presentation/pages/add_task_page.dart';

/// Displays a row of quick-action buttons for common operations.
class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.bolt_outlined, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceAround,
              children: <Widget>[
                _ActionButton(
                  icon: Icons.event_outlined,
                  label: 'Calendar',
                  onPressed: () => context.push(RouteNames.calendar),
                ),
                _ActionButton(
                  icon: Icons.add_task_outlined,
                  label: 'Add Task',
                  onPressed: () => _navigateTo(context, const AddTaskPage()),
                ),
                _ActionButton(
                  icon: Icons.calendar_today_outlined,
                  label: 'Today\'s Plan',
                  onPressed: () => context.push(RouteNames.plan),
                ),
                _ActionButton(
                  icon: Icons.flag_outlined,
                  label: 'Goals',
                  onPressed: () => _navigateTo(context, const GoalListPage()),
                ),
                _ActionButton(
                  icon: Icons.menu_book_outlined,
                  label: 'Journal',
                  onPressed: () => context.push(RouteNames.journal),
                ),
                _ActionButton(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onPressed: () => context.push(RouteNames.settings),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(RouteNames.aiAssistant),
                icon: const Icon(Icons.smart_toy_outlined, size: 18),
                label: const Text('Ask AI Chief of Staff'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FilledButton.tonal(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(14),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(icon, size: 20, color: colorScheme.onSecondaryContainer),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
