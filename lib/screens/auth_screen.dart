// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // User interface
import 'AdminMainScreen.dart'; // Admin interface 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  void _navigateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4E342E),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF4E342E)),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _LoginPage(onNavigate: _navigateToPage),
                _RegisterPage(onNavigate: _navigateToPage),
                _ResetPasswordPage(onNavigate: _navigateToPage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Global Text Field Widget
Widget _buildTextField(
  String hint,
  IconData icon, {
  bool isPassword = false,
  bool obscureText = false,
  VoidCallback? onToggleVisibility,
  TextEditingController? controller,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword ? obscureText : false,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: onToggleVisibility,
            )
          : null,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    ),
  );
}

// --- LoginPage Implementation ---
class _LoginPage extends StatefulWidget {
  final Function(int) onNavigate;
  const _LoginPage({required this.onNavigate});

  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Modified Login Logic with Role-Based Navigation
  void _login() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        // Checking user role for redirection
        if (user.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminMainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 50),
          _buildLogo(),
          const SizedBox(height: 30),
          const Text(
            'Welcome back!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 40),
          _buildTextField('Email', Icons.email_outlined, controller: _emailController),
          const SizedBox(height: 20),
          _buildTextField(
            'Password',
            Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            controller: _passwordController,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => widget.onNavigate(2),
              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : _buildPrimaryButton('Sign in', _login),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => widget.onNavigate(1),
            child: const Text("Don't have an account? Sign UP", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- RegisterPage Implementation ---
class _RegisterPage extends StatefulWidget {
  final Function(int) onNavigate;
  const _RegisterPage({required this.onNavigate});

  @override
  State<_RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<_RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Modified Register Logic
  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
      if (user != null && mounted) {
        // Regular users navigate to Home screen after registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 50),
          _buildLogo(),
          const SizedBox(height: 30),
          const Text(
            'Create Account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 40),
          _buildTextField('Full Name', Icons.person_outline, controller: _nameController),
          const SizedBox(height: 20),
          _buildTextField('Email Address', Icons.email_outlined, controller: _emailController),
          const SizedBox(height: 20),
          _buildTextField(
            'Password',
            Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            controller: _passwordController,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Confirm Password',
            Icons.lock_outline,
            isPassword: true,
            obscureText: _obscureConfirmPassword,
            onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            controller: _confirmPasswordController,
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : _buildPrimaryButton('Create Account', _register),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => widget.onNavigate(0),
            child: const Text("Already have an account? Sign in", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- ResetPasswordPage Implementation ---
class _ResetPasswordPage extends StatefulWidget {
  final Function(int) onNavigate;
  const _ResetPasswordPage({required this.onNavigate});

  @override
  State<_ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<_ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent! Check your email.'), backgroundColor: Colors.green),
        );
        widget.onNavigate(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            _buildLogo(),
            const SizedBox(height: 30),
            const Text(
              'Reset Password',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text('Enter Your email to receive a reset link', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            _buildTextField('Email Address', Icons.email_outlined, controller: _emailController),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _buildPrimaryButton('Send Reset Link', _resetPassword),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => widget.onNavigate(0),
              child: const Text("Remember your password? Sign in", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLogo() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Image.asset(
      'assets/images/app_icon.png',
      height: 80,
      width: 80,
      errorBuilder: (c, e, s) => const Icon(Icons.coffee, size: 50, color: Color(0xFF4E342E)),
    ),
  );
}