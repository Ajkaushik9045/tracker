import 'package:fpdart/fpdart.dart';
import 'package:tracker/core/error/failures.dart';

/// Base class for all use cases.
/// [Type] is the return type, [Params] is the input type.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use when the use case doesn't need any parameters.
class NoParams {
  const NoParams();
}
