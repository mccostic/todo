import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/domain/entities/todo.dart';
import 'package:todo/domain/usecases/add_todo.dart';
import 'package:todo/domain/usecases/delete_todo.dart';
import 'package:todo/domain/usecases/get_todos.dart';
import 'package:todo/domain/usecases/toggle_todo.dart';
import 'package:todo/presentation/bloc/todo_bloc.dart';
import 'package:todo/presentation/bloc/todo_event.dart';
import 'package:todo/presentation/bloc/todo_state.dart';
import 'todo_bloc_test.mocks.dart';
import 'package:bloc_test/bloc_test.dart';

@GenerateMocks([GetTodos, AddTodo, DeleteTodo, ToggleTodo])

void main() {
  late TodoBloc bloc;
  late MockAddTodo mockAddTodo;
  late MockGetTodos mockGetTodos;
  late MockDeleteTodo mockDeleteTodo;
  late MockToggleTodo mockToggleTodo;

  setUp(() {
    mockGetTodos = MockGetTodos();
    mockAddTodo = MockAddTodo();
    mockDeleteTodo = MockDeleteTodo();
    mockToggleTodo = MockToggleTodo();

    bloc = TodoBloc(
      getTodos: mockGetTodos,
      addTodo: mockAddTodo,
      deleteTodo: mockDeleteTodo,
      toggleTodo: mockToggleTodo,
    );
  });

  tearDown(() => bloc.close());

  final testDate = DateTime(2024);

  final activeTodo = Todo(
    id: '1',
    title: 'Test Todo',
    description: 'Description',
    isCompleted: false,
    createdAt: testDate,
  );

  final completedTodo = Todo(
    id: '2',
    title: 'Completed Todo',
    description: '',
    isCompleted: true,
    createdAt: testDate,
  );

  final todos = [activeTodo, completedTodo];

  group('TodoLoaded', () {

    group('completedCount', () {
      test('returns correct count of completed todos', () {
        final state = TodoLoaded(todos: todos);
        expect(state.completedCount, equals(1));
      });

      test('returns zero when no completed todos', () {
        final state = TodoLoaded(todos: [activeTodo]);
        expect(state.completedCount, equals(0));
      });

      test('returns all when all todos are completed', () {
        final state = TodoLoaded(todos: [completedTodo, completedTodo]);
        expect(state.completedCount, equals(2));
      });
    });

    group('activeCount', () {
      test('returns correct count of active todos', () {
        final state = TodoLoaded(todos: todos);
        expect(state.activeCount, equals(1));
      });

      test('returns zero when no active todos', () {
        final state = TodoLoaded(todos: [completedTodo]);
        expect(state.activeCount, equals(0)); // ← hits !t.isCompleted path
      });

      test('returns all when all todos are active', () {
        final state = TodoLoaded(todos: [activeTodo, activeTodo]);
        expect(state.activeCount, equals(2));
      });
    });

  });


  // ─────────────────────────────────────────
  // LoadTodosEvent
  // ─────────────────────────────────────────
  group('LoadTodosEvent', () {
    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoading, TodoLoaded] on success',
      build: () {
        when(mockGetTodos()).thenAnswer((_) async => [activeTodo]);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadTodoEvent()),
      expect: () => [
        TodoLoading(),
        TodoLoaded(todos: [activeTodo]),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits [TodoLoading, TodoError] on failure',
      build: () {
        when(mockGetTodos()).thenThrow(Exception('Failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadTodoEvent()),
      expect: () => [
        TodoLoading(),
        isA<TodoError>(),
      ],
    );
  });

  // ─────────────────────────────────────────
  // AddTodoEvent
  // ─────────────────────────────────────────
  group('AddTodoEvent', () {
    blocTest<TodoBloc, TodoState>(
      'emits updated TodoLoaded with new todo added',
      build: () {
        when(mockAddTodo(any)).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => TodoLoaded(todos: []),
      act: (bloc) => bloc.add(AddTodoEvent(
        title: 'New Todo',
        description: 'Description',
      )),
      expect: () => [
        isA<TodoLoaded>().having((s) => s.todos.length, 'todos length', 1),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'does nothing if state is not TodoLoaded',
      build: () => bloc,
      seed: () => TodoInitial(),
      act: (bloc) => bloc.add(AddTodoEvent(title: 'New Todo', description: '')),
      expect: () => [],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoError when addTodo fails',
      build: () {
        when(mockAddTodo(any)).thenThrow(Exception('Error'));
        return bloc;
      },
      seed: () => TodoLoaded(todos: []),
      act: (bloc) => bloc.add(AddTodoEvent(
        title: 'New Todo',
        description: 'Description',
      )),
      expect: () => [isA<TodoError>()],
    );
  });

  // ─────────────────────────────────────────
  // ToggleTodoEvent
  // ─────────────────────────────────────────
  group('ToggleTodoEvent', () {
    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with todo toggled to completed',
      build: () {
        when(mockToggleTodo(any)).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => TodoLoaded(todos: [activeTodo]),
      act: (bloc) => bloc.add(ToggleTodoEvent(id: '1')),
      expect: () => [
        TodoLoaded(todos: [activeTodo.copyWith(isCompleted: true)]),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with todo toggled back to active',
      build: () {
        when(mockToggleTodo(any)).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => TodoLoaded(todos: [completedTodo]),
      act: (bloc) => bloc.add(ToggleTodoEvent(id: '2')),
      expect: () => [
        TodoLoaded(todos: [completedTodo.copyWith(isCompleted: false)]),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoError when toggle fails',
      build: () {
        when(mockToggleTodo(any)).thenThrow(Exception('Error'));
        return bloc;
      },
      seed: () => TodoLoaded(todos: [activeTodo]),
      act: (bloc) => bloc.add(ToggleTodoEvent(id: '1')),
      expect: () => [isA<TodoError>()],
    );

    blocTest<TodoBloc, TodoState>(
      'does nothing if state is not TodoLoaded',
      build: () => bloc,
      seed: () => TodoInitial(),
      act: (bloc) => bloc.add(ToggleTodoEvent(id: '1')),
      expect: () => [],
    );
  });

  // ─────────────────────────────────────────
  // DeleteTodoEvent
  // ─────────────────────────────────────────
  group('DeleteTodoEvent', () {
    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with todo removed',
      build: () {
        when(mockDeleteTodo(any)).thenAnswer((_) async {});
        return bloc;
      },
      seed: () => TodoLoaded(todos: [activeTodo]),
      act: (bloc) => bloc.add(DeleteTodoEvent(id: '1')),
      expect: () => [
        TodoLoaded(todos: []),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoError when delete fails',
      build: () {
        when(mockDeleteTodo(any)).thenThrow(Exception('Error'));
        return bloc;
      },
      seed: () => TodoLoaded(todos: [activeTodo]),
      act: (bloc) => bloc.add(DeleteTodoEvent(id: '1')),
      expect: () => [isA<TodoError>()],
    );

    blocTest<TodoBloc, TodoState>(
      'does nothing if state is not TodoLoaded',
      build: () => bloc,
      seed: () => TodoInitial(),
      act: (bloc) => bloc.add(DeleteTodoEvent(id: '1')),
      expect: () => [],
    );
  });

  // ─────────────────────────────────────────
  // FilterTodosEvent
  // ─────────────────────────────────────────
  group('FilterTodosEvent', () {
    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with completed filter',
      build: () => bloc,
      seed: () => TodoLoaded(todos: [activeTodo, completedTodo]),
      act: (bloc) => bloc.add(FilterTodosEvent(filter: TodoFilter.completed)),
      expect: () => [
        TodoLoaded(
          todos: [activeTodo, completedTodo],
          filter: TodoFilter.completed,
        ),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with active filter',
      build: () => bloc,
      seed: () => TodoLoaded(todos: [activeTodo, completedTodo]),
      act: (bloc) => bloc.add(FilterTodosEvent(filter: TodoFilter.active)),
      expect: () => [
        TodoLoaded(
          todos: [activeTodo, completedTodo],
          filter: TodoFilter.active,
        ),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'emits TodoLoaded with all filter',
      build: () => bloc,
      seed: () => TodoLoaded(
        todos: [activeTodo, completedTodo],
        filter: TodoFilter.completed, // start on completed
      ),
      act: (bloc) => bloc.add(FilterTodosEvent(filter: TodoFilter.all)),
      expect: () => [
        TodoLoaded(
          todos: [activeTodo, completedTodo],
          filter: TodoFilter.all,
        ),
      ],
    );

    blocTest<TodoBloc, TodoState>(
      'filteredTodos returns only completed when filter is completed',
      build: () => bloc,
      seed: () => TodoLoaded(todos: [activeTodo, completedTodo]),
      act: (bloc) => bloc.add(FilterTodosEvent(filter: TodoFilter.completed)),
      verify: (bloc) {
        final state = bloc.state as TodoLoaded;
        expect(state.filteredTodo.length, equals(1));
        expect(state.filteredTodo.first.isCompleted, isTrue);
      },
    );

    blocTest<TodoBloc, TodoState>(
      'filteredTodos returns only active when filter is active',
      build: () => bloc,
      seed: () => TodoLoaded(todos: [activeTodo, completedTodo]),
      act: (bloc) => bloc.add(FilterTodosEvent(filter: TodoFilter.active)),
      verify: (bloc) {
        final state = bloc.state as TodoLoaded;
        expect(state.filteredTodo.length, equals(1));
        expect(state.filteredTodo.first.isCompleted, isFalse);
      },
    );

    blocTest<TodoBloc, TodoState>(
      'filteredTodos returns all when filter is all',
      build: () => bloc,
      seed: () => TodoLoaded(todos: [activeTodo, completedTodo]),
      act: (bloc) => bloc.add(FilterTodosEvent(filter: TodoFilter.all)),
      verify: (bloc) {
        final state = bloc.state as TodoLoaded;
        expect(state.filteredTodo.length, equals(2));
      },
    );

    blocTest<TodoBloc, TodoState>(
      'does nothing if state is not TodoLoaded',
      build: () => bloc,
      seed: () => TodoInitial(),
      act: (bloc) => bloc.add(FilterTodosEvent(filter: TodoFilter.completed)),
      expect: () => [],
    );
  });
}
