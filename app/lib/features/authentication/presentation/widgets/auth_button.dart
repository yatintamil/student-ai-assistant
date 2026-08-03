import 'package:flutter/material.dart';

/// A full-width primary action button for authentication forms.
class AuthButton extends StatelessWidget {
  /// Creates an authentication action button.
  const AuthButton({
    required this.label,
    this.onPressed,
    super.key,
  });

  /// The button label.
  final String label;

  /// The action to perform when pressed.
  ///
  /// A `null` value displays the button in its disabled placeholder state.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
