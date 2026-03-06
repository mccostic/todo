import 'package:todo/domain/entities/todo.dart';
import 'package:todo/domain/repositories/todo_repository.dart';

class AddTodo {
  final TodoRepository repository;
  AddTodo(this.repository);

  Future<void> call(Todo todo) => repository.addTodo(todo);

}