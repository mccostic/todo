import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/todo_model.dart';
import 'request/create_todo_request.dart';
import 'request/update_todo_request.dart';

part 'todo_api_service.g.dart';

@RestApi()
abstract class TodoApiService {
  factory TodoApiService(Dio dio, {String baseUrl}) = _TodoApiService;

  @GET('/todos/')      // ← trailing slash
  Future<List<TodoModel>> getTodos();

  @GET('/todos/{id}')
  Future<TodoModel> getTodo(@Path('id') String id);

  @POST('/todos/')     // ← trailing slash
  Future<TodoModel> createTodo(@Body() CreateTodoRequest request);

  @PUT('/todos/{id}')
  Future<TodoModel> updateTodo(
      @Path('id') String id,
      @Body() UpdateTodoRequest request,
      );

  @PATCH('/todos/{id}/toggle')
  Future<TodoModel> toggleTodo(@Path('id') String id);

  @DELETE('/todos/{id}')
  Future<void> deleteTodo(@Path('id') String id);
}