import 'package:flutter/cupertino.dart';
import 'package:todo/domain/entities/todo.dart';

class Box<T> {
  final T value;
  Box(this.value);
}


void main(){
  final intBox = Box<int>(45);
  final stringBox = Box('Hello world');

  debugPrint("int box = ${intBox.value} ${intBox.runtimeType}");
  debugPrint("int box = ${stringBox.value} ${stringBox.runtimeType}");

}

abstract class Repository<T, ID> {
  Future<T?> findById(ID id);
  Future<List<T>> findAll();
  Future<T> save(T entity);
  Future<void> delete(ID id);
}


class TodoRepositoryImpl implements Repository<Todo, String> {

  @override
  Future<void> delete(String id) async{
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<Todo>> findAll() async{
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  Future<Todo?> findById(String id) async{
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  Future<Todo> save(Todo entity) async{
    // TODO: implement save
    throw UnimplementedError();
  }

}







