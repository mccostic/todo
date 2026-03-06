// test/domain/entities/todo_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/domain/entities/todo.dart';

void main() {
  final testDate = DateTime(2024, 1, 1);

  final testTodo = Todo(
    id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    createdAt: testDate,
  );

  group('Todo', () {

    group('copyWith', () {
      test('should update only provided fields', () {
        final result = testTodo.copyWith(title: 'New Title');

        expect(result.title, equals('New Title'));
        expect(result.id, equals('1'));           // unchanged
        expect(result.description, equals('Test Description')); // unchanged
        expect(result.isCompleted, equals(false)); // unchanged ← hits the red line
        expect(result.createdAt, equals(testDate)); // unchanged
      });

      test('should update isCompleted when provided', () {
        final result = testTodo.copyWith(isCompleted: true);
        expect(result.isCompleted, isTrue);
      });

      // This specifically hits isCompleted ?? this.isCompleted
      test('should keep original isCompleted when not provided', () {
        final result = testTodo.copyWith(title: 'New Title'); // no isCompleted
        expect(result.isCompleted, equals(testTodo.isCompleted)); // falls back to this.isCompleted
      });
    });

    group('equality', () {
      test('two todos with same values should be equal', () {
        final todo2 = Todo(
          id: '1',
          title: 'Test Todo',
          description: 'Test Description',
          isCompleted: false,
          createdAt: testDate,
        );
        expect(testTodo, equals(todo2));
      });

      test('two todos with different values should not be equal', () {
        final todo2 = testTodo.copyWith(title: 'Different');
        expect(testTodo, isNot(equals(todo2)));
      });

      test('props should contain all fields', () {
        expect(testTodo.props, equals([
          '1',
          'Test Todo',
          'Test Description',
          false,
          testDate,
        ]));
      });
    });

  });
}