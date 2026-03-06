import 'package:equatable/equatable.dart';

abstract class TodoEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

// User opened the app / screen
class LoadTodoEvent extends TodoEvent{}

// User submitted the add form
class AddTodoEvent extends TodoEvent{
  final String title;
  final String description;

  AddTodoEvent({required this.title, required this.description});

  @override
  List<Object?> get props => [title,description];
}

// User tapped the checkbox
class ToggleTodoEvent extends TodoEvent{
  final String id;
  ToggleTodoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// User tapped delete
class DeleteTodoEvent extends TodoEvent{
  final String id;
  DeleteTodoEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// User changed filter tab
class FilterTodosEvent extends TodoEvent{
  final TodoFilter filter;

  FilterTodosEvent({required this.filter});

  @override
  List<Object?> get props => [filter];
}
enum TodoFilter {all, active, completed}