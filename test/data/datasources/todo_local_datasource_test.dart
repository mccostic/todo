import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/data/datasources/todo_local_datasource.dart';
import 'package:todo/data/models/todo_model.dart';



@GenerateMocks([SharedPreferences])
import 'todo_local_datasource_test.mocks.dart';
void main(){
  late TodoLocalDatasourceImpl datasource;
  late MockSharedPreferences mockPrefs;

  setUp((){
    mockPrefs = MockSharedPreferences();
    datasource = TodoLocalDatasourceImpl(sharedPreferences:mockPrefs);
  });
  final testDate = DateTime(2024, 1, 1);
  final testModel = TodoModel(
    id: '1',
    title: 'Test Todo',
    description: 'Test Description',
    isCompleted: false,
    createdAt: testDate,
  );
  const todoKey = 'TODOS';

  group('getTodos',(){
    test('should return list of todos when data exists', () async{
      // Arrange — simulate stored JSON strings
      when(mockPrefs.getStringList(todoKey)).thenReturn([testModel.toJsonString()]);
      //Act
      final result = await datasource.getTodos();
      //Assert
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
      expect(result.first.title, equals('Test Todo'));
      verify(mockPrefs.getStringList(todoKey)).called(1);
    });

    test('should return empty list when no data exists', () async{
      when(mockPrefs.getStringList(any)).thenReturn([]);

      final result = await datasource.getTodos();
      expect(result, isEmpty);
      verify(mockPrefs.getStringList(todoKey)).called(1);
    });

    // This test specifically covers the null branch (the red line)
    test('should return empty list when SharedPreferences returns null', () async {
      // Arrange — simulate first time app runs, nothing stored yet
      when(mockPrefs.getStringList('TODOS')).thenReturn(null); // ← null

      // Act
      final result = await datasource.getTodos();

      // Assert — the null check returns []
      expect(result, isEmpty);
      expect(result, equals([]));
    });

  });

  group('saveTodos', (){
    test('should save list of todos to shared preferences', () async{
      when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);
      await datasource.saveTodos([]);
      verify(mockPrefs.setStringList(todoKey, [])).called(1);
    });
  });
}