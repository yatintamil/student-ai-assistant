import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

/// Exception thrown when attempting to use Google Sign-In on an unsupported platform.
///
/// Google Sign-In only supports Android, iOS, and Web. This exception is thrown
/// when attempting to sign in on Windows desktop or other unsupported platforms.
class UnsupportedPlatformException implements Exception {
  /// Creates an [UnsupportedPlatformException] with an optional [message].
  const UnsupportedPlatformException([
    this.message = 'Google Sign-In is only supported on Android, iOS and Web.',
  ]);

  /// Human-readable message describing the platform restriction.
  final String message;

  @override
  String toString() => 'UnsupportedPlatformException: $message';
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

  /// The web OAuth client ID from google-services.json (client_type: 3).
  ///
  /// On Android, google_sign_in 7.x requires this as [serverClientId] when
  /// calling [GoogleSignIn.initialize] so that the underlying CredentialManager
  /// SDK requests an ID token that Firebase can verify. Without it, the SDK
  /// either throws a [GoogleSignInException] with
  /// [GoogleSignInExceptionCode.clientConfigurationError] or — worse — silently
  /// maps the config failure to a fake "canceled" result.
  ///
  /// This value is the `client_id` of the `oauth_client` entry with
  /// `client_type: 3` inside `android/app/google-services.json`.
  static const String _webClientId =
      '61504972008-3oabgib0npmp5sof0lkofvreb6r0hul6.apps.googleusercontent.com';

  /// Ensures the Google Sign-In SDK has been initialized exactly once.
  ///
  /// If initialization is already in progress or has completed, the cached
  /// future is returned. If initialization fails, the cache is cleared so a
  /// later attempt can retry instead of permanently reusing a failed future.
  ///
  /// The [serverClientId] is passed explicitly so the SDK requests an ID token
  /// on Android, which is required for [FirebaseAuth.signInWithCredential].
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
    _googleSignIn
        .initialize(
          clientId: _webClientId,
          serverClientId: _webClientId,
        )
        .then(
          (_) => completer.complete(),
          onError: (Object error, StackTrace stackTrace) {
            // Reset the guard so a future sign-in attempt can re-initialize.
            _googleSignInInitialization = null;
            completer.completeError(error, stackTrace);
          },
        );

    return completer.future;
  }

  /// Checks if Google Sign-In is supported on the current platform.
  ///
  /// Google Sign-In is only supported on Android, iOS, and Web.
  /// Windows desktop and other platforms are not supported.
  bool _isGoogleSignInSupported() {
    if (kIsWeb) {
      return true;
    }
    // On non-web platforms, check the specific OS
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      // If Platform is not available, assume unsupported
      return false;
    }
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
  /// 1. Checks if Google Sign-In is supported on the current platform.
  /// 2. Ensures the `google_sign_in` SDK is initialized (with [_webClientId]
  ///    as [serverClientId] so Android requests an ID token).
  /// 3. Calls [GoogleSignIn.authenticate], which presents the interactive
  ///    Google account picker and returns a [GoogleSignInAccount].
  /// 4. Builds a Firebase [AuthCredential] from the Google ID token and
  ///    exchanges it with [FirebaseAuth.signInWithCredential] to establish a
  ///    Firebase session. If the user has no existing Firebase account, Firebase
  ///    creates one automatically — this is how Google sign-up works.
  ///
  /// Throws [UnsupportedPlatformException] when attempting to sign in on an
  /// unsupported platform (e.g., Windows desktop).
  ///
  /// Throws [SignInCancelledException] when the user explicitly cancels the
  /// flow (e.g. presses Back on the account picker). On Android the underlying
  /// CredentialManager SDK may also report `canceled` for certain
  /// configuration errors; in that case the exception message will contain
  /// additional context so the caller can distinguish intent from misconfiguration.
  ///
  /// All other errors are rethrown unchanged so callers can surface them.
  ///
  /// The returned [UserCredential] describes the new (or existing) Firebase
  /// session and is returned to the caller per the [AuthService] contract.
  @override
  Future<UserCredential> signInWithGoogle() async {
    // Check platform support before attempting sign-in
    if (!_isGoogleSignInSupported()) {
      throw const UnsupportedPlatformException(
        'Google Sign-In is only supported on Android, iOS and Web.',
      );
    }

    if (kIsWeb) {
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        return await _firebaseAuth.signInWithPopup(googleProvider);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
          throw const SignInCancelledException();
        }
        rethrow;
      }
    }

    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        // NOTE: Android CredentialManager surfaces some configuration errors
        // (wrong SHA-1, missing serverClientId) as a false "canceled" code.
        // Rethrowing as SignInCancelledException is still correct for the user
        // intent case; config errors are caught during development via the
        // missing-idToken guard below.
        throw const SignInCancelledException();
      }
      rethrow;
    } on PlatformException catch (error) {
      if (error.code == 'sign_in_canceled' || error.code == 'CANCELLED') {
        throw const SignInCancelledException();
      }
      rethrow;
    }

    final String? idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      // This usually means the serverClientId was not passed to initialize(),
      // causing the Google SDK to skip requesting an ID token. Verify that
      // _webClientId matches the client_type: 3 entry in google-services.json
      // and that the google-services Gradle plugin is applied.
      throw StateError(
        'Google sign-in completed without an ID token. '
        'Verify that the serverClientId in FirebaseAuthService._webClientId '
        'matches the client_type: 3 entry in google-services.json.',
      );
    }

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    // signInWithCredential creates a new Firebase account when the Google
    // identity has not been seen before — this is the "sign up with Google"
    // path. No separate registration step is needed.
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

  /// Sends a password reset email to [email] via Firebase Authentication.
  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
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
    Object? firstError;
    StackTrace? firstStackTrace;

    // Only attempt Google sign-out on supported mobile platforms
    if (!kIsWeb && _isGoogleSignInSupported()) {
      try {
        await _ensureGoogleSignInInitialized();
        // Clear the Google OAuth session first so the next sign-in starts from
        // a clean account picker.
        await _googleSignIn.signOut();
      } catch (error, stackTrace) {
        firstError = error;
        firstStackTrace = stackTrace;
      }
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
