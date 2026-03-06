import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/data/models/todo_model.dart';

abstract class TodoLocalDatasource {
  Future<List<TodoModel>> getTodos();

  Future<void> saveTodos(List<TodoModel> todos);
}

class TodoLocalDatasourceImpl implements TodoLocalDatasource{
  static const _key = 'TODOS';
  final SharedPreferences sharedPreferences;

  TodoLocalDatasourceImpl({required this.sharedPreferences});


  @override
  Future<List<TodoModel>> getTodos() async{
    final jsonStringList = sharedPreferences.getStringList(_key);

    if(jsonStringList == null) return [];

    return jsonStringList.map((jsonString) =>
        TodoModel.fromJsonString(jsonString)).toList();

  }

  @override
  Future<void> saveTodos(List<TodoModel> todos) async{
    final jsonStringList  = todos.map((todo) =>
        todo.toJsonString()).toList();
    debugPrint("saveTodos: $jsonStringList");
    await sharedPreferences.setStringList(_key, jsonStringList);
  }

}