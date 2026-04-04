import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  AuthService() {
    try {
      // Initialize Firebase services - required for authentication
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      print('Firebase Auth and Firestore initialized successfully');
    } catch (e) {
      print('Firebase initialization error: $e');
      throw Exception('Firebase services are not available. Please check your internet connection and try again.');
    }
  }

  // Get current user
  User? get currentUser {
    return _auth.currentUser;
  }

  // Auth change user stream
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      
      if (result.user != null) {
        // Try to get user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
        
        if (userDoc.exists) {
          return AppUser.fromMap(userDoc.data() as Map<String, dynamic>);
        } else {
          // If user document doesn't exist, create one
          AppUser newUser = AppUser(
            id: result.user!.uid,
            email: result.user!.email ?? email.trim().toLowerCase(),
            name: result.user!.displayName ?? 'User',
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
      String errorMessage = _getAuthErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Register with email and password
  Future<AppUser?> registerWithEmailPassword(
      String email, String password, String name) async {
    try {
      print('Starting registration for email: $email');
      
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        throw Exception('All fields are required');
      }

      if (!isValidPassword(password)) {
        throw Exception(getPasswordStrengthMessage(password));
      }

      if (!isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      print('Creating user with Firebase Auth...');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (result.user != null) {
        print('User created successfully, updating profile...');
        // Update the user's display name
        await result.user!.updateDisplayName(name.trim());

        AppUser newUser = AppUser(
          id: result.user!.uid,
          email: email.trim().toLowerCase(),
          name: name.trim(),
        );

        print('Saving user data to Firestore...');
        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        print('Registration completed successfully');
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error: ${e.code} - ${e.message}');
      String errorMessage = _getAuthErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      print('Registration error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('An unexpected error occurred during registration. Please try again.');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      // Validate email
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      if (!isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getAuthErrorMessage(e.code);
      throw Exception(errorMessage);
    } catch (e) {
      print('Reset password error: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Get user data
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
      print('Get user data error: $e');
      return null;
    }
  }

  // Check if user is signed in
  bool get isSignedIn {
    return _auth.currentUser != null;
  }

  // Email validation
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Enhanced password validation
  bool isValidPassword(String password) {
    // Must be at least 8 characters
    if (password.length < 8) return false;
    
    // Must contain at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    
    // Must contain at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    
    // Must contain at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    
    // Must contain at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    
    return true;
  }

  // Get password strength feedback
  String getPasswordStrengthMessage(String password) {
    List<String> issues = [];
    
    if (password.length < 8) {
      issues.add('at least 8 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      issues.add('one uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      issues.add('one lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      issues.add('one number');
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      issues.add('one special character (!@#\$%^&*etc.)');
    }
    
    if (issues.isEmpty) {
      return 'Strong password!';
    } else {
      return 'Password must contain: ${issues.join(', ')}';
    }
  }

  // Get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
