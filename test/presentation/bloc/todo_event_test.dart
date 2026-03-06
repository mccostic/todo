import 'package:flutter_test/flutter_test.dart';
import 'package:todo/presentation/bloc/todo_event.dart';

void main(){
  group('TodoEvent equality', () {

    group('LoadTodoEvent', () {
      test('two instances should be equal',(){
        expect(LoadTodoEvent(), equals(LoadTodoEvent()));
      });
    });

    group('AddTodoEvent', () {
      test('two instances with same values should be equal', () {
        expect(AddTodoEvent(title: 'Test', description: 'Desc'),
        equals(AddTodoEvent(title: 'Test', description: 'Desc')));
      });

      test('two instances with different values should not be equal', () {
        expect(
            AddTodoEvent(title: 'Test', description: 'Desc'),
            isNot(AddTodoEvent(title: 'Different', description: 'Desc')));
      });

      test('props should contain title and description', () {
        final event = AddTodoEvent(title: 'Test', description: 'Desc');
        expect(event.props, equals(['Test', 'Desc']));
      });
    });

    group('ToggleTodoEvent', () {
      test('two instances with same id should be equal', () {
        expect(
          ToggleTodoEvent(id: '1'),
          equals(ToggleTodoEvent(id: '1')),
        );
      });

      test('two instances with different id should not be equal', () {
        expect(
          ToggleTodoEvent(id: '1'),
          isNot(equals(ToggleTodoEvent(id: '2'))),
        );
      });

      test('props should contain id', () {
        final event = ToggleTodoEvent(id: '1');
        expect(event.props, equals(['1']));
      });
    });

    group('DeleteTodoEvent', () {
      test('two instances with same id should be equal', () {
        expect(
          DeleteTodoEvent(id: '1'),
          equals(DeleteTodoEvent(id: '1')),
        );
      });

      test('two instances with different id should not be equal', () {
        expect(
          DeleteTodoEvent(id: '1'),
          isNot(equals(DeleteTodoEvent(id: '2'))),
        );
      });

      test('props should contain id', () {
        final event = DeleteTodoEvent(id: '1');
        expect(event.props, equals(['1']));
      });
    });

    group('FilterTodosEvent', () {
      test('two instances with same filter should be equal', () {
        expect(
          FilterTodosEvent(filter: TodoFilter.completed),
          equals(FilterTodosEvent(filter: TodoFilter.completed)),
        );
      });

      test('two instances with different filter should not be equal', () {
        expect(
          FilterTodosEvent(filter: TodoFilter.completed),
          isNot(equals(FilterTodosEvent(filter: TodoFilter.all))),
        );
      });

      test('props should contain filter', () {
        final event = FilterTodosEvent(filter: TodoFilter.all);
        expect(event.props, equals([TodoFilter.all]));
      });
    });

  });
}