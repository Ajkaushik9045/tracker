import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';

import 'package:tracker/core/error/exceptions.dart';
import 'package:tracker/core/error/failures.dart';
import 'package:tracker/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:tracker/features/auth/data/models/auth_event_model.dart';
import 'package:tracker/features/auth/domain/entities/auth_event_entity.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
/// Handles error mapping and coordinates datasource calls.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource datasource;

  const AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await datasource.signInWithGoogle();

      // Log successful login event
      try {
        await datasource.logEvent(AuthEventModel(
          userId: user.uid,
          eventType: 'login',
          email: user.email,
        ));
      } catch (_) {
        // Ignore telemetry errors to prevent app crash
      }

      return Right(user.toEntity());
    } on AuthCancelledException {
      // User dismissed the Google Sign-In picker
      _logFailedAttempt('user_cancelled');
      return const Left(AuthCancelledFailure());
    } on FirebaseAuthException catch (e) {
      // Firebase Auth specific errors — classify by error code
      final reason = _classifyFirebaseAuthError(e.code);
      _logFailedAttempt(reason);
      return Left(ServerFailure(_firebaseAuthMessage(e.code)));
    } on SocketException {
      // No internet connection
      _logFailedAttempt('network_error');
      return const Left(NetworkFailure());
    } on HttpException {
      // HTTP-level failure
      _logFailedAttempt('network_error');
      return const Left(NetworkFailure());
    } catch (e) {
      // Classify any remaining exceptions
      final reason = _classifyGenericError(e);
      _logFailedAttempt(reason);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await datasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logAuthEvent(AuthEventEntity event) async {
    try {
      await datasource.logEvent(AuthEventModel(
        userId: event.userId,
        eventType: event.eventType,
        email: event.email,
        failureReason: event.failureReason,
      ));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return datasource.authStateChanges.map(
      (model) => model?.toEntity(),
    );
  }

  // ─── Private Helpers ───

  /// Best-effort logging of a failed attempt. Never throws.
  void _logFailedAttempt(String reason) {
    try {
      datasource.logEvent(AuthEventModel(
        userId: 'unknown',
        eventType: 'failed_attempt',
        email: 'unknown',
        failureReason: reason,
      ));
    } catch (_) {
      // Swallow — telemetry must never break the auth flow
    }
  }

  /// Maps FirebaseAuthException error codes to a failure reason string.
  String _classifyFirebaseAuthError(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'account_exists_different_credential';
      case 'invalid-credential':
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return 'credential_error';
      case 'user-disabled':
        return 'account_disabled';
      case 'user-not-found':
        return 'user_not_found';
      case 'too-many-requests':
        return 'too_many_requests';
      case 'operation-not-allowed':
        return 'operation_not_allowed';
      case 'network-request-failed':
        return 'network_error';
      default:
        return 'firebase_error';
    }
  }

  /// Returns a user-friendly message for FirebaseAuth error codes.
  String _firebaseAuthMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this user.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled for this project.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Classifies non-Firebase exceptions into a reason string.
  String _classifyGenericError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection') ||
        message.contains('unreachable') ||
        message.contains('timed out') ||
        message.contains('timeout')) {
      return 'network_error';
    }

    if (message.contains('google') || message.contains('sign_in')) {
      return 'google_sign_in_error';
    }

    if (message.contains('credential') || message.contains('token')) {
      return 'credential_error';
    }

    if (message.contains('permission') || message.contains('denied')) {
      return 'permission_denied';
    }

    return 'unknown_error';
  }
}
