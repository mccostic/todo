
import 'package:flutter_test/flutter_test.dart';
import 'package:todo/data/models/todo_model.dart';
import 'package:todo/domain/entities/todo.dart';

void main(){
  final testDate = DateTime(2024, 1, 1);
  final testModel = TodoModel(
    id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    createdAt: testDate,
  );

  final testJson = {
    'id': '1',
    'title': 'Test Todo',
    'description': 'Test Description',
    'isCompleted': false,
    'createdAt': testDate.toIso8601String(),
  };

  group('TodoModel', (){
    test('should be a subclass of Todo', (){
      expect(testModel, isA<Todo>());
    });
    
    group('fromJson', (){
      test('should return a valid model from JSON', (){
        final result = TodoModel.fromJson(testJson);
        expect(result.id, equals('1'));
        expect(result.title, equals('Test Todo'));
        expect(result.description, equals('Test Description'));
        expect(result.isCompleted, equals(false));
        expect(result.createdAt, equals(testDate));
      });
    });

    group('toJson', (){
      test('should return a valid JSON map', (){
        final result = testModel.toJson();
        expect(result, testJson);
      });
    });

    group('fromEntity', (){
      test('should create model from entity', (){
        final entity = Todo(
          id: '1',
          title: 'Test Todo',
          description: 'Test Description',
          isCompleted: false,
          createdAt: testDate
        );

        final model = TodoModel.fromEntity(entity);

        expect(model.id, equals(entity.id));
        expect(model.title, equals(entity.title));
        expect(model.description, equals(entity.description));
        expect(model.isCompleted, equals(entity.isCompleted));
        expect(model.createdAt, equals(entity.createdAt));
      });
    });

    group('toJsonString and fromJsonString', (){
      test('should correctly serialize and deserialize', (){
        final jsonString = testModel.toJsonString();
        final result = TodoModel.fromJsonString(jsonString);

        expect(result.id, equals(testModel.id));
        expect(result.title, equals(testModel.title));
        expect(result.description, equals(testModel.description));
        expect(result.isCompleted, equals(testModel.isCompleted));
        expect(result.createdAt, equals(testModel.createdAt));
      });
    });
  });
}