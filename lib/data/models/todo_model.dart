import 'dart:convert';

import '../../domain/entities/todo.dart';

class TodoModel extends Todo{
  const TodoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.createdAt
});

  // Create model from JSON map (coming from storage)
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      isCompleted: (json['is_completed'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  // Convert model to JSON map (going to storage)
  Map<String,dynamic> toJson(){
    return {
      'id': id,
      'title':title,
      'description':description,
      'isCompleted':isCompleted,
      'createdAt':createdAt.toIso8601String(),
    };
  }

  factory TodoModel.fromJsonString(String source) =>
      TodoModel.fromJson(json.decode(source));

  String toJsonString() => json.encode(toJson());

  factory TodoModel.fromEntity(Todo todo){
    return TodoModel(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        isCompleted: todo.isCompleted,
        createdAt: todo.createdAt);
  }

}