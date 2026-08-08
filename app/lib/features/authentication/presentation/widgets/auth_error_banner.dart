import 'package:flutter/material.dart';

/// A full-width banner that displays an authentication error message using
/// Material 3 error colour tokens.
///
/// Renders nothing when [message] is empty — silent outcomes (e.g. a user
/// closing the Google sign-in sheet) produce an empty string from the
/// controller, and the caller should guard with
/// `if (message.isNotEmpty) AuthErrorBanner(message: message)`.
class AuthErrorBanner extends StatelessWidget {
  /// Creates an [AuthErrorBanner] with the given [message].
  const AuthErrorBanner({super.key, required this.message});

  /// The human-readable error message to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 20,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
