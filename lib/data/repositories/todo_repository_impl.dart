// lib/data/repositories/todo_repository_impl.dart
import 'package:logger/logger.dart';
import '../../core/error/error_response.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_response.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDatasource remoteDatasource;
  final TodoLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  TodoRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  // Converts ApiResponse failure → typed AppException
  Never _throwFromResponse(ApiResponse response) {
    final error = response.error!;
    _logger.e('Repository error: ${error.message} (code: ${error.code})');
    throw _mapErrorToException(error);
  }

  AppException _mapErrorToException(ErrorResponse error) {
    switch (error.code) {
      case 1000:
        return NetworkException(message: error.message);
      case 1001:
        return TimeoutException(message: error.message);
      case 1002:
        return ConnectionException(message: error.message);
      case 2001:
        return UnauthorizedException(message: error.message);
      case 2002:
        return ForbiddenException(message: error.message);
      case 2003:
        return NotFoundException(message: error.message);
      case 2004:
        return ConflictException(message: error.message);
      case 2005:
        return ValidationException(message: error.message);
      case 2006:
        return RateLimitException(message: error.message);
      case 3001:
        return TodoNotFoundException(message: error.message);
      case 3002:
        return TodoAlreadyCompletedException(message: error.message);
      case 3003:
        return TodoTitleEmptyException(message: error.message);
      case 3004:
        return TodoLimitExceededException(message: error.message);
      default:
        return ServerException(message: error.message);
    }
  }

  @override
  Future<List<Todo>> getTodos() async {
    if (await networkInfo.isConnected) {
      _logger.d('Fetching todos from remote');
      final response = await remoteDatasource.getTodos();

      if (response.isSuccess) {
        _logger.d('Caching ${response.data!.length} todos locally');
        await localDatasource.saveTodos(response.data!);
        return response.data!;
      }

      // Server failed — fall back to cache
      if (response.error?.code == 2000) {
        _logger.w('Server error — falling back to cache');
        return await localDatasource.getTodos();
      }

      _throwFromResponse(response);
    } else {
      _logger.w('Offline — returning cached todos');
      return await localDatasource.getTodos();
    }
  }

  @override
  Future<void> addTodo(Todo todo) async {
    // Business validation first
    if (todo.title.trim().isEmpty) {
      throw const TodoTitleEmptyException();
    }

    if (await networkInfo.isConnected) {
      _logger.d('Creating todo on remote: ${todo.title}');
      final response = await remoteDatasource.createTodo(
        todo.title,
        todo.description,
      );

      if (response.isSuccess) {
        final todos = await localDatasource.getTodos();
        todos.add(response.data!);
        await localDatasource.saveTodos(todos);
        return;
      }

      _throwFromResponse(response);
    } else {
      _logger.w('Offline — saving todo locally');
      final todos = await localDatasource.getTodos();
      todos.add(TodoModel.fromEntity(todo));
      await localDatasource.saveTodos(todos);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    if (await networkInfo.isConnected) {
      _logger.d('Deleting todo on remote: $id');
      final response = await remoteDatasource.deleteTodo(id);

      // ← Check statusCode OR success, not isSuccess (which requires data != null)
      if (response.success) {
        final todos = await localDatasource.getTodos();
        todos.removeWhere((t) => t.id == id);
        await localDatasource.saveTodos(todos);
        return;
      }

      _throwFromResponse(response);
    } else {
      _logger.w('Offline — deleting todo locally');
      final todos = await localDatasource.getTodos();
      todos.removeWhere((t) => t.id == id);
      await localDatasource.saveTodos(todos);
    }
  }

  @override
  Future<void> toggleTodo(String id) async {
    if (await networkInfo.isConnected) {
      _logger.d('Toggling todo on remote: $id');
      final response = await remoteDatasource.toggleTodo(id);

      if (response.isSuccess) {
        final todos = await localDatasource.getTodos();
        final index = todos.indexWhere((t) => t.id == id);
        if (index != -1) {
          todos[index] = response.data!;
          await localDatasource.saveTodos(todos);
        }
        return;
      }

      _throwFromResponse(response);
    } else {
      _logger.w('Offline — toggling todo locally');
      final todos = await localDatasource.getTodos();
      final index = todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        todos[index] = TodoModel(
          id: todos[index].id,
          title: todos[index].title,
          description: todos[index].description,
          isCompleted: !todos[index].isCompleted,
          createdAt: todos[index].createdAt,
        );
        await localDatasource.saveTodos(todos);
      }
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    if (todo.title.trim().isEmpty) {
      throw const TodoTitleEmptyException();
    }

    if (await networkInfo.isConnected) {
      _logger.d('Updating todo on remote: ${todo.id}');
      final response = await remoteDatasource.updateTodo(
        TodoModel.fromEntity(todo),
      );

      if (response.isSuccess) {
        final todos = await localDatasource.getTodos();
        final index = todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          todos[index] = response.data!;
          await localDatasource.saveTodos(todos);
        }
        return;
      }

      _throwFromResponse(response);
    } else {
      _logger.w('Offline — updating todo locally');
      final todos = await localDatasource.getTodos();
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = TodoModel.fromEntity(todo);
        await localDatasource.saveTodos(todos);
      }
    }
  }
}