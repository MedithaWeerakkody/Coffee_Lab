import 'package:flutter_test/flutter_test.dart';
import 'package:coffee_lab/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('Password validation tests', () {
      // Test weak passwords
      expect(authService.isValidPassword('12345'), false);
      expect(authService.isValidPassword('password'), false);
      expect(authService.isValidPassword('PASSWORD'), false);
      expect(authService.isValidPassword('Password'), false);
      expect(authService.isValidPassword('Password1'), false);

      // Test strong passwords
      expect(authService.isValidPassword('Password1!'), true);
      expect(authService.isValidPassword('MySecure123@'), true);
      expect(authService.isValidPassword('CoffeeLab2024#'), true);
    });

    test('Email validation tests', () {
      // Test invalid emails
      expect(authService.isValidEmail(''), false);
      expect(authService.isValidEmail('invalid'), false);
      expect(authService.isValidEmail('invalid@'), false);
      expect(authService.isValidEmail('@domain.com'), false);

      // Test valid emails
      expect(authService.isValidEmail('test@example.com'), true);
      expect(authService.isValidEmail('user.name@domain.co.uk'), true);
      expect(authService.isValidEmail('demo@cafeconnect.com'), true);
    });

    test('Password strength messages', () {
      String message = authService.getPasswordStrengthMessage('weak');
      expect(message.contains('at least 8 characters'), true);
      expect(message.contains('one uppercase letter'), true);
      expect(message.contains('one number'), true);
      expect(message.contains('one special character'), true);

      String strongMessage = authService.getPasswordStrengthMessage(
        'StrongPass123!',
      );
      expect(strongMessage, 'Strong password!');
    });

    test('Firebase auth service initialization', () {
      // Auth service should be properly initialized
      expect(authService, isNotNull);
      expect(authService.currentUser, isNull); // No user signed in initially
      expect(authService.isSignedIn, false);
    });
  });
}
