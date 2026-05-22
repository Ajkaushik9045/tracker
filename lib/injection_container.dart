import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tracker/core/services/local_storage_service.dart';
import 'package:tracker/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:tracker/features/auth/domain/usecases/log_auth_event.dart';
import 'package:tracker/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:tracker/features/auth/domain/usecases/sign_out.dart';
import 'package:tracker/features/auth/presentation/bloc/auth_bloc.dart';

/// Service locator instance.
final sl = GetIt.instance;

/// Registers all dependencies.
/// [prefs] must be pre-initialized since SharedPreferences.getInstance() is async.
void init(SharedPreferences prefs) {
  // ─── Core Services ───
  sl.registerLazySingleton(() => LocalStorageService(prefs));

  // ─── BLoC ───
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signOut: sl(),
      datasource: sl(),
      localStorage: sl(),
    ),
  );

  // ─── Use Cases ───
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => LogAuthEvent(sl()));

  // ─── Repository ───
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // ─── Data Sources ───
  sl.registerLazySingleton(() => FirebaseAuthDatasource());
}
