import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/domain/repositories/todo_repository.dart';
import 'package:todo/presentation/bloc/todo_bloc.dart';
import 'package:todo/presentation/bloc/todo_event.dart';
import 'package:todo/presentation/screens/todo_screen.dart';
import 'core/di/injection_container.dart' as di;
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<TodoRepository>(
      create: (_) => sl<TodoRepository>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocProvider(
          create: (_) => sl<TodoBloc>()..add(LoadTodoEvent()),
          child: const TodoScreen(),
        ),
      ),
    );
  }
}
