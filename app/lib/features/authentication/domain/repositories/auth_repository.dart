import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> signInWithGoogle();

  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();
}