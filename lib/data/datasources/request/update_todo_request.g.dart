// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_todo_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTodoRequest _$UpdateTodoRequestFromJson(Map<String, dynamic> json) =>
    UpdateTodoRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool?,
    );

Map<String, dynamic> _$UpdateTodoRequestToJson(UpdateTodoRequest instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'description': ?instance.description,
      'is_completed': ?instance.isCompleted,
    };
