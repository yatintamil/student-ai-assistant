import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';

/// Concrete data-layer model representing a user.
///
/// This model extends [UserEntity] from the domain layer so it can be
/// passed through the domain boundary while retaining data-layer
/// serialization/deserialization responsibilities.
///
/// The class is immutable and provides factories for JSON and
/// Firebase [User] conversions.
class UserModel extends UserEntity {
  /// Creates an immutable [UserModel].
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.photoUrl,
  });

  /// Creates a [UserModel] from a JSON map.
  ///
  /// Keys expected:
  /// - `id` -> String
  /// - `name` -> String
  /// - `email` -> String
  /// - `photoUrl` -> String
  ///
  /// Any missing or null values will default to the empty string for
  /// string fields to preserve immutability and avoid null propagation.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }

  /// Creates a [UserModel] from a Firebase [User].
  ///
  /// Mapping rules:
  /// - Firebase [User].uid -> `id`
  /// - Firebase [User].displayName -> `name` (falls back to empty string)
  /// - Firebase [User].email -> `email` (falls back to empty string)
  /// - Firebase [User].photoURL -> `photoUrl`
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  /// Converts this [UserModel] into a JSON map.
  ///
  /// The produced map uses the same keys expected by [fromJson].
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
