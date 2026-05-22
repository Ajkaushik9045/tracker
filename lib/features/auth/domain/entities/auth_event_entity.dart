/// Domain entity representing an authentication event to be logged.
class AuthEventEntity {
  final String userId;
  final String eventType; // 'login', 'logout', 'failed_attempt'
  final String email;

  const AuthEventEntity({
    required this.userId,
    required this.eventType,
    required this.email,
  });
}
