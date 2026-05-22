import 'package:tracker/features/auth/domain/entities/user_entity.dart';

/// BLoC states for authentication.
abstract class AuthState {}

/// Initial state before any auth check.
class AuthInitial extends AuthState {}

/// Loading — sign-in or sign-out in progress.
class AuthLoading extends AuthState {}

/// User is authenticated. Holds the [UserEntity].
class Authenticated extends AuthState {
  final UserEntity user;
  Authenticated(this.user);
}

/// User is not authenticated.
class Unauthenticated extends AuthState {}

/// An error occurred during authentication.
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
