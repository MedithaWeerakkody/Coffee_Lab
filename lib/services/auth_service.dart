import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool get isSignedIn => _auth.currentUser != null;

  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final User? firebaseUser = result.user;
      if (firebaseUser == null) {
        return null;
      }

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;

        print('LOGGED IN UID: ${firebaseUser.uid}');
        print('FIRESTORE USER DATA: $data');
        print('ROLE FROM FIRESTORE: ${data['role']}');

        return AppUser(
          id: firebaseUser.uid,
          email: (data['email'] ?? firebaseUser.email ?? email.trim())
              .toString()
              .trim()
              .toLowerCase(),
          name: (data['name'] ?? firebaseUser.displayName ?? 'User')
              .toString()
              .trim(),
          role: (data['role'] ?? 'user').toString().trim().toLowerCase(),
        );
      } else {
        final AppUser newUser = AppUser(
          id: firebaseUser.uid,
          email: (firebaseUser.email ?? email.trim()).trim().toLowerCase(),
          name: (firebaseUser.displayName ?? 'User').trim(),
          role: 'user',
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(
              newUser.toMap(),
            );

        print('NO FIRESTORE USER DOC FOUND. CREATED DEFAULT USER DOC.');

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<AppUser?> registerWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        throw Exception('All fields are required');
      }

      if (!isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      if (!isValidPassword(password)) {
        throw Exception(getPasswordStrengthMessage(password));
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final User? firebaseUser = result.user;
      if (firebaseUser == null) {
        return null;
      }

      await firebaseUser.updateDisplayName(name.trim());

      final AppUser newUser = AppUser(
        id: firebaseUser.uid,
        email: email.trim().toLowerCase(),
        name: name.trim(),
        role: 'user',
      );

      await _firestore.collection('users').doc(firebaseUser.uid).set(
            newUser.toMap(),
          );

      print('REGISTERED USER DOC CREATED FOR UID: ${firebaseUser.uid}');

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('Registration error: $e');
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception(
        'An unexpected error occurred during registration. Please try again.',
      );
    }
  }

  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();

      if (data != null) {
        return (data['role'] ?? 'user').toString().trim().toLowerCase();
      }

      // Fallback: if there's no users doc, check the separate 'admins' collection
      // (some admin creation paths stored admins in 'admins' only).
      final adminDoc = await _firestore.collection('admins').doc(uid).get();
      if (adminDoc.exists) return 'admin';

      return 'user';
    } catch (e) {
      print('getUserRole error: $e');
      return 'user';
    }
  }

  Future<AppUser?> getUserData(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;

        return AppUser(
          id: uid,
          email: (data['email'] ?? '').toString(),
          name: (data['name'] ?? 'User').toString(),
          role: (data['role'] ?? 'user').toString().trim().toLowerCase(),
        );
      }

      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email cannot be empty');
      }

      if (!isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      await _auth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('Reset password error: $e');
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return false;
    return true;
  }

  String getPasswordStrengthMessage(String password) {
    final List<String> issues = [];

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
      issues.add('one special character');
    }

    return issues.isEmpty
        ? 'Strong password!'
        : 'Password must contain: ${issues.join(', ')}';
  }

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