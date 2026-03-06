import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/data/datasources/todo_api_service.dart';
import 'package:todo/data/datasources/todo_local_datasource.dart';
import 'package:todo/data/datasources/todo_remote_datasource.dart';
import 'package:todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/domain/repositories/todo_repository.dart';
import 'package:todo/domain/usecases/add_todo.dart';
import 'package:todo/domain/usecases/delete_todo.dart';
import 'package:todo/domain/usecases/get_todos.dart';
import 'package:todo/domain/usecases/toggle_todo.dart';
import 'package:todo/presentation/bloc/todo_bloc.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── BLoC ────────────────────────────────────────────
  // Factory = new instance every time it's requested
  sl.registerFactory(() => TodoBloc(
    getTodos: sl(),
    addTodo: sl(),
    deleteTodo: sl(),
    toggleTodo: sl(),
  ));

  // ─── Use Cases ───────────────────────────────────────
  // LazySingleton = created once, first time it's requested
  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));
  sl.registerLazySingleton(() => ToggleTodo(sl()));

  // ─── Repository ──────────────────────────────────────
  // Now takes remoteDatasource, localDatasource and networkInfo
  sl.registerLazySingleton<TodoRepository>(
        () => TodoRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  // ─── Datasources ─────────────────────────────────────
  sl.registerLazySingleton<TodoRemoteDatasource>(
        () => TodoRemoteDatasourceImpl(apiService: sl()),
  );

  sl.registerLazySingleton<TodoLocalDatasource>(
        () => TodoLocalDatasourceImpl(sharedPreferences: sl()),
  );

  // ─── Network ─────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(sl()),
  );

  // Dio instance created via DioClient which sets up
  // all interceptors — Auth, Logging, Error
  sl.registerLazySingleton<Dio>(
        () => DioClient.createDio(),
  );

  // Retrofit service — uses the Dio instance
  sl.registerLazySingleton<TodoApiService>(
        () => TodoApiService(sl<Dio>()),
  );

  // Internet connection checker for NetworkInfo
  sl.registerLazySingleton(
        () => InternetConnectionChecker(),
  );

  // ─── External ────────────────────────────────────────
  // Singleton = created immediately and always same instance
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
}