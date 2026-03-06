
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/domain/entities/todo.dart';
import 'package:todo/domain/repositories/todo_repository.dart';
import 'package:todo/domain/usecases/add_todo.dart';


@GenerateMocks([TodoRepository])
import 'add_todo_test.mocks.dart';

void main(){
  late MockTodoRepository mockTodoRepository;
  late AddTodo useCase;
  setUp((){
    mockTodoRepository = MockTodoRepository();
    useCase = AddTodo(mockTodoRepository);
  });

  final testTodo = Todo(
    id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    createdAt: DateTime(2024),
  );

  test('should call addTodo on repository with correct todo', () async {
    when(mockTodoRepository.addTodo(testTodo)).thenAnswer((_) async {});

    await useCase(testTodo);
    verify(mockTodoRepository.addTodo(testTodo)).called(1);
    verifyNoMoreInteractions(mockTodoRepository);
  });
}