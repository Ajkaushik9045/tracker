import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';

/// Caches the authenticated user's data locally using SharedPreferences.
/// This allows the app to show profile data instantly on restart
/// before Firebase auth state stream emits.
class LocalStorageService {
  final SharedPreferences _prefs;

  static const String _keyUser = 'cached_user';
  static const String _keyIsLoggedIn = 'is_logged_in';

  const LocalStorageService(this._prefs);

  /// Saves user data locally after a successful sign-in.
  Future<void> cacheUser(UserEntity user) async {
    final userMap = {
      'uid': user.uid,
      'displayName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoUrl,
    };
    await _prefs.setString(_keyUser, jsonEncode(userMap));
    await _prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Retrieves the cached user, or null if none exists.
  UserEntity? getCachedUser() {
    final jsonStr = _prefs.getString(_keyUser);
    if (jsonStr == null) return null;

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UserEntity(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  /// Whether a user was previously logged in.
  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;

  /// Clears cached user data on logout.
  Future<void> clearUser() async {
    await _prefs.remove(_keyUser);
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}
