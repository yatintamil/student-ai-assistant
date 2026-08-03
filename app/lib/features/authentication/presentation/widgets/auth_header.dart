import 'package:flutter/material.dart';

/// Displays the title and supporting text at the top of an auth form.
class AuthHeader extends StatelessWidget {
  /// Creates an authentication header.
  const AuthHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  /// The primary heading shown to the user.
  final String title;

  /// The supporting message shown below [title].
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle, style: textTheme.bodyLarge),
      ],
    );
  }
}
