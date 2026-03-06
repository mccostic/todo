import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;

  const TodoItem({required this.todo, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TodoBloc, TodoState, bool>(
      selector: (state) {
        return switch (state) {
          TodoLoaded(:final togglingIds) => togglingIds.contains(todo.id),
          _ => false,
        };
      },
      builder: (context, isToggling) {
        return Dismissible(
          key: ValueKey(todo.id),
          direction:
              isToggling ? DismissDirection.none : DismissDirection.endToStart,
          onDismissed: (_) {
            context.read<TodoBloc>().add(DeleteTodoEvent(id: todo.id));
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: AbsorbPointer(
            absorbing: isToggling,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isToggling ? 0.6 : 1.0,
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      // Checkbox or loader
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: isToggling
                              ? const CupertinoActivityIndicator()
                              : Checkbox(
                                  value: todo.isCompleted,
                                  onChanged: (_) {
                                    context
                                        .read<TodoBloc>()
                                        .add(ToggleTodoEvent(id: todo.id));
                                  },
                                ),
                        ),
                      ),
                      // Title & description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              todo.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: todo.isCompleted ? Colors.grey : null,
                              ),
                            ),
                            if (todo.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  todo.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Date
                      Text(
                        _formatDate(todo.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
