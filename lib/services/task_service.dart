import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

 Future<void> addTask(Task task) async {
  final user = _auth.currentUser;
  if (user == null) {
    print("No user is signed in!");  // Debugging
    return;
  }

  try {
    await _firestore.collection('users')
        .doc(user.uid)
        .collection('tasks')
        .add(task.toMap());

    print("Task added to Firestore!");
  } catch (e) {
    print("Failed to add task: $e");
  }
}




  Stream<List<Task>> getTasks() {
  final user = _auth.currentUser;
  if (user == null) {
    print("❌ No user found in getTasks!");
    return const Stream.empty();
  }

  return _firestore
      .collection('users')
      .doc(user.uid)
      .collection('tasks')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final tasks = snapshot.docs
            .map((doc) => Task.fromMap(doc.id, doc.data()))
            .toList();
        print("✅ Loaded ${tasks.length} tasks");
        return tasks;
      });
}


  Future<void> updateTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
