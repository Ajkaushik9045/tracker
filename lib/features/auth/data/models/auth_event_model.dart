import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model for auth events stored in Firestore.
/// Maps domain AuthEventEntity to a Firestore-compatible map.
class AuthEventModel {
  final String userId;
  final String eventType; // 'login', 'logout', 'failed_attempt'
  final String email;

  /// Optional reason for failure. Only populated for 'failed_attempt' events.
  /// Possible values:
  ///   - 'user_cancelled'     → user dismissed the Google Sign-In picker
  ///   - 'network_error'      → no internet or DNS failure
  ///   - 'credential_error'   → invalid/expired Google credentials
  ///   - 'account_disabled'   → Firebase account disabled
  ///   - 'too_many_requests'  → rate limited by Firebase
  ///   - 'firebase_error'     → other Firebase Auth errors
  ///   - 'google_sign_in_error' → Google Sign-In SDK error
  ///   - 'unknown_error'      → unclassified exception
  final String? failureReason;

  const AuthEventModel({
    required this.userId,
    required this.eventType,
    required this.email,
    this.failureReason,
  });

  /// Converts to a map for Firestore. Always uses server timestamp.
  /// Only includes failureReason if it's not null (keeps Firestore docs clean).
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'eventType': eventType,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (failureReason != null) {
      map['failureReason'] = failureReason;
    }
    return map;
  }
}
