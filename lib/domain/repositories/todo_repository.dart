
import 'package:todo/domain/entities/todo.dart';

abstract class TodoRepository {

  Future<List<Todo>> getTodos();

  Future<void> addTodo(Todo todo);

  Future<void> deleteTodo(String id);

  Future<void> toggleTodo(String id);

  Future<void> updateTodo(Todo todo);
}