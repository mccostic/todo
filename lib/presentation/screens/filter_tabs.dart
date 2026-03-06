import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';

class FilterTabs extends StatelessWidget {
  const FilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TodoBloc, TodoState, TodoFilter>(
      selector: (state) {
        return switch (state) {
          TodoLoaded(:final filter) => filter,
          _ => TodoFilter.all,
        };
      },
      builder: (context, currentFilter) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: TodoFilter.values.map((filter) {
            final isSelected = currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(filter.name.toUpperCase()),
                selected: isSelected,
                onSelected: (_) {
                  context
                      .read<TodoBloc>()
                      .add(FilterTodosEvent(filter: filter));
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
