import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/services/auth/firebase_auth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';
import '../states/auth_state.dart';

/// The single source of truth for authentication state.
///
/// This controller wraps the [AuthRepository] and exposes the current
/// [AuthState] to the presentation layer. It owns the state lifecycle for
/// every authentication operation (sign-in, registration, sign-out, and
/// session restore) and is the only place that translates exceptions into
/// user-facing messages.
///
/// It intentionally depends only on [AuthRepository] and [AuthState]. It never
/// touches Firebase directly, Firestore, UI classes, or performs navigation,
/// keeping the presentation layer decoupled from the underlying infrastructure.
///
/// ## Riverpod 3
///
/// This controller follows the official Riverpod 3 [Notifier] pattern: it has
/// a zero-argument constructor and resolves its dependencies inside [build]
/// via [Ref.read].
class AuthController extends Notifier<AuthState> {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    Future.microtask(loadCurrentUser);
    return AuthState.loading();
  }

  // ---------------------------------------------------------------------------
  // Public operations
  // ---------------------------------------------------------------------------

  /// Signs the user in with their Google account.
  Future<void> signInWithGoogle() async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithGoogle();
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }
  /// Signs the user in with [email] and [password].
  Future<void> signInWithEmail(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Registers a new user with the given [name], [email], and [password].
  Future<void> register(String name, String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _repository.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Sends a password reset email to [email].
  Future<bool> sendPasswordResetEmail(String email) async {
    state = AuthState.loading();
    try {
      await _repository.sendPasswordResetEmail(email);
      state = AuthState.unauthenticated();
      return true;
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
      return false;
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    state = AuthState.loading();
    try {
      await _repository.signOut();
      state = AuthState.unauthenticated();
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  /// Restores the currently signed-in user, typically at app startup.
  Future<void> loadCurrentUser() async {
    state = AuthState.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (error) {
      state = AuthState.failure(_errorMessage(error));
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping — single place in the app that converts exceptions into
  // user-facing messages.
  // ---------------------------------------------------------------------------

  /// Converts an exception into a safe, human-readable message.
  ///
  /// [FirebaseAuthException] codes are mapped to specific guidance so users
  /// understand what went wrong and how to fix it. [SignInCancelledException]
  /// is silently discarded — a cancelled flow is not an error worth surfacing.
  /// [UnsupportedPlatformException] is shown to inform users about platform
  /// limitations. All other exceptions fall back to a generic message.
  String _errorMessage(Object error) {
    // User cancelled the Google sign-in sheet — not an error.
    if (error is SignInCancelledException) return '';

    // Platform not supported for Google Sign-In
    if (error is UnsupportedPlatformException) {
      return error.message;
    }

    // Google Sign-In configuration error
    if (error is GoogleSignInException) {
      return 'Google Sign-In is not configured correctly. Verify the OAuth client IDs and Android SHA-1/SHA-256 fingerprints in Firebase.';
    }

    // Firebase Authentication errors
    if (error is FirebaseAuthException) {
      final mapped = _mapFirebaseCode(error.code);
      if (mapped.isNotEmpty) return mapped;
      return error.message ?? 'Authentication error (${error.code}).';
    }

    // State errors from service layer
    if (error is StateError) {
      return error.message;
    }

    // String errors
    if (error is String) return error;

    return 'Authentication failed: $error';
  }

  /// Maps a Firebase Authentication error code to a friendly message.
  static String _mapFirebaseCode(String code) {
    return switch (code) {
      // ── Email / password ──────────────────────────────────────────────────
      'invalid-email' => 'That email address is not valid.',
      'user-not-found' =>
        'No account found for that email. Please check the address or create an account.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'user-disabled' =>
        'This account has been disabled. Please contact support.',
      'email-already-in-use' =>
        'An account with that email already exists. Try signing in instead.',
      'weak-password' =>
        'Password is too weak. Use at least 8 characters with a mix of letters and numbers.',
      'requires-recent-login' =>
        'Please sign in again to continue with this action.',
      'credential-already-in-use' =>
        'This credential is already linked to another account.',
      // ── Google / OAuth ────────────────────────────────────────────────────
      'popup-closed-by-user' => '',  // Silent — user chose to close the popup.
      'cancelled' => '', // Silent — user cancelled.
      'popup-blocked' =>
        'The sign-in popup was blocked by the browser. Please allow popups and try again.',
      'unauthorized-domain' =>
        'This domain is not authorized in Firebase Console. Add your current domain (e.g. localhost) in Firebase Auth -> Settings -> Authorized domains.',
      'account-exists-with-different-credential' =>
        'An account already exists with the same email but a different sign-in method.',
      'operation-not-allowed' =>
        'Google sign-in is not enabled for this Firebase project. Enable the Google provider in Firebase Authentication.',
      'configuration-not-found' =>
        'Google sign-in is not configured for this Firebase project. Check the OAuth configuration and try again.',
      'invalid-credential' =>
        'Google sign-in could not verify this credential. Check the app OAuth configuration and try again.',
      'app-not-authorized' =>
        'This app is not authorized to use Google sign-in. Check the Firebase and OAuth configuration.',
      // ── Network ───────────────────────────────────────────────────────────
      'network-request-failed' =>
        'Network error. Please check your connection and try again.',
      // ── Rate limiting ─────────────────────────────────────────────────────
      'too-many-requests' =>
        'Too many attempts. Please wait a moment before trying again.',
      // ── Fallback ──────────────────────────────────────────────────────────
      _ => '',
    };
  }
}
