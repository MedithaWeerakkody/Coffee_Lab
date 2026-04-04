import 'package:flutter_test/flutter_test.dart';

// Simple class to test validation methods without Firebase initialization
class AuthValidator {
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
}

void main() {
  group('Authentication Validation Tests', () {
    late AuthValidator validator;

    setUp(() {
      validator = AuthValidator();
    });

    test('Password validation tests', () {
      // Test weak passwords
      expect(validator.isValidPassword('12345'), false);
      expect(validator.isValidPassword('password'), false);
      expect(validator.isValidPassword('PASSWORD'), false);
      expect(validator.isValidPassword('Password'), false);
      expect(validator.isValidPassword('Password1'), false);

      // Test strong passwords
      expect(validator.isValidPassword('Password1!'), true);
      expect(validator.isValidPassword('MySecure123@'), true);
      expect(validator.isValidPassword('CoffeeLab2024#'), true);
    });

    test('Email validation tests', () {
      // Test invalid emails
      expect(validator.isValidEmail(''), false);
      expect(validator.isValidEmail('invalid'), false);
      expect(validator.isValidEmail('invalid@'), false);
      expect(validator.isValidEmail('@domain.com'), false);

      // Test valid emails
      expect(validator.isValidEmail('test@example.com'), true);
      expect(validator.isValidEmail('user.name@domain.co.uk'), true);
      expect(validator.isValidEmail('demo@cafeconnect.com'), true);
    });

    test('Password strength messages', () {
      String message = validator.getPasswordStrengthMessage('weak');
      expect(message.contains('at least 8 characters'), true);
      expect(message.contains('one uppercase letter'), true);
      expect(message.contains('one number'), true);
      expect(message.contains('one special character'), true);

      String strongMessage = validator.getPasswordStrengthMessage(
        'StrongPass123!',
      );
      expect(strongMessage, 'Strong password!');
    });

    test('Comprehensive password requirements', () {
      // Test all required components
      expect(validator.isValidPassword('Aa1!'), false); // Too short
      expect(
        validator.isValidPassword('Password123'),
        false,
      ); // No special char
      expect(validator.isValidPassword('password123!'), false); // No uppercase
      expect(validator.isValidPassword('PASSWORD123!'), false); // No lowercase
      expect(validator.isValidPassword('Password!'), false); // No number
      expect(validator.isValidPassword('MyStrongPass123!'), true); // Perfect
    });
  });
}
