import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todo/domain/entities/todo.dart';
import 'package:todo/domain/repositories/todo_repository.dart';
import 'package:todo/domain/usecases/toggle_todo.dart';

@GenerateMocks([TodoRepository])
import 'toggle_todo_test.mocks.dart';
void main(){
  late ToggleTodo useCase;
  late MockTodoRepository mockTodoRepository;
  setUp((){
    mockTodoRepository = MockTodoRepository();
    useCase = ToggleTodo(mockTodoRepository);
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

  test('should call toggleTodo on repository with correct id', () async{
    when(mockTodoRepository.toggleTodo('1')).thenAnswer((_) async{
      testTodos[0] = testTodos.firstWhere((todo)=> todo.id == '1').copyWith(isCompleted: true);
      return ;
    });

    await useCase('1');

    verify(mockTodoRepository.toggleTodo('1')).called(1);
    expect(true, equals(testTodos.first.isCompleted));
    verifyNoMoreInteractions(mockTodoRepository);
  });
}