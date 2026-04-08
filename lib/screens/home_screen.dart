import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../services/cart_provider.dart';
import '../services/auth_service.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Initialize services and controllers
  final MenuService _menuService = MenuService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Coffee',
    'Pastry',
    'Breakfast',
    'Dessert',
    'Salad',
    'Sandwich',
    'Beverage',
  ];

  @override
  void dispose() {
    // Dispose controller to prevent memory leaks
    _searchController.dispose();
    super.dispose();
  }

  // Handle user logout and navigate to authentication screen
  void _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE0E0E0,
      ), // Light grey background as per wireframe
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D4037), // Coffee-themed dark brown
        elevation: 0,
        title: const Text(
          'Coffee Lab',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Cart icon with item count badge
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () => Navigator.of(context).pushNamed('/cart'),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Logout menu
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with rounded design
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search menu items...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF5D4037)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF5D4037)),
                ),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),

          // Category selection chips
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) =>
                        setState(() => _selectedCategory = category),
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFF5D4037)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // StreamBuilder to fetch and display menu items from database
          Expanded(
            child: StreamBuilder<List<MenuItem>>(
              stream: _selectedCategory == 'All'
                  ? _menuService.getMenuItems()
                  : _menuService.getMenuItemsByCategory(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final menuItems = snapshot.data ?? [];
                final filteredItems = menuItems
                    .where(
                      (item) => item.name.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (filteredItems.isEmpty)
                  return const Center(child: Text('No items found'));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return MenuItemCard(
                      menuItem: filteredItems[index],
                      onAddToCart: () {
                        // Add item to global cart provider
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addItem(filteredItems[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${filteredItems[index].name} added'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }
}
