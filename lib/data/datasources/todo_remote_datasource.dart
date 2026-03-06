import '../../core/network/api_response.dart';
import '../../core/network/safe_api_call.dart';
import '../models/todo_model.dart';
import 'request/create_todo_request.dart';
import 'request/update_todo_request.dart';
import 'todo_api_service.dart';

abstract class TodoRemoteDatasource {
  Future<ApiResponse<List<TodoModel>>> getTodos();
  Future<ApiResponse<TodoModel>> createTodo(String title, String description);
  Future<ApiResponse<TodoModel>> updateTodo(TodoModel todo);
  Future<ApiResponse<TodoModel>> toggleTodo(String id);
  Future<ApiResponse<void>> deleteTodo(String id);
}

class TodoRemoteDatasourceImpl implements TodoRemoteDatasource {
  final TodoApiService apiService;

  TodoRemoteDatasourceImpl({required this.apiService});

  @override
  Future<ApiResponse<List<TodoModel>>> getTodos() {
    return safeApiCall(
      call: () => apiService.getTodos(),
    );
  }

  @override
  Future<ApiResponse<TodoModel>> createTodo(
      String title,
      String description,
      ) {
    return safeApiCall(
      call: () => apiService.createTodo(
        CreateTodoRequest(title: title, description: description),
      ),
    );
  }

  @override
  Future<ApiResponse<TodoModel>> updateTodo(TodoModel todo) {
    return safeApiCall(
      call: () => apiService.updateTodo(
        todo.id,
        UpdateTodoRequest(
          title: todo.title,
          description: todo.description,
          isCompleted: todo.isCompleted,
        ),
      ),
    );
  }

  @override
  Future<ApiResponse<TodoModel>> toggleTodo(String id) {
    return safeApiCall(
      call: () => apiService.toggleTodo(id),
    );
  }

  @override
  Future<ApiResponse<void>> deleteTodo(String id) {
    return safeApiVoidCall(
      call: () => apiService.deleteTodo(id),
    );
  }
}