import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/domain/usecases/add_todo.dart';
import 'package:todo/domain/usecases/delete_todo.dart';
import 'package:todo/domain/usecases/get_todos.dart';
import 'package:todo/domain/usecases/toggle_todo.dart';
import 'package:todo/presentation/bloc/todo_event.dart';
import 'package:todo/presentation/bloc/todo_state.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/todo.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final DeleteTodo deleteTodo;
  final ToggleTodo toggleTodo;
  final _uuid = const Uuid();

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.deleteTodo,
    required this.toggleTodo,
  }) : super(TodoInitial()) {
    on<LoadTodoEvent>(_onLoadTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<ToggleTodoEvent>(_onToggleTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<FilterTodosEvent>(_onFilterTodos);
  }

  Future<void> _onLoadTodos(
      LoadTodoEvent event,
      Emitter<TodoState> emit,
      ) async {
    emit(TodoLoading());
    try {
      final todos = await getTodos();
      emit(TodoLoaded(todos: todos));
    } on NetworkException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
    } on TimeoutException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
    } on UnauthorizedException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
    } on ForbiddenException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
    } on ServerException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
    } on AppException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
    } catch (e) {
      emit(TodoError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onAddTodo(
      AddTodoEvent event,
      Emitter<TodoState> emit,
      ) async {
    if (state is! TodoLoaded) return;
    final currentState = state as TodoLoaded;

    try {
      final todo = Todo(
        id: _uuid.v4(),
        title: event.title,
        description: event.description,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await addTodo(todo);

      final updatedTodos = List<Todo>.from(currentState.todos)..add(todo);
      emit(currentState.copyWith(todos: updatedTodos));
    } on AppException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
      emit(currentState);
    } catch (e) {
      emit(TodoError(message: 'Failed to add todo: $e'));
      emit(currentState);
    }
  }

  Future<void> _onToggleTodo(
      ToggleTodoEvent event,
      Emitter<TodoState> emit,
      ) async {
    if (state is! TodoLoaded) return;
    final currentState = state as TodoLoaded;

    // Mark as toggling before the API call
    emit(currentState.copyWith(
      togglingIds: {...currentState.togglingIds, event.id},
    ));

    try {
      await toggleTodo(event.id);

      final updatedTodos = currentState.todos.map((todo) {
        if (todo.id == event.id) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList();

      final remainingIds = {...currentState.togglingIds}..remove(event.id);
      emit(currentState.copyWith(
        todos: updatedTodos,
        togglingIds: remainingIds,
      ));
    } on AppException catch (e) {
      final remainingIds = {...currentState.togglingIds}..remove(event.id);
      emit(TodoError(message: e.message, code: e.code));
      emit(currentState.copyWith(togglingIds: remainingIds));
    } catch (e) {
      final remainingIds = {...currentState.togglingIds}..remove(event.id);
      emit(TodoError(message: 'Failed to toggle todo: $e'));
      emit(currentState.copyWith(togglingIds: remainingIds));
    }
  }

  Future<void> _onDeleteTodo(
      DeleteTodoEvent event,
      Emitter<TodoState> emit,
      ) async {
    if (state is! TodoLoaded) return;
    final currentState = state as TodoLoaded;

    try {
      await deleteTodo(event.id);

      final updatedTodos = currentState.todos
          .where((todo) => todo.id != event.id)
          .toList();

      emit(currentState.copyWith(todos: updatedTodos));
    } on AppException catch (e) {
      emit(TodoError(message: e.message, code: e.code));
      emit(currentState);
    } catch (e) {
      emit(TodoError(message: 'Failed to delete todo: $e'));
      emit(currentState);
    }
  }

  void _onFilterTodos(
      FilterTodosEvent event,
      Emitter<TodoState> emit,
      ) {
    if (state is TodoLoaded) {
      emit((state as TodoLoaded).copyWith(filter: event.filter));
    }
  }
}