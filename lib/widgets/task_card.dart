import 'package:flutter/material.dart';
import '../../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({required this.task, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        title: Text(task.title),
        subtitle: Text(task.dueDate.toString()),
        value: task.status == 'completed',
        onChanged: (_) {},
      ),
    );
  }
}