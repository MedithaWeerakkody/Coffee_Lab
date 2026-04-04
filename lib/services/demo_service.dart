import '../models/user.dart';
import '../models/menu_item.dart';
import '../models/order.dart';
import '../models/reservation.dart';
import '../models/cart_item.dart';

// Simple mock user for demo mode
class DemoFirebaseUser {
  String get uid => 'demo_user_123';
  String? get email => 'demo@cafeconnect.com';
  String? get displayName => 'Demo User';
}

class DemoService {
  static bool _isDemoMode = false;
  static AppUser? _demoUser;
  static DemoFirebaseUser? _demoFirebaseUser;
  
  static void enableDemoMode() {
    _isDemoMode = true;
    _demoUser = AppUser(
      id: 'demo_user_123',
      name: 'Demo User',
      email: 'demo@cafeconnect.com',
    );
    _demoFirebaseUser = DemoFirebaseUser();
  }
  
  static void disableDemoMode() {
    _isDemoMode = false;
    _demoUser = null;
    _demoFirebaseUser = null;
  }
  
  static bool get isDemoMode => _isDemoMode;
  static AppUser? get demoUser => _demoUser;
  static DemoFirebaseUser? get demoFirebaseUser => _demoFirebaseUser;
  
  // Demo menu items
  static List<MenuItem> getDemoMenuItems() {
    return [
      MenuItem(
        id: '1',
        name: 'Classic Espresso',
        description: 'Rich and bold espresso shot',
        price: 3.50,
        category: 'Coffee',
        imageUrl: 'assets/images/espresso.jpg',
      ),
      MenuItem(
        id: '2',
        name: 'Cappuccino',
        description: 'Espresso with steamed milk and foam',
        price: 4.25,
        category: 'Coffee',
        imageUrl: 'assets/images/cappuccino.jpg',
      ),
      MenuItem(
        id: '3',
        name: 'Latte',
        description: 'Smooth espresso with steamed milk',
        price: 4.50,
        category: 'Coffee',
        imageUrl: 'assets/images/latte.jpg',
      ),
      MenuItem(
        id: '4',
        name: 'Americano',
        description: 'Espresso with hot water',
        price: 3.75,
        category: 'Coffee',
        imageUrl: 'assets/images/americano.jpg',
      ),
      MenuItem(
        id: '5',
        name: 'Croissant',
        description: 'Buttery, flaky pastry',
        price: 2.75,
        category: 'Pastries',
        imageUrl: 'assets/images/croissant.jpg',
      ),
      MenuItem(
        id: '6',
        name: 'Blueberry Muffin',
        description: 'Fresh baked muffin with blueberries',
        price: 3.25,
        category: 'Pastries',
        imageUrl: 'assets/images/muffin.jpg',
      ),
      MenuItem(
        id: '7',
        name: 'Caesar Salad',
        description: 'Crisp romaine with caesar dressing',
        price: 8.50,
        category: 'Food',
        imageUrl: 'assets/images/caesar.jpg',
      ),
      MenuItem(
        id: '8',
        name: 'Grilled Sandwich',
        description: 'Grilled cheese and ham sandwich',
        price: 7.25,
        category: 'Food',
        imageUrl: 'assets/images/sandwich.jpg',
      ),
    ];
  }
  
  // Demo orders
  static List<Order> getDemoOrders() {
    final menuItems = getDemoMenuItems();
    return [
      Order(
        id: 'order_1',
        userId: 'demo_user_123',
        items: [
          CartItem(
            itemId: menuItems[0].id,
            name: menuItems[0].name,
            price: menuItems[0].price,
            imageUrl: menuItems[0].imageUrl,
            quantity: 2,
          ),
          CartItem(
            itemId: menuItems[4].id,
            name: menuItems[4].name,
            price: menuItems[4].price,
            imageUrl: menuItems[4].imageUrl,
            quantity: 1,
          ),
        ],
        total: 9.75,
        status: 'Completed',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Order(
        id: 'order_2',
        userId: 'demo_user_123',
        items: [
          CartItem(
            itemId: menuItems[2].id,
            name: menuItems[2].name,
            price: menuItems[2].price,
            imageUrl: menuItems[2].imageUrl,
            quantity: 1,
          ),
          CartItem(
            itemId: menuItems[5].id,
            name: menuItems[5].name,
            price: menuItems[5].price,
            imageUrl: menuItems[5].imageUrl,
            quantity: 1,
          ),
        ],
        total: 7.75,
        status: 'Pending',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
  
  // Demo reservations
  static List<Reservation> getDemoReservations() {
    return [
      Reservation(
        id: 'reservation_1',
        userId: 'demo_user_123',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '14:30',
        guests: 2,
        status: 'Confirmed',
      ),
      Reservation(
        id: 'reservation_2',
        userId: 'demo_user_123',
        date: DateTime.now().add(const Duration(days: 3)),
        time: '18:00',
        guests: 4,
        status: 'Pending',
      ),
    ];
  }
}
