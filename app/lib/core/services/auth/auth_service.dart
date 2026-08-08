import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthService {
  User? get currentUser;

  Stream<User?> authStateChanges();

  Future<UserCredential> signInWithGoogle();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();
}