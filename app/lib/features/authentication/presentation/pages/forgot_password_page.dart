import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

/// Displays the responsive forgot-password form.
///
/// This page intentionally stops after local validation until the controller
/// exposes a password-reset operation. It already watches
/// [authControllerProvider] so that the future operation can use the same
/// loading-state contract as the other authentication pages.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  /// Creates the forgot-password page.
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

/// Holds the transient forgot-password form state.
class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  static const RegExp _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      return;
    }

    // TODO(authentication): Once AuthController exposes password reset,
    // integrate it here through:
    // ref.read(authControllerProvider.notifier).<reset-password-method>(
    //   _emailController.text.trim(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 40.0 : 24.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.school_outlined,
                              color: colorScheme.onPrimaryContainer,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Forgot Password?',
                          style: textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email to receive a password reset link.',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autofillHints: const <String>[AutofillHints.email],
                          onFieldSubmitted:
                              isLoading ? null : (_) => _sendResetLink(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                            hintText: 'you@example.com',
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Email is required.';
                            }
                            if (!_emailPattern.hasMatch(email)) {
                              return 'Enter a valid email address.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: isLoading ? null : _sendResetLink,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Send Reset Link'),
                        ),
                        const SizedBox(height: 16),
                        const TextButton(
                          onPressed: null,
                          child: Text('Back to Sign In'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
