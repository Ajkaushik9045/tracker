import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:tracker/features/auth/presentation/pages/login_page.dart';
import 'package:tracker/features/auth/presentation/pages/profile_page.dart';

/// GoRouter configuration with auth-based redirection.
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnLogin = state.matchedLocation == '/login';

      // If authenticated and on login page → redirect to profile
      if (authState is Authenticated && isOnLogin) {
        return '/profile';
      }

      // If not authenticated and NOT on login page → redirect to login
      if (authState is! Authenticated && !isOnLogin) {
        return '/login';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}

/// Converts a Stream into a Listenable so GoRouter can react to BLoC changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
