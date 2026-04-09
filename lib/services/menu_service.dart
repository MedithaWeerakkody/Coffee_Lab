import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all menu items
  Stream<List<MenuItem>> getMenuItems() {
    return _firestore
        .collection('menu')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MenuItem.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Get menu items by category
  Stream<List<MenuItem>> getMenuItemsByCategory(String category) {
    return _firestore
        .collection('menu')
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MenuItem.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  // Add comprehensive real menu items
  Future<void> addRealMenuItems() async {
    final realMenuItems = [
      // ☕ COFFEE MENU
      MenuItem(
        id: '',
        name: 'Classic Espresso',
        price: 2.50,
        description: 'Rich, bold single shot of premium arabica beans',
        imageUrl:
            'https://images.unsplash.com/photo-1545665277-5937750a7c1b?w=800&q=80',
        category: 'Coffee',
      ),
      MenuItem(
        id: '',
        name: 'Cappuccino',
        price: 3.50,
        description:
            'Perfect blend of espresso, steamed milk, and velvety foam',
        imageUrl:
            'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=800&q=80',
        category: 'Coffee',
      ),
      MenuItem(
        id: '',
        name: 'Caffe Latte',
        price: 4.00,
        description: 'Smooth espresso with creamy steamed milk and light foam',
        imageUrl:
            'https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=800&q=80',
        category: 'Coffee',
      ),
      MenuItem(
        id: '',
        name: 'Americano',
        price: 3.00,
        description: 'Espresso shots diluted with hot water for a smooth taste',
        imageUrl:
            'https://images.unsplash.com/photo-1497636577773-f1231844b336?w=800&q=80',
        category: 'Coffee',
      ),
      MenuItem(
        id: '',
        name: 'Macchiato',
        price: 3.75,
        description: 'Espresso "marked" with a dollop of steamed milk foam',
        imageUrl:
            'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=800&q=80',
        category: 'Coffee',
      ),
      MenuItem(
        id: '',
        name: 'Mocha',
        price: 4.50,
        description:
            'Chocolate espresso drink with steamed milk and whipped cream',
        imageUrl:
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80',
        category: 'Coffee',
      ),
      MenuItem(
        id: '',
        name: 'Cold Brew',
        price: 3.75,
        description: 'Smooth, refreshing coffee brewed cold for 12 hours',
        imageUrl:
            'https://images.unsplash.com/photo-1517701550184-7e6a3eb56503?w=800&q=80',
        category: 'Coffee',
      ),
      MenuItem(
        id: '',
        name: 'Iced Latte',
        price: 4.25,
        description:
            'Chilled espresso with cold milk and ice, perfectly refreshing',
        imageUrl:
            'https://images.unsplash.com/photo-1534778101976-62847782c213?w=800&q=80',
        category: 'Coffee',
      ),

      // 🥐 PASTRIES & BREAKFAST
      MenuItem(
        id: '',
        name: 'Butter Croissant',
        price: 2.50,
        description: 'Flaky, buttery French pastry baked fresh daily',
        imageUrl:
            'https://images.unsplash.com/photo-1555507036-ab794f575db6?w=800&q=80',
        category: 'Pastry',
      ),
      MenuItem(
        id: '',
        name: 'Pain au Chocolat',
        price: 3.00,
        description: 'Croissant dough wrapped around rich dark chocolate',
        imageUrl:
            'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=800&q=80',
        category: 'Pastry',
      ),
      MenuItem(
        id: '',
        name: 'Almond Croissant',
        price: 3.50,
        description: 'Buttery croissant filled with sweet almond cream',
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80',
        category: 'Pastry',
      ),
      MenuItem(
        id: '',
        name: 'Blueberry Muffin',
        price: 2.75,
        description: 'Moist muffin bursting with fresh blueberries',
        imageUrl:
            'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=800&q=80',
        category: 'Pastry',
      ),
      MenuItem(
        id: '',
        name: 'Cinnamon Danish',
        price: 3.25,
        description: 'Sweet pastry with cinnamon swirl and vanilla glaze',
        imageUrl:
            'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=800&q=80',
        category: 'Pastry',
      ),
      MenuItem(
        id: '',
        name: 'Avocado Toast',
        price: 6.50,
        description:
            'Sourdough bread topped with smashed avocado, lime, and sea salt',
        imageUrl:
            'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=800&q=80',
        category: 'Breakfast',
      ),

      // 🍰 DESSERTS
      MenuItem(
        id: '',
        name: 'Chocolate Cake',
        price: 5.50,
        description: 'Decadent three-layer chocolate cake with rich frosting',
        imageUrl:
            'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&q=80',
        category: 'Dessert',
      ),
      MenuItem(
        id: '',
        name: 'New York Cheesecake',
        price: 6.00,
        description: 'Creamy classic cheesecake with graham cracker crust',
        imageUrl:
            'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=800&q=80',
        category: 'Dessert',
      ),
      MenuItem(
        id: '',
        name: 'Tiramisu',
        price: 5.75,
        description:
            'Italian dessert with coffee-soaked ladyfingers and mascarpone',
        imageUrl:
            'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=800&q=80',
        category: 'Dessert',
      ),
      MenuItem(
        id: '',
        name: 'Lemon Tart',
        price: 4.50,
        description: 'Tangy lemon curd in a buttery pastry shell',
        imageUrl:
            'https://images.unsplash.com/photo-1519915028121-7d3463d20b13?w=800&q=80',
        category: 'Dessert',
      ),
      MenuItem(
        id: '',
        name: 'Strawberry Shortcake',
        price: 5.25,
        description: 'Fresh strawberries with whipped cream and vanilla cake',
        imageUrl:
            'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=800&q=80',
        category: 'Dessert',
      ),

      // 🥗 SALADS & LIGHT MEALS
      MenuItem(
        id: '',
        name: 'Caesar Salad',
        price: 8.50,
        description:
            'Crisp romaine lettuce with parmesan, croutons, and Caesar dressing',
        imageUrl:
            'https://images.unsplash.com/photo-1551248429-40975aa4de74?w=800&q=80',
        category: 'Salad',
      ),
      MenuItem(
        id: '',
        name: 'Mediterranean Bowl',
        price: 9.50,
        description:
            'Quinoa, feta, olives, cucumber, tomatoes with lemon vinaigrette',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
        category: 'Salad',
      ),
      MenuItem(
        id: '',
        name: 'Grilled Chicken Salad',
        price: 10.50,
        description:
            'Mixed greens with grilled chicken, cherry tomatoes, and balsamic',
        imageUrl:
            'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800&q=80',
        category: 'Salad',
      ),
      MenuItem(
        id: '',
        name: 'Caprese Salad',
        price: 7.50,
        description:
            'Fresh mozzarella, tomatoes, basil with olive oil and balsamic',
        imageUrl:
            'https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=800&q=80',
        category: 'Salad',
      ),

      // 🥪 SANDWICHES
      MenuItem(
        id: '',
        name: 'Club Sandwich',
        price: 8.75,
        description: 'Turkey, bacon, lettuce, tomato on toasted bread',
        imageUrl:
            'https://images.unsplash.com/photo-1539252554453-80ab65ce3586?w=800&q=80',
        category: 'Sandwich',
      ),
      MenuItem(
        id: '',
        name: 'Grilled Panini',
        price: 7.50,
        description: 'Ham, mozzarella, tomato, and basil on grilled ciabatta',
        imageUrl:
            'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800&q=80',
        category: 'Sandwich',
      ),
      MenuItem(
        id: '',
        name: 'BLT',
        price: 6.50,
        description: 'Crispy bacon, fresh lettuce, and tomato on sourdough',
        imageUrl:
            'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=800&q=80',
        category: 'Sandwich',
      ),

      // 🧃 BEVERAGES
      MenuItem(
        id: '',
        name: 'Fresh Orange Juice',
        price: 3.50,
        description: 'Freshly squeezed orange juice, no pulp',
        imageUrl:
            'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=800&q=80',
        category: 'Beverage',
      ),
      MenuItem(
        id: '',
        name: 'Green Smoothie',
        price: 4.50,
        description: 'Spinach, banana, apple, and coconut water blend',
        imageUrl:
            'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=800&q=80',
        category: 'Beverage',
      ),
      MenuItem(
        id: '',
        name: 'Iced Tea',
        price: 2.50,
        description: 'Refreshing black tea served over ice with lemon',
        imageUrl:
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=800&q=80',
        category: 'Beverage',
      ),
    ];

    for (MenuItem item in realMenuItems) {
      await _firestore.collection('menu').add(item.toMap());
    }
  }

  // Legacy method name for compatibility
  Future<void> addSampleMenuItems() async {
    await addRealMenuItems();
  }
}
