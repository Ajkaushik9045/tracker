/// Base failure class for the domain layer.
/// All specific failures extend this.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Returned when a server/network error occurs.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'An unexpected error occurred. Please try again.']);
}

/// Returned when the user cancels the Google Sign-In flow.
class AuthCancelledFailure extends Failure {
  const AuthCancelledFailure([super.message = 'Sign-in was cancelled.']);
}
