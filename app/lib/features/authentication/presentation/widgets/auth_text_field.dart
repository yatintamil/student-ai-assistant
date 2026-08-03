import 'package:flutter/material.dart';

/// A consistently styled text field for authentication forms.
class AuthTextField extends StatelessWidget {
  /// Creates an authentication text field.
  const AuthTextField({
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    super.key,
  });

  /// The persistent field label.
  final String label;

  /// Optional example text displayed within the field.
  final String? hintText;

  /// The keyboard type requested for text entry.
  final TextInputType? keyboardType;

  /// Whether entered text is obscured.
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: hintText,
        labelText: label,
      ),
    );
  }
}
