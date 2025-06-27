import 'package:flutter/material.dart';
import 'task_form_screen.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: TaskFormScreen(), // Directly showing the task form
    );
  }
}
