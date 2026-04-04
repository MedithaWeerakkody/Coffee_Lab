import 'package:coffee_lab/screens/Role%20selection%20screen.dart';
import 'package:coffee_lab/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/Role selection screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/history_screen.dart';
import 'screens/Admin login screen.dart';
import 'screens/AdminMainScreen.dart';
import 'services/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    await Future.delayed(const Duration(milliseconds: 100));
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const CoffeeLab());
}

class CoffeeLab extends StatelessWidget {
  const CoffeeLab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MaterialApp(
        title: 'Coffee Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.brown,
          primaryColor: const Color(0xFF795548),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF795548),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF795548),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF795548),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF795548), width: 2),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/auth': (context) => const RoleSelectionScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/reservation': (context) => const ReservationScreen(),
          '/payment': (context) => const PaymentScreen(),
          '/history': (context) => const HistoryScreen(),
          '/admin-login': (context) => const AdminLoginScreen(),
          '/admin': (context) => AdminMainScreen(),
        },
      ),
    );
  }
}