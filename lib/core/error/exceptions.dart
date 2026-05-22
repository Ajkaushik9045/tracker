/// Thrown when the user cancels the Google Sign-In popup.
class AuthCancelledException implements Exception {
  final String message;
  const AuthCancelledException([this.message = 'Authentication was cancelled by the user.']);
}
