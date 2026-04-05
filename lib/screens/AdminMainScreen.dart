import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Admindashboardscreen.dart';
import 'Adminordersscreen.dart';
import 'Adminmenuscreen.dart';
import 'AdminStockScreen.dart';
import 'Adminreservationsscreen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  static const _brown = Color(0xFF3D1F1A);
  static const _brownLight = Color(0xFF7C3A2E);
  static const _cream = Color(0xFFF0C9B0);

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminOrdersScreen(),
    const AdminMenuScreen(),
    const AdminStockScreen(),
    const AdminReservationsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Orders',
    'Menu',
    'Stock',
    'Reservations',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: _brown,
        foregroundColor: _cream,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/auth');
              }
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Reservations',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: _brown,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
