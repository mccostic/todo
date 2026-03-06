import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/core/error/exceptions.dart';
import 'package:todo/core/network/api_response.dart';
import 'package:todo/core/network/network_info.dart';
import 'package:todo/data/datasources/todo_local_datasource.dart';
import 'package:todo/data/datasources/todo_remote_datasource.dart';
import 'package:todo/data/models/todo_model.dart';
import 'package:todo/data/repositories/todo_repository_impl.dart';
import 'package:todo/domain/entities/todo.dart';
import 'package:todo/core/error/error_response.dart';

import 'todo_repository_impl_test.mocks.dart';

@GenerateMocks([
  TodoLocalDatasource,
  TodoRemoteDatasource,
  NetworkInfo,
])
void main() {
  late TodoRepositoryImpl repository;
  late MockTodoLocalDatasource mockLocalDatasource;
  late MockTodoRemoteDatasource mockRemoteDatasource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDatasource = MockTodoLocalDatasource();
    mockRemoteDatasource = MockTodoRemoteDatasource();
    mockNetworkInfo = MockNetworkInfo();

    repository = TodoRepositoryImpl(
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocalDatasource,
      networkInfo: mockNetworkInfo,
    );
  });

  final testDate = DateTime(2024, 1, 1);

  final testModel = TodoModel(
    id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    createdAt: testDate,
  );

  final testTodo = Todo(
    id: '2',
    title: 'New Todo',
    description: 'New Description',
    isCompleted: false,
    createdAt: testDate,
  );

  // ─── Helpers ──────────────────────────────────────────
  // Reduces repetition for online/offline setup
  void setOnline() =>
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

  void setOffline() =>
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

  // ─────────────────────────────────────────────────────
  // getTodos
  // ─────────────────────────────────────────────────────
  group('getTodos', () {
    test('online: should return remote todos and cache them', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.getTodos()).thenAnswer(
            (_) async => ApiResponse.success([testModel]),
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      final result = await repository.getTodos();

      // Assert
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
      verify(mockRemoteDatasource.getTodos()).called(1);
      // Verify remote data was cached locally
      verify(mockLocalDatasource.saveTodos([testModel])).called(1);
    });

    test('online: should fall back to cache when server error (2000)', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.getTodos()).thenAnswer(
            (_) async => ApiResponse.failure(
          const ErrorResponse(code: 2000, message: 'Server error'),
        ),
      );
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );

      // Act
      final result = await repository.getTodos();

      // Assert — fell back to local cache
      expect(result.length, equals(1));
      verify(mockLocalDatasource.getTodos()).called(1);
    });

    test('online: should throw UnauthorizedException on 401', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.getTodos()).thenAnswer(
            (_) async => ApiResponse.failure(
          const ErrorResponse(code: 2001, message: 'Unauthorized'),
        ),
      );

      // Assert
      expect(
            () => repository.getTodos(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('offline: should return cached todos', () async {
      // Arrange
      setOffline();
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );

      // Act
      final result = await repository.getTodos();

      // Assert — remote never called
      expect(result.length, equals(1));
      verifyNever(mockRemoteDatasource.getTodos());
      verify(mockLocalDatasource.getTodos()).called(1);
    });

    test('offline: should return empty list when no cache', () async {
      // Arrange
      setOffline();
      when(mockLocalDatasource.getTodos()).thenAnswer((_) async => []);

      // Act
      final result = await repository.getTodos();

      // Assert
      expect(result, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────
  // addTodo
  // ─────────────────────────────────────────────────────
  group('addTodo', () {
    test('online: should create on remote and update cache', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.createTodo(any, any)).thenAnswer(
            (_) async => ApiResponse.success(testModel),
      );
      when(mockLocalDatasource.getTodos()).thenAnswer((_) async => []);
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.addTodo(testTodo);

      // Assert
      verify(mockRemoteDatasource.createTodo(
        testTodo.title,
        testTodo.description,
      )).called(1);
      verify(mockLocalDatasource.saveTodos(any)).called(1);
    });

    test('online: should throw TodoTitleEmptyException when title is empty',
            () async {
          // Arrange
          setOnline();
          final emptyTodo = Todo(
            id: '3',
            title: '',  // empty title
            description: '',
            isCompleted: false,
            createdAt: testDate,
          );

          // Assert — thrown before hitting network
          expect(
                () => repository.addTodo(emptyTodo),
            throwsA(isA<TodoTitleEmptyException>()),
          );
          verifyNever(mockRemoteDatasource.createTodo(any, any));
        });

    test('online: should throw when remote returns failure', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.createTodo(any, any)).thenAnswer(
            (_) async => ApiResponse.failure(
          const ErrorResponse(code: 3004, message: 'Limit exceeded'),
        ),
      );

      // Assert
      expect(
            () => repository.addTodo(testTodo),
        throwsA(isA<TodoLimitExceededException>()),
      );
    });

    test('offline: should save todo locally', () async {
      // Arrange
      setOffline();
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.addTodo(testTodo);

      // Assert — remote never called
      verifyNever(mockRemoteDatasource.createTodo(any, any));
      verify(mockLocalDatasource.saveTodos(argThat(
        predicate<List<TodoModel>>((list) => list.length == 2),
      ))).called(1);
    });
  });

  // ─────────────────────────────────────────────────────
  // deleteTodo
  // ─────────────────────────────────────────────────────
  group('deleteTodo', () {
    test('online: should delete on remote and remove from cache', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.deleteTodo(any)).thenAnswer(
            (_) async => ApiResponse.success(null),
      );
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.deleteTodo('1');

      // Assert
      verify(mockRemoteDatasource.deleteTodo('1')).called(1);
      verify(mockLocalDatasource.saveTodos(argThat(
        predicate<List<TodoModel>>((list) => list.isEmpty),
      ))).called(1);
    });

    test('online: should throw TodoNotFoundException when not found', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.deleteTodo(any)).thenAnswer(
            (_) async => ApiResponse.failure(
          const ErrorResponse(code: 3001, message: 'Todo not found'),
        ),
      );

      // Assert
      expect(
            () => repository.deleteTodo('999'),
        throwsA(isA<TodoNotFoundException>()),
      );
    });

    test('offline: should delete from local cache only', () async {
      // Arrange
      setOffline();
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.deleteTodo('1');

      // Assert — remote never called
      verifyNever(mockRemoteDatasource.deleteTodo(any));
      verify(mockLocalDatasource.saveTodos(argThat(
        predicate<List<TodoModel>>((list) => list.isEmpty),
      ))).called(1);
    });
  });

  // ─────────────────────────────────────────────────────
  // toggleTodo
  // ─────────────────────────────────────────────────────
  group('toggleTodo', () {
    test('online: should toggle on remote and update cache', () async {
      // Arrange
      setOnline();
      final toggledModel = TodoModel(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: true, // flipped
        createdAt: testDate,
      );
      when(mockRemoteDatasource.toggleTodo(any)).thenAnswer(
            (_) async => ApiResponse.success(toggledModel),
      );
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.toggleTodo('1');

      // Assert — saved with flipped value from server response
      verify(mockLocalDatasource.saveTodos(argThat(
        predicate<List<TodoModel>>(
              (list) => list.first.isCompleted == true,
        ),
      ))).called(1);
    });

    test('online: should throw TodoNotFoundException when not found', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.toggleTodo(any)).thenAnswer(
            (_) async => ApiResponse.failure(
          const ErrorResponse(code: 3001, message: 'Todo not found'),
        ),
      );

      // Assert
      expect(
            () => repository.toggleTodo('999'),
        throwsA(isA<TodoNotFoundException>()),
      );
    });

    test('offline: should toggle in local cache', () async {
      // Arrange
      setOffline();
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.toggleTodo('1');

      // Assert — remote never called, local flipped
      verifyNever(mockRemoteDatasource.toggleTodo(any));
      verify(mockLocalDatasource.saveTodos(argThat(
        predicate<List<TodoModel>>(
              (list) => list.first.isCompleted == true,
        ),
      ))).called(1);
    });
  });

  // ─────────────────────────────────────────────────────
  // updateTodo
  // ─────────────────────────────────────────────────────
  group('updateTodo', () {
    final updatedTodo = Todo(
      id: '1',
      title: 'Updated Title',
      description: 'Updated Description',
      isCompleted: true,
      createdAt: testDate,
    );

    test('online: should update on remote and sync cache', () async {
      // Arrange
      setOnline();
      final updatedModel = TodoModel(
        id: '1',
        title: 'Updated Title',
        description: 'Updated Description',
        isCompleted: true,
        createdAt: testDate,
      );
      when(mockRemoteDatasource.updateTodo(any)).thenAnswer(
            (_) async => ApiResponse.success(updatedModel),
      );
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.updateTodo(updatedTodo);

      // Assert
      verify(mockRemoteDatasource.updateTodo(any)).called(1);
      verify(mockLocalDatasource.saveTodos(argThat(
        predicate<List<TodoModel>>(
              (list) =>
          list.first.title == 'Updated Title' &&
              list.first.isCompleted == true,
        ),
      ))).called(1);
    });

    test('online: should throw TodoTitleEmptyException when title is empty',
            () async {
          // Arrange
          setOnline();
          final emptyTodo = updatedTodo.copyWith(title: '');

          // Assert — thrown before hitting network
          expect(
                () => repository.updateTodo(emptyTodo),
            throwsA(isA<TodoTitleEmptyException>()),
          );
          verifyNever(mockRemoteDatasource.updateTodo(any));
        });

    test('online: should throw TodoNotFoundException when not found', () async {
      // Arrange
      setOnline();
      when(mockRemoteDatasource.updateTodo(any)).thenAnswer(
            (_) async => ApiResponse.failure(
          const ErrorResponse(code: 3001, message: 'Not found'),
        ),
      );

      // Assert
      expect(
            () => repository.updateTodo(updatedTodo),
        throwsA(isA<TodoNotFoundException>()),
      );
    });

    test('offline: should update in local cache only', () async {
      // Arrange
      setOffline();
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      // Act
      await repository.updateTodo(updatedTodo);

      // Assert — remote never called
      verifyNever(mockRemoteDatasource.updateTodo(any));
      verify(mockLocalDatasource.saveTodos(argThat(
        predicate<List<TodoModel>>(
              (list) => list.first.title == 'Updated Title',
        ),
      ))).called(1);
    });



    test('should not update when id does not match', () async {
      // Arrange
      setOffline();
      when(mockLocalDatasource.getTodos()).thenAnswer(
            (_) async => [testModel],
      );
      when(mockLocalDatasource.saveTodos(any)).thenAnswer((_) async {});

      final wrongIdTodo = Todo(
        id: '999', // does not exist
        title: 'Updated Title',
        description: '',
        isCompleted: false,
        createdAt: testDate,
      );

      // Act
      await repository.updateTodo(wrongIdTodo);

      // Assert — saveTodos never called because index was -1
      verifyNever(mockLocalDatasource.saveTodos(any));
    });
  });
}
