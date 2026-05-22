import 'package:fpdart/fpdart.dart';
import 'package:tracker/core/error/failures.dart';
import 'package:tracker/core/usecases/usecase.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Sign in the user with Google.
class SignInWithGoogle implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  const SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.signInWithGoogle();
  }
}
