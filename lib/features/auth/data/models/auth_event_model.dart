import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for auth events stored in Firestore.
/// Maps domain AuthEventEntity to a Firestore-compatible map.
class AuthEventModel {
  final String userId;
  final String eventType; // 'login', 'logout', 'failed_attempt'
  final String email;

  const AuthEventModel({
    required this.userId,
    required this.eventType,
    required this.email,
  });

  /// Converts to a map for Firestore. Always uses server timestamp.
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'eventType': eventType,
        'email': email,
        'timestamp': FieldValue.serverTimestamp(),
      };
}
