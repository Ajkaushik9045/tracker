import 'package:fpdart/fpdart.dart';
import 'package:tracker/core/error/failures.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';
import 'package:tracker/features/auth/domain/entities/auth_event_entity.dart';

/// Abstract repository contract for auth operations.
/// The domain layer defines WHAT can be done; the data layer defines HOW.
abstract class AuthRepository {
  /// Attempts Google Sign-In. Returns [UserEntity] on success or [Failure].
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Signs out the current user.
  Future<Either<Failure, void>> signOut();

  /// Logs an authentication event to the backend.
  Future<Either<Failure, void>> logAuthEvent(AuthEventEntity event);

  /// Stream of auth state changes. Emits null when signed out.
  Stream<UserEntity?> get authStateChanges;
}
