/// BLoC events for authentication.
/// These are UI-triggered events, NOT Firestore auth events.
abstract class AuthBlocEvent {}

/// User tapped the "Sign in with Google" button.
class SignInRequested extends AuthBlocEvent {}

/// User tapped the "Logout" button.
class SignOutRequested extends AuthBlocEvent {}

/// Check if the user is already authenticated (app startup).
class AuthCheckRequested extends AuthBlocEvent {}
