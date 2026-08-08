import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/router/route_names.dart';

/// Displays a time-sensitive greeting and the current date.
///
/// When [displayName] is provided, the greeting is personalized.
class GreetingCard extends StatelessWidget {
  /// Creates a [GreetingCard].
  const GreetingCard({super.key, this.displayName});

  /// Optional user display name for a personalized greeting.
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final name = displayName?.trim();
    final suffix = name != null && name.isNotEmpty ? ', $name' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${_greeting(now.hour)}$suffix',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM d').format(now),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(RouteNames.settings),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  /// Returns a greeting string based on the [hour] of the day (0–23).
  String _greeting(int hour) {
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }
}
