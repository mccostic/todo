import 'package:json_annotation/json_annotation.dart';

part 'create_todo_request.g.dart';

@JsonSerializable()
class CreateTodoRequest {
  final String title;
  final String description;

  const CreateTodoRequest({
    required this.title,
    required this.description,
  });

  factory CreateTodoRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTodoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateTodoRequestToJson(this);
}