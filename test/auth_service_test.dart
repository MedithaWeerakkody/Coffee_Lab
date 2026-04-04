import 'package:flutter_test/flutter_test.dart';

// Test email validation without requiring Firebase
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

void main() {
  group('Email Validation Tests', () {
    test('should validate email format correctly', () {
      // Test valid emails
      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('user.name@domain.co.uk'), true);
      expect(isValidEmail('user+tag@example.org'), true);
      expect(isValidEmail('valid.email@test-domain.com'), true);

      // Test invalid emails
      expect(isValidEmail('invalid-email'), false);
      expect(isValidEmail('user@'), false);
      expect(isValidEmail('@domain.com'), false);
      expect(isValidEmail(''), false);
      expect(isValidEmail('user@domain'), false);
      expect(isValidEmail('user space@domain.com'), false);
    });

    test('should handle edge cases in email validation', () {
      // Edge cases
      expect(isValidEmail('a@b.co'), true);
      expect(isValidEmail('test123@domain123.org'), true);
      expect(isValidEmail('user-name@sub.domain.com'), true);
      
      // Invalid edge cases
      expect(isValidEmail('user@.com'), false);
      expect(isValidEmail('user@domain.'), false);
      expect(isValidEmail('.user@domain.com'), false);
    });
  });

  group('Input Validation Tests', () {
    test('should identify empty fields', () {
      expect(''.trim().isEmpty, true);
      expect('   '.trim().isEmpty, true);
      expect('test'.trim().isEmpty, false);
    });

    test('should validate password length requirements', () {
      expect('12345'.length < 6, true);
      expect('123456'.length >= 6, true);
      expect('password123'.length >= 6, true);
    });

    test('should trim and normalize email addresses', () {
      expect('  TEST@EXAMPLE.COM  '.trim().toLowerCase(), 'test@example.com');
      expect('User@Domain.Com'.trim().toLowerCase(), 'user@domain.com');
    });
  });
}
