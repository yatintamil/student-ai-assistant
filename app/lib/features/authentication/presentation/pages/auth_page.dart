import 'package:flutter/material.dart';

import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

/// A responsive, presentation-only authentication page.
///
/// This page intentionally contains no authentication state, controller
/// access, navigation, or action handlers. Those integrations can be supplied
/// later through the reusable widgets' callback properties.
class AuthPage extends StatelessWidget {
  /// Creates the authentication page.
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 600 ? 32.0 : 24.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AuthHeader(
                        title: 'Welcome back',
                        subtitle: 'Sign in to continue learning.',
                      ),
                      SizedBox(height: 32),
                      AuthTextField(
                        label: 'Email address',
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16),
                      AuthTextField(
                        label: 'Password',
                        obscureText: true,
                      ),
                      SizedBox(height: 24),
                      AuthButton(label: 'Sign in'),
                      SizedBox(height: 24),
                      AuthDivider(),
                      SizedBox(height: 24),
                      GoogleSignInButton(),
                    ],
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
