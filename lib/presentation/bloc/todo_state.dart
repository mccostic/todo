import 'package:equatable/equatable.dart';
import 'package:todo/presentation/bloc/todo_event.dart';

import '../../domain/entities/todo.dart';

abstract class TodoState extends Equatable{
  @override
  List<Object?> get props => [];
}

// Initial state before anything loads
class TodoInitial extends TodoState{}

// Loading from storage
class TodoLoading extends TodoState{}

// Data loaded successfully
class TodoLoaded extends TodoState{
  final List<Todo> todos;
  final TodoFilter filter;

  // Computed property — filtered list based on current filter
  List<Todo> get filteredTodo{
    switch (filter){
      case TodoFilter.active:
        return todos.where((t) => !t.isCompleted).toList();
      case TodoFilter.completed:
        return todos.where((t) => t.isCompleted).toList();
      case TodoFilter.all:
        return todos;
    }
  }

  int get completedCount => todos.where((t)=> t.isCompleted).length;
  int get activeCount => todos.where((t)=> !t.isCompleted).length;

  TodoLoaded({required this.todos, this.filter = TodoFilter.all});

  TodoLoaded copyWith({List<Todo>? todos, TodoFilter? filter}){
    return TodoLoaded(todos: todos ?? this.todos, filter: filter ?? this.filter);
  }

  @override
  List<Object?> get props => [todos,filter];

}

// lib/presentation/bloc/todo_state.dart
class TodoError extends TodoState {
  final String message;
  final int? code;

  TodoError({required this.message, this.code});

  // Helper getters for UI
  bool get isNetworkError => code == 1000 || code == 1001;
  bool get isAuthError => code == 2001 || code == 2002;
  bool get isBusinessError => code != null && code! >= 3000;

  @override
  List<Object?> get props => [message, code];
}