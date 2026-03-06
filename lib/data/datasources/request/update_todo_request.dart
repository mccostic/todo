import 'package:json_annotation/json_annotation.dart';

part 'update_todo_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateTodoRequest {
  final String? title;
  final String? description;

  @JsonKey(name: 'is_completed')
  final bool? isCompleted;

  const UpdateTodoRequest({
    this.title,
    this.description,
    this.isCompleted,
  });

  factory UpdateTodoRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTodoRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTodoRequestToJson(this);
}