import 'package:fpdart/fpdart.dart';
import 'package:tracker/core/error/failures.dart';
import 'package:tracker/core/usecases/usecase.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Sign out the current user.
class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
