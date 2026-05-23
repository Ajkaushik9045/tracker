import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tracker/core/services/local_storage_service.dart';
import 'package:tracker/core/usecases/usecase.dart';
import 'package:tracker/features/auth/data/models/auth_event_model.dart';
import 'package:tracker/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:tracker/features/auth/domain/entities/user_entity.dart';
import 'package:tracker/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:tracker/features/auth/domain/usecases/sign_out.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_state.dart';

/// Handles all authentication logic.
/// Receives [AuthBlocEvent]s from the UI and emits [AuthState]s.
class AuthBloc extends Bloc<AuthBlocEvent, AuthState> {
  final SignInWithGoogle _signIn;
  final SignOut _signOut;
  final FirebaseAuthDatasource _datasource;
  final LocalStorageService _localStorage;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this._signIn,
    required this._signOut,
    required this._datasource,
    required this._localStorage,
  }) : super(AuthInitial()) {
    on<SignInRequested>(_onSignIn);
    on<SignOutRequested>(_onSignOut);
    on<AuthCheckRequested>(_onAuthCheck);
  }

  /// Handles sign-in request.
  Future<void> _onSignIn(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _signIn(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        // Cache user data locally for faster app startup
        _localStorage.cacheUser(user);
        emit(Authenticated(user));
      },
    );
  }

  /// Handles sign-out request.
  /// Logs the logout event BEFORE signing out so we still have user context.
  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Capture user info BEFORE emitting AuthLoading (which changes state)
    String userId = 'unknown';
    String email = 'unknown';
    if (state is Authenticated) {
      final user = (state as Authenticated).user;
      userId = user.uid;
      email = user.email;
    }

    emit(AuthLoading());

    // Log the logout event
    try {
      await _datasource.logEvent(AuthEventModel(
        userId: userId,
        eventType: 'logout',
        email: email,
      ));
    } catch (_) {
      // Best-effort logging — don't block sign-out if logging fails
    }

    // Clear cached user data
    await _localStorage.clearUser();

    final result = await _signOut(const NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  /// Checks if user is already signed in on app startup.
  Future<void> _onAuthCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    await emit.forEach<UserEntity?>(
      _datasource.authStateChanges,
      onData: (user) {
        if (user != null) {
          // Update local cache with fresh data
          _localStorage.cacheUser(user);
          return Authenticated(user);
        }
        return Unauthenticated();
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
