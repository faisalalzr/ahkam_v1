import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign In
  Future<User?> signInWithEmailPassword(String email, String pass) async {
    try {
      // Sign in the user
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(email: email, password: pass);

      // Check if the user document exists
      final userDoc = await _firestore
          .collection('account')
          .doc(userCredential.user!.uid)
          .get();

      // If the user document doesn't exist, create it
      if (!userDoc.exists) {
        await _firestore
            .collection('account')
            .doc(userCredential.user!.uid)
            .set(
                {
              'uid': userCredential.user!.uid,
              'email': email,
            },
                SetOptions(
                    merge:
                        true)); // Use merge to avoid overwriting existing data
      }

      return userCredential.user; // Return the authenticated user
    } on FirebaseAuthException catch (e) {
      throw Exception('Authentication failed: ${e.message}');
    }
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign Up
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      // Create the user with the provided credentials
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Check if the user document exists
      final userDoc = await _firestore
          .collection('account')
          .doc(userCredential.user!.uid)
          .get();

      // If the user document doesn't exist, create it
      if (!userDoc.exists) {
        await _firestore
            .collection('account')
            .doc(userCredential.user!.uid)
            .set(
                {
              'uid': userCredential.user!.uid,
              'email': email,
            },
                SetOptions(
                    merge:
                        true)); // Use merge to avoid overwriting existing data
      }

      return userCredential.user; // Return the created user
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
