import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/auth/firebase_auth_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../states/auth_state.dart';

/// Provides the [FirebaseAuth] client used across the authentication feature.
///
/// This is the single composition root for the Firebase Authentication
/// singleton. It is the only place in the application that references
/// `FirebaseAuth.instance`, so every downstream consumer (via
/// [authServiceProvider]) receives an injectable instance that can be
/// overridden in tests.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provides the [AuthService] abstraction backed by Firebase Authentication.
///
/// Depends on [firebaseAuthProvider] and constructs the concrete
/// [FirebaseAuthService] via constructor injection. Consumers depend on the
/// [AuthService] interface, keeping the service layer decoupled from the
/// Firebase SDK and making it easy to swap in a fake in tests.
final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthService(firebaseAuth);
});

/// Provides the [AuthRepository] abstraction for the authentication feature.
///
/// Depends on [authServiceProvider] and constructs the concrete
/// [AuthRepositoryImpl] via constructor injection. Consumers depend on the
/// [AuthRepository] interface, which exposes only domain entities and keeps
/// the data layer out of the presentation layer.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepositoryImpl(authService);
});

/// Provides the [AuthController], the single source of truth for
/// authentication state.
///
/// This is a [NotifierProvider] that exposes the [AuthController] — a
/// [Notifier<AuthState>] — to the presentation layer. The controller follows
/// the official Riverpod 3 [Notifier] pattern: it has a zero-argument
/// constructor and resolves its [AuthRepository] dependency inside [build]
/// via [Ref.read]. Watching this provider exposes the current [AuthState],
/// while its notifier exposes the authentication operations (sign-in,
/// registration, sign-out, and session restore).
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
