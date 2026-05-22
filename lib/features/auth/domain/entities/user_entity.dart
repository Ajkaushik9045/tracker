/// Domain entity representing an authenticated user.
/// This is what the rest of the app works with — no Firebase types leak out.
class UserEntity {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });
}
