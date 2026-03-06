
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/domain/entities/todo.dart';
import 'package:todo/domain/repositories/todo_repository.dart';
import 'package:todo/domain/usecases/get_todos.dart';


@GenerateMocks([TodoRepository])
import 'get_todos_test.mocks.dart';
void main (){
  late GetTodos useCase;
  late MockTodoRepository mockTodoRepository;

  setUp((){
    mockTodoRepository = MockTodoRepository();
    useCase = GetTodos(mockTodoRepository);
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

  test('should get todos from repository', () async{
    when(mockTodoRepository.getTodos()).thenAnswer((_) async => testTodos);

    //Act
    final result = await useCase();

    //Assert
    expect(result, equals(testTodos));
    verify(mockTodoRepository.getTodos()).called(1);
    verifyNoMoreInteractions(mockTodoRepository);
  });
}