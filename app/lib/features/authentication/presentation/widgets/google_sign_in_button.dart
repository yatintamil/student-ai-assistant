import 'package:flutter/material.dart';

/// A full-width outlined button reserved for Google sign-in.
class GoogleSignInButton extends StatelessWidget {
  /// Creates a Google sign-in button.
  const GoogleSignInButton({
    this.onPressed,
    super.key,
  });

  /// The action to perform when the button is pressed.
  ///
  /// A `null` value keeps this presentation-only button disabled.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.g_mobiledata),
        label: const Text('Continue with Google'),
        onPressed: onPressed,
      ),
    );
  }
}
