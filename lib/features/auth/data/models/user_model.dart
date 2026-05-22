import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:tracker/features/auth/domain/entities/user_entity.dart';

/// Data model that maps between Firebase User and our domain UserEntity.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.photoUrl,
  });

  /// Creates a UserModel from a Firebase User object.
  factory UserModel.fromFirebaseUser(fb.User user) {
    return UserModel(
      uid: user.uid,
      displayName: user.displayName ?? 'No Name',
      email: user.email ?? 'No Email',
      photoUrl: user.photoURL,
    );
  }

  /// Converts this model to a pure domain entity.
  UserEntity toEntity() => UserEntity(
        uid: uid,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
      );
}
