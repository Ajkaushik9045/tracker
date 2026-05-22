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
      await datasource.logEvent(AuthEventModel(
        userId: user.uid,
        eventType: 'login',
        email: user.email,
      ));

      return Right(user.toEntity());
    } on AuthCancelledException {
      // Log the cancellation as a failed attempt
      await datasource.logEvent(const AuthEventModel(
        userId: 'unknown',
        eventType: 'failed_attempt',
        email: 'unknown',
      ));
      return const Left(AuthCancelledFailure());
    } catch (e) {
      // Log any other failure
      await datasource.logEvent(const AuthEventModel(
        userId: 'unknown',
        eventType: 'failed_attempt',
        email: 'unknown',
      ));
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
}
