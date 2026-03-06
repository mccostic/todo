import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/core/error/exceptions.dart';
import 'package:todo/data/datasources/todo_api_service.dart';
import 'package:todo/data/datasources/todo_remote_datasource.dart';
import 'package:todo/data/datasources/request/create_todo_request.dart';
import 'package:todo/data/datasources/request/update_todo_request.dart';
import 'package:todo/data/models/todo_model.dart';

import 'todo_remote_datasource_test.mocks.dart';

@GenerateMocks([TodoApiService])
void main() {
  late TodoRemoteDatasourceImpl datasource;
  late MockTodoApiService mockApiService;

  setUp(() {
    mockApiService = MockTodoApiService();
    datasource = TodoRemoteDatasourceImpl(apiService: mockApiService);
  });

  final testDate = DateTime(2024, 1, 1);

  final testModel = TodoModel(
    id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    createdAt: testDate,
  );

  // ─────────────────────────────────────────────────────
  // getTodos
  // ─────────────────────────────────────────────────────
  group('getTodos', () {
    test('should return ApiResponse.success with list of todos', () async {
      // Arrange
      when(mockApiService.getTodos()).thenAnswer((_) async => [testModel]);

      // Act
      final result = await datasource.getTodos();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals([testModel]));
      verify(mockApiService.getTodos()).called(1);
    });

    test('should return ApiResponse.failure when service throws NetworkException',
            () async {
          // Arrange
          when(mockApiService.getTodos())
              .thenThrow(const NetworkException());

          // Act
          final result = await datasource.getTodos();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(1000));
        });

    test('should return ApiResponse.failure when service throws UnauthorizedException',
            () async {
          // Arrange
          when(mockApiService.getTodos())
              .thenThrow(const UnauthorizedException());

          // Act
          final result = await datasource.getTodos();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(2001));
        });

    test('should return ApiResponse.failure when service throws ServerException',
            () async {
          // Arrange
          when(mockApiService.getTodos())
              .thenThrow(const ServerException());

          // Act
          final result = await datasource.getTodos();

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(2000));
        });

    test('should return ApiResponse.failure on unexpected error', () async {
      // Arrange
      when(mockApiService.getTodos()).thenThrow(Exception('Unexpected'));

      // Act
      final result = await datasource.getTodos();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error?.code, equals(9999));
    });
  });

  // ─────────────────────────────────────────────────────
  // createTodo
  // ─────────────────────────────────────────────────────
  group('createTodo', () {
    test('should return ApiResponse.success with created todo', () async {
      // Arrange
      when(mockApiService.createTodo(any)).thenAnswer((_) async => testModel);

      // Act
      final result = await datasource.createTodo('Test Todo', 'Test Description');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.title, equals('Test Todo'));
      verify(mockApiService.createTodo(
        argThat(
          predicate<CreateTodoRequest>(
                (r) => r.title == 'Test Todo' && r.description == 'Test Description',
          ),
        ),
      )).called(1);
    });

    test('should return ApiResponse.failure when service throws TodoLimitExceededException',
            () async {
          // Arrange
          when(mockApiService.createTodo(any))
              .thenThrow(const TodoLimitExceededException());

          // Act
          final result = await datasource.createTodo('Test', 'Description');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(3004));
        });

    test('should return ApiResponse.failure when service throws NetworkException',
            () async {
          // Arrange
          when(mockApiService.createTodo(any))
              .thenThrow(const NetworkException());

          // Act
          final result = await datasource.createTodo('Test', 'Description');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(1000));
        });

    test('should return ApiResponse.failure on unexpected error', () async {
      // Arrange
      when(mockApiService.createTodo(any)).thenThrow(Exception('Unexpected'));

      // Act
      final result = await datasource.createTodo('Test', 'Description');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error?.code, equals(9999));
    });
  });

  // ─────────────────────────────────────────────────────
  // updateTodo
  // ─────────────────────────────────────────────────────
  group('updateTodo', () {
    test('should return ApiResponse.success with updated todo', () async {
      // Arrange
      final updatedModel = TodoModel(
        id: '1',
        title: 'Updated Title',
        description: 'Updated Description',
        isCompleted: true,
        createdAt: testDate,
      );
      when(mockApiService.updateTodo(any, any))
          .thenAnswer((_) async => updatedModel);

      // Act
      final result = await datasource.updateTodo(updatedModel);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.title, equals('Updated Title'));
      expect(result.data?.isCompleted, isTrue);
      verify(mockApiService.updateTodo(
        '1',
        argThat(
          predicate<UpdateTodoRequest>(
                (r) =>
            r.title == 'Updated Title' &&
                r.description == 'Updated Description' &&
                r.isCompleted == true,
          ),
        ),
      )).called(1);
    });

    test('should return ApiResponse.failure when service throws NotFoundException',
            () async {
          // Arrange
          when(mockApiService.updateTodo(any, any))
              .thenThrow(const NotFoundException());

          // Act
          final result = await datasource.updateTodo(testModel);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(2003));
        });

    test('should return ApiResponse.failure when service throws NetworkException',
            () async {
          // Arrange
          when(mockApiService.updateTodo(any, any))
              .thenThrow(const NetworkException());

          // Act
          final result = await datasource.updateTodo(testModel);

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(1000));
        });

    test('should return ApiResponse.failure on unexpected error', () async {
      // Arrange
      when(mockApiService.updateTodo(any, any))
          .thenThrow(Exception('Unexpected'));

      // Act
      final result = await datasource.updateTodo(testModel);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error?.code, equals(9999));
    });
  });

  // ─────────────────────────────────────────────────────
  // toggleTodo
  // ─────────────────────────────────────────────────────
  group('toggleTodo', () {
    test('should return ApiResponse.success with toggled todo', () async {

      final toggledModel = TodoModel(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: true,  // flipped
        createdAt: testDate,
      );
      when(mockApiService.toggleTodo(any))
          .thenAnswer((_) async => toggledModel);

      // Act
      final result = await datasource.toggleTodo('1');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data?.isCompleted, isTrue);
      verify(mockApiService.toggleTodo('1')).called(1);
    });

    test('should return ApiResponse.failure when service throws TodoNotFoundException',
            () async {
          // Arrange
          when(mockApiService.toggleTodo(any))
              .thenThrow(const TodoNotFoundException());

          // Act
          final result = await datasource.toggleTodo('999');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(3001));
        });

    test('should return ApiResponse.failure when service throws NetworkException',
            () async {
          // Arrange
          when(mockApiService.toggleTodo(any))
              .thenThrow(const NetworkException());

          // Act
          final result = await datasource.toggleTodo('1');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(1000));
        });

    test('should return ApiResponse.failure on unexpected error', () async {
      // Arrange
      when(mockApiService.toggleTodo(any)).thenThrow(Exception('Unexpected'));

      // Act
      final result = await datasource.toggleTodo('1');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error?.code, equals(9999));
    });
  });

  // ─────────────────────────────────────────────────────
  // deleteTodo
  // ─────────────────────────────────────────────────────
  group('deleteTodo', () {
    test('should return ApiResponse.success on successful delete', () async {
      // Arrange
      when(mockApiService.deleteTodo(any)).thenAnswer((_) async {});

      // Act
      final result = await datasource.deleteTodo('1');

      // Assert
      expect(result.isSuccess, isTrue);
      verify(mockApiService.deleteTodo('1')).called(1);
    });

    test('should return ApiResponse.failure when service throws TodoNotFoundException',
            () async {
          // Arrange
          when(mockApiService.deleteTodo(any))
              .thenThrow(const TodoNotFoundException());

          // Act
          final result = await datasource.deleteTodo('999');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(3001));
        });

    test('should return ApiResponse.failure when service throws NetworkException',
            () async {
          // Arrange
          when(mockApiService.deleteTodo(any))
              .thenThrow(const NetworkException());

          // Act
          final result = await datasource.deleteTodo('1');

          // Assert
          expect(result.isFailure, isTrue);
          expect(result.error?.code, equals(1000));
        });

    test('should return ApiResponse.failure on unexpected error', () async {
      // Arrange
      when(mockApiService.deleteTodo(any)).thenThrow(Exception('Unexpected'));

      // Act
      final result = await datasource.deleteTodo('1');

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.error?.code, equals(9999));
    });
  });
}