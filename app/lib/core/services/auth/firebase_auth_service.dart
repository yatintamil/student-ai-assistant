import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_service.dart';

/// Exception thrown when a third-party sign-in flow is cancelled by the user.
///
/// This is a lightweight, specific exception so callers can distinguish a
/// cancellation from other authentication errors, such as misconfiguration or
/// network failures.
class SignInCancelledException implements Exception {
  /// Creates a [SignInCancelledException] with an optional [message].
  const SignInCancelledException([
    this.message = 'Sign-in was cancelled by the user.',
  ]);

  /// Human-readable message describing the cancellation.
  final String message;

  @override
  String toString() => 'SignInCancelledException: $message';
}

/// Firebase implementation of [AuthService].
///
/// Exposes the authentication operations used by the rest of the application
/// on top of Firebase Authentication and Google Sign-In.
///
/// ## Dependency injection
///
/// [FirebaseAuth] is constructor-injected so that tests can supply a fake,
/// mocked, or otherwise customized instance without touching the global
/// `FirebaseAuth.instance` singleton. This keeps the service decoupled from
/// framework setup and makes its behaviour deterministic in tests.
///
/// [GoogleSignIn] cannot be constructor-injected because `google_sign_in` 7.x
/// removed the public constructor; the SDK now exposes a single stateless
/// instance via [GoogleSignIn.instance]. This service references that
/// singleton directly, and the required one-time initialization is handled
/// internally through [FirebaseAuthService._ensureGoogleSignInInitialized].
class FirebaseAuthService implements AuthService {
  /// Creates a [FirebaseAuthService].
  ///
  /// The [firebaseAuth] instance is required and must be provided by the
  /// caller (for example, via dependency injection or a composition root).
  FirebaseAuthService(this._firebaseAuth);

  /// The injected Firebase Auth client used for all Firebase operations.
  final FirebaseAuth _firebaseAuth;

  /// The Google Sign-In SDK singleton.
  ///
  /// `google_sign_in` 7.x removed its public constructor and requires all
  /// usage to go through [GoogleSignIn.instance]. Referencing it once here
  /// keeps it out of the individual method bodies.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Caches the one-time [GoogleSignIn.initialize] future.
  ///
  /// The `google_sign_in` 7.x SDK requires [GoogleSignIn.initialize] to be
  /// called exactly once and awaited before any other method may be used.
  /// Caching the returned future guarantees that concurrent callers share a
  /// single initialization while still blocking until it completes.
  Future<void>? _googleSignInInitialization;

  /// Ensures the Google Sign-In SDK has been initialized exactly once.
  ///
  /// If initialization is already in progress or has completed, the cached
  /// future is returned. If initialization fails, the cache is cleared so a
  /// later attempt can retry instead of permanently reusing a failed future.
  Future<void> _ensureGoogleSignInInitialized() {
    final Future<void>? existing = _googleSignInInitialization;
    if (existing != null) {
      return existing;
    }

    final Completer<void> completer = Completer<void>();
    _googleSignInInitialization = completer.future;

    // Use then/onError instead of try/catch with await so the guard is
    // installed before initialization starts, making the in-flight future
    // visible to concurrent callers immediately.
    _googleSignIn.initialize().then(
      (_) => completer.complete(),
      onError: (Object error, StackTrace stackTrace) {
        // Reset the guard so a future sign-in attempt can re-initialize.
        _googleSignInInitialization = null;
        completer.completeError(error, stackTrace);
      },
    );

    return completer.future;
  }

  /// The currently signed in [User], or `null` if there is no user.
  ///
  /// Uses the injected [FirebaseAuth] instead of `FirebaseAuth.instance`.
  @override
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes from Firebase.
  ///
  /// Exposes [FirebaseAuth.authStateChanges] so UI layers can reactively
  /// rebuild when the signed-in identity changes (sign-in, sign-out,
  /// session refresh, token refresh).
  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// Signs in using Google Sign-In and Firebase Authentication.
  ///
  /// 1. Ensures the `google_sign_in` SDK is initialized.
  /// 2. Calls [GoogleSignIn.authenticate], which presents the interactive
  ///    Google account picker and returns a [GoogleSignInAccount].
  /// 3. Builds a Firebase [AuthCredential] from the Google ID token and
  ///    exchanges it with [FirebaseAuth.signInWithCredential] to establish a
  ///    Firebase session.
  ///
  /// Throws [SignInCancelledException] when the user cancels the flow. The
  /// cancellation can surface either as a typed [GoogleSignInException] or,
  /// on some native platforms, as a [PlatformException]; both are mapped to
  /// [SignInCancelledException]. All other errors are rethrown unchanged so
  /// callers can distinguish user cancellation from real failures.
  ///
  /// The returned [UserCredential] describes the new Firebase session and is
  /// returned to the caller per the [AuthService] contract.
  @override
  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount googleUser;
    try {
      // authenticate() is the 7.x replacement for the removed signIn().
      // Unlike signIn(), it never returns null: every failure — including
      // user cancellation — is communicated by throwing a
      // GoogleSignInException, so we must map that onto our own
      // cancellation signal below.
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SignInCancelledException();
      }
      rethrow;
    } on PlatformException catch (error) {
      // Defensive path: some native platform implementations may still
      // surface user cancellation through the platform channel as a
      // PlatformException rather than a typed GoogleSignInException.
      if (error.code == 'sign_in_canceled' || error.code == 'CANCELLED') {
        throw const SignInCancelledException();
      }
      rethrow;
    }

    // In 7.x, GoogleSignInAuthentication exposes only an ID token. The ID
    // token is the secure, verifiable proof of Google identity required to
    // mint a Firebase credential. If the platform did not return one, the
    // sign-in cannot proceed and should fail loudly rather than silently
    // creating an unusable session.
    final String? idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw StateError('Google sign-in completed without an ID token.');
    }

    // Bridge the Google identity into Firebase by creating an OAuth
    // credential from the ID token, then exchange that credential for a
    // full Firebase session via the injected FirebaseAuth instance.
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs in with email and password using Firebase Authentication.
  ///
  /// Re-throws any [FirebaseAuthException] so the caller can surface
  /// localized, user-friendly messages if desired.
  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Registers a new user with email and password and updates the
  /// display name.
  ///
  /// After account creation, the newly created user's display name is
  /// updated to [name], and the user is reloaded so the local cached profile
  /// reflects the change immediately. Any [FirebaseAuthException] is rethrown
  /// for the caller to handle.
  @override
  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;

    if (user != null) {
      // Update the Firebase profile so the display name is persisted on the
      // server and available on other devices and after restarts.
      await user.updateDisplayName(name);
      // Reload the local user object so it reflects the updated profile
      // immediately instead of carrying a stale cached copy.
      await user.reload();
    }

    return userCredential;
  }

  /// Signs out of both Google and Firebase.
  ///
  /// The two sign-outs are performed sequentially, and the Firebase sign-out
  /// is always attempted even when the Google sign-out fails. This is
  /// important because a partial sign-out (for example, a cleared Firebase
  /// session while the Google session survives) would leave the application
  /// in an inconsistent authentication state.
  ///
  /// After both attempts, the first encountered error is rethrown with its
  /// original stack trace so the caller can react. If both sign-outs succeed,
  /// the method completes normally.
  @override
  Future<void> signOut() async {
    await _ensureGoogleSignInInitialized();

    Object? firstError;
    StackTrace? firstStackTrace;

    try {
      // Clear the Google OAuth session first so the next sign-in starts from
      // a clean account picker.
      await _googleSignIn.signOut();
    } catch (error, stackTrace) {
      firstError = error;
      firstStackTrace = stackTrace;
    }

    try {
      // Always attempt the Firebase sign-out, even if the Google sign-out
      // above failed, so the local Firebase session is never left dangling.
      await _firebaseAuth.signOut();
    } catch (error, stackTrace) {
      firstError ??= error;
      firstStackTrace ??= stackTrace;
    }

    if (firstError != null) {
      // Rethrow the first error encountered, preserving its stack trace.
      Error.throwWithStackTrace(
        firstError,
        firstStackTrace ?? StackTrace.current,
      );
    }
  }
}
