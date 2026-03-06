import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/presentation/bloc/todo_bloc.dart';
import 'package:todo/presentation/bloc/todo_state.dart';
import 'package:todo/presentation/screens/add_todo_sheet.dart';
import 'package:todo/presentation/screens/todo_item.dart';
import 'filter_tabs.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: FilterTabs(),
        ),
      ),
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            TodoLoading() =>
              const Center(child: CupertinoActivityIndicator()),
            TodoLoaded(:final todos, :final activeCount, :final completedCount) =>
              todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No todos yet!',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _StatsBar(
                          active: activeCount,
                          completed: completedCount,
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: todos.length,
                            itemBuilder: (context, index) {
                              return TodoItem(todo: todos[index]);
                            },
                          ),
                        ),
                      ],
                    ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddToSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddToSheet(BuildContext context) {
    final bloc = context.read<TodoBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const AddTodoSheet(),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final int active;
  final int completed;

  const _StatsBar({required this.active, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text('Active: $active',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Text('Done: $completed',
              style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
