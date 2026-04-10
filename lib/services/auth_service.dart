import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  // Initialize Firebase authentication and Firestore instance
  AuthService() {
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      print('Firebase Auth and Firestore initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      throw Exception(
        'Firebase services are not available. Please check your internet connection.',
      );
    }
  }

  // Returns the currently logged-in user
  User? get currentUser {
    return _auth.currentUser;
  }

  // Stream to listen for authentication state changes (logged in/out)
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // Signs in an existing user with email and password
  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (result.user != null) {
        // Fetch user document from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (userDoc.exists) {
          return AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
        } else {
          // Create a new user document if it does not exist
          AppUser newUser = AppUser(
            id: result.user!.uid,
            email: result.user!.email ?? email.trim().toLowerCase(),
            name: result.user!.displayName ?? 'User',
            role: 'user', // Assigned default role as user
          );

          await _firestore
              .collection('users')
              .doc(result.user!.uid)
              .set(newUser.toMap());

          return newUser;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Registers a new user with email, password, and name
  Future<AppUser?> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Validate registration inputs
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        throw Exception('All fields are required');
      }

      if (!isValidPassword(password)) {
        throw Exception(getPasswordStrengthMessage(password));
      }

      // Create new user account in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (result.user != null) {
        await result.user!.updateDisplayName(name.trim());

        // Create user object and save to Firestore
        AppUser newUser = AppUser(
          id: result.user!.uid,
          email: email.trim().toLowerCase(),
          name: name.trim(),
          role: 'user', // Assigned default role as user
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      rethrow;
    }
  }

  // Sends a password reset email to the user
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) throw Exception('Email cannot be empty');
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      rethrow;
    }
  }

  // Signs out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out.');
    }
  }

  // Retrieves user profile data from Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        return AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Checks if a user is currently signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Helper method: Validates email format
  bool isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  // Helper method: Validates password strength
  bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }

  // Helper method: Provides feedback on password weakness
  String getPasswordStrengthMessage(String password) {
    List<String> issues = [];
    if (password.length < 8) issues.add('at least 8 characters');
    if (!RegExp(r'[A-Z]').hasMatch(password))
      issues.add('one uppercase letter');
    if (!RegExp(r'[a-z]').hasMatch(password))
      issues.add('one lowercase letter');
    if (!RegExp(r'[0-9]').hasMatch(password)) issues.add('one number');
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password))
      issues.add('one special character');

    return issues.isEmpty
        ? 'Strong password!'
        : 'Password must contain: ${issues.join(', ')}';
  }

  // Helper method: Maps Firebase error codes to user-friendly messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
