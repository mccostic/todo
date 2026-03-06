
import 'package:equatable/equatable.dart';

class Todo extends Equatable{
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt});

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt}){
    return Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt);
  }

  /*
  Equatable uses these for == comparison
  Without this, two Todo object with same data would not be equal
  Why Equatable? Without it, todo1 == todo2 compares references, not values.
  BLoC uses equality to decide whether to emit a new state, so this matters a lot.
  */
  @override
  List<Object?> get props => [id, title, description, isCompleted, createdAt];
}