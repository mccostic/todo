// lib/presentation/widgets/todo_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  // ValueKey ensures Flutter correctly identifies this widget
  // when list order changes — preserves animations and state
  const TodoItem({required this.todo, super.key});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Swipe to delete
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        context.read<TodoBloc>().add(DeleteTodoEvent(id:todo.id));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) {
              context.read<TodoBloc>().add(ToggleTodoEvent(id:todo.id));
            },
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              // Strike through if completed
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isCompleted ? Colors.grey : null,
            ),
          ),
          subtitle: todo.description.isNotEmpty
              ? Text(todo.description)
              : null,
          trailing: Text(
            _formatDate(todo.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}