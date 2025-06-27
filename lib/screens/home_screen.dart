import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? firstName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser; // Check if user is authenticated

    if (user == null) {
      // User is not authenticated, handle accordingly
      print("User is not authenticated");
      return;
    } else {
      print("Authenticated user UID: ${user.uid}");
    }

    // Fetch user details from your AuthService
    final userDetails = await authService.getUserDetails();

    if (mounted) {
      setState(() {
        firstName = userDetails?['firstName'] ?? 'User';
      });
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final User? user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${firstName ?? 'User'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: user != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Open Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildTaskList('open'),
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Completed Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildTaskList('completed'),
                  const SizedBox(height: 20),
                ],
              ),
            )
          : const Center(child: Text('Not authenticated', style: TextStyle(fontSize: 16, color: Colors.red))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
