import 'package:flutter/material.dart';

/// A full-width primary action used throughout onboarding.
class PrimaryContinueButton extends StatelessWidget {
  /// Creates a primary onboarding action.
  const PrimaryContinueButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Visible action label.
  final String label;

  /// Invoked when the user activates the action.
  final VoidCallback? onPressed;

  /// Whether to replace the label with a progress indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
