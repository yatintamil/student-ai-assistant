import 'package:flutter/material.dart';

/// Separates alternative authentication methods with a centered label.
class AuthDivider extends StatelessWidget {
  /// Creates a labeled authentication divider.
  const AuthDivider({
    this.label = 'or',
    super.key,
  });

  /// The label displayed between the divider lines.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
