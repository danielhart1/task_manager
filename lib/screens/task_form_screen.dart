import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({Key? key}) : super(key: key);

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'Normal'; // Default Priority

  // Save task to Firestore
 Future<void> _saveTask() async {
  if (_formKey.currentState!.validate() && _dueDate != null) {
    final id = const Uuid().v4(); // Generate unique ID
    final task = Task(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate!,
      priority: _priority,
      status: 'open', // default status
      createdAt: DateTime.now(),
    );

    // Save task to Firestore
    try {
      print("Saving task with ID: $id");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('tasks')
          .doc(id)
          .set(task.toMap());

      print("Task saved successfully.");
      Navigator.pop(context); // Go back after saving
    } catch (e) {
      print("Error saving task: $e");
    }
  } else if (_dueDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a deadline')),
    );
  }
}

Widget _buildTaskList(String status) {
  final userId = FirebaseAuth.instance.currentUser?.uid; // Get userId

  if (userId == null) {
    return const Center(child: Text('Not authenticated'));
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users') // Add 'users' collection for user-specific data
        .doc(userId) // Use authenticated user's UID
        .collection('tasks')
        .where('status', isEqualTo: status)
        .orderBy('dueDate')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No tasks found.'));
      }

      final tasks = snapshot.data!.docs;
      print("Fetched ${tasks.length} tasks for status: $status");

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(task['title']),
              subtitle: Text('Due: ${task['dueDate'].toString().split('T')[0]}'),
              trailing: Text(task['priority']),
            ),
          );
        },
      );
    },
  );
}

  // Pick the due date from the calendar
  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
              validator: (value) => value!.isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_dueDate == null
                  ? 'Pick a deadline'
                  : 'Deadline: ${_dueDate!.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDueDate,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              items: ['Low', 'Normal', 'High'].map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTask,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
