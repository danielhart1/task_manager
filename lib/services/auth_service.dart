import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Getters
  User? get currentUser => _auth.currentUser;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Email/Password Registration with Name and Surname
  Future<UserCredential> signUp(String firstName, String surname, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'surname': surname,
        'email': email,
      });

      // Update display name in FirebaseAuth
      await userCredential.user!.updateDisplayName("$firstName $surname");

      await sendVerificationEmail();
      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    }
  }

  // Email/Password Login
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Authentication returned null user',
        );
      }

      notifyListeners();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    }
  }

  // Update User Name
  Future<void> updateUserName(String firstName, String surname) async {
    if (currentUser == null) return;

    try {
      // Update FirebaseAuth display name
      await currentUser!.updateDisplayName("$firstName $surname");

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'firstName': firstName,
        'surname': surname,
      });

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  // Fetch user details from Firestore
  Future<Map<String, dynamic>?> getUserDetails() async {
    if (currentUser == null) return null;
    final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data();
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _parseAuthError(e);
    }
  }

  // Email Verification
  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint("Error sending verification email: $e");
    }
  }

  // Error Handling
  String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Enter a valid email';
      case 'weak-password':
        return 'Password must be 6+ characters';
      case 'user-not-found':
        return 'No account found';
      case 'wrong-password':
        return 'Incorrect password';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
