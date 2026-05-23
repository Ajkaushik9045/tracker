/// Domain entity representing an authentication event to be logged.
class AuthEventEntity {
  final String userId;
  final String eventType; // 'login', 'logout', 'failed_attempt'
  final String email;

  /// Optional reason for failed attempts.
  /// Examples: 'user_cancelled', 'network_error', 'firebase_auth_error', etc.
  final String? failureReason;

  const AuthEventEntity({
    required this.userId,
    required this.eventType,
    required this.email,
    this.failureReason,
  });
}
