import 'package:fpdart/fpdart.dart';
import 'package:tracker/core/error/failures.dart';
import 'package:tracker/core/usecases/usecase.dart';
import 'package:tracker/features/auth/domain/entities/auth_event_entity.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';

/// Use case: Log an authentication event (login, logout, failed_attempt).
class LogAuthEvent implements UseCase<void, AuthEventEntity> {
  final AuthRepository repository;

  const LogAuthEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(AuthEventEntity params) {
    return repository.logAuthEvent(params);
  }
}
