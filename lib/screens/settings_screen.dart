import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/theme_service.dart';
import './auth/login_screen.dart'; // Ensure this exists

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  File? _image;
  final picker = ImagePicker();
  String? _profileImageUrl;
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final user = _auth.currentUser;
  if (user != null) {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() {
          _profileImageUrl = doc.data()?['profileImageUrl'] ?? "";
          _nameController.text = doc.data()?['firstName'] ?? ""; // Load first name
          _surnameController.text = doc.data()?['surname'] ?? ""; // Load surname
        });
      }
    }
  }
}


  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final storageRef =
        FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');

    await storageRef.putFile(_image!);
    final downloadUrl = await storageRef.getDownloadURL();

    setState(() {
      _profileImageUrl = downloadUrl;
    });

    await _firestore.collection('users').doc(user.uid).update({
      'profileImageUrl': downloadUrl,
    });
  }

  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'firstName': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null &&
                        _profileImageUrl!.isNotEmpty
                    ? NetworkImage(_profileImageUrl!) as ImageProvider
                    : AssetImage('assets/default_avatar.png'),
              ),
            ),
            SizedBox(height: 16),

            // First Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "First Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),

            // Surname Field
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(
                labelText: "Surname",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveUserData,
              icon: Icon(Icons.save),
              label: Text("Save Changes"),
            ),
            SizedBox(height: 16),

            // Dark Mode Switch
            ListTile(
              title: Text("Dark Mode"),
              trailing: Switch(
                value: themeNotifier.isDarkMode,
                onChanged: (bool value) {
                  themeNotifier.toggleTheme(value);
                },
              ),
            ),
            Spacer(), // Pushes Sign Out button to the bottom

            // Sign Out Button
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: Icon(Icons.logout),
              label: Text("Sign Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
