
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/domain/entities/todo.dart';
import 'package:todo/domain/usecases/delete_todo.dart';
import 'package:todo/domain/repositories/todo_repository.dart';


@GenerateMocks([TodoRepository])
import 'delete_todo_test.mocks.dart';

void main(){
  late DeleteTodo useCase;
  late MockTodoRepository mockTodoRepository;

  setUp((){
    mockTodoRepository = MockTodoRepository();
    useCase = DeleteTodo(mockTodoRepository);
  });
  final testTodos = [
    Todo(
      id: '1',
      title: 'Test',
      description: '',
      isCompleted: false,
      createdAt: DateTime(2024),
    ),
  ];
  test('should call deleteTodo on repository with correct id', () async {
    when(mockTodoRepository.deleteTodo('1')).thenAnswer((_) async {
      testTodos.removeWhere((todo)=> todo.id == '1');
    });

    await useCase('1');

    verify(mockTodoRepository.deleteTodo('1')).called(1);
    expect([], equals(testTodos));
    verifyNoMoreInteractions(mockTodoRepository);
  });

}