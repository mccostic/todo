import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/presentation/bloc/todo_bloc.dart';
import 'package:todo/presentation/bloc/todo_event.dart';

class AddTodoSheet  extends StatefulWidget{
  const AddTodoSheet({super.key});

  @override
  State<StatefulWidget> createState() => _AddTodoSheetState();


}


class _AddTodoSheetState extends State<AddTodoSheet>{
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(){
    if(_formKey.currentState?.validate() ?? false){
      context.read<TodoBloc>().add(AddTodoEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim()));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
      left: 16,
      right: 16,
      top: 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [

            Text('New Todo',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Todo'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

}