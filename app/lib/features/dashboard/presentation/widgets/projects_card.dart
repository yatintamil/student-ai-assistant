import 'package:flutter/material.dart';

import '../states/dashboard_state.dart';

/// Displays a compact list of the user's active projects.
///
/// Each project is rendered as a [ListTile] with a colour-coded category tag
/// chip. [projects] is a list of [DashboardProject] value objects.
class ProjectsCard extends StatelessWidget {
  /// Creates a [ProjectsCard].
  const ProjectsCard({super.key, required this.projects});

  /// The projects to render.
  final List<DashboardProject> projects;

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
                Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Goal Progress',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (projects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.flag_outlined,
                        size: 40,
                        color: colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No goals yet',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...projects.map(
                (project) => _ProjectRow(
                  project: project,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({
    required this.project,
    required this.textTheme,
    required this.colorScheme,
  });

  final DashboardProject project;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          // Circular progress indicator
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: project.progress,
                  strokeWidth: 4,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: _getProgressColor(project.progress, colorScheme),
                ),
                Text(
                  '${(project.progress * 100).toInt()}%',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _TagChip(
                  tag: project.tag,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress, ColorScheme colorScheme) {
    if (progress >= 1.0) {
      return Colors.green;
    } else if (progress >= 0.7) {
      return colorScheme.primary;
    } else if (progress >= 0.3) {
      return Colors.orange;
    } else {
      return Colors.red.shade400;
    }
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.tag,
    required this.colorScheme,
    required this.textTheme,
  });

  final String tag;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
