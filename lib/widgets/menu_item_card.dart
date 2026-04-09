import 'package:flutter/material.dart';

class MenuItemCard extends StatelessWidget {
  final dynamic menuItem;
  final VoidCallback onAddToCart;

  const MenuItemCard({
    Key? key,
    required this.menuItem,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // Matches the light cream background seen in the latest UI update
      color: const Color(0xFFFFF3E0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // --- Item Image Section ---
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                // Display the network image using the same URL used in the Cart screen
                child:
                    menuItem != null &&
                        menuItem.imageUrl != null &&
                        menuItem.imageUrl != ""
                    ? Image.network(
                        menuItem.imageUrl,
                        fit: BoxFit.cover,
                        // Show a loading indicator while the image is fetching
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                        // Fallback icon if the image URL is broken or fails to load
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.restaurant_menu,
                              color: Colors.orange,
                            ),
                      )
                    : const Icon(Icons.restaurant_menu, color: Colors.orange),
              ),
            ),
            const SizedBox(width: 16),

            // --- Item Details Section ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuItem != null ? menuItem.name.toString() : "Cafe Item",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    menuItem != null
                        ? "Rs. ${menuItem.price.toStringAsFixed(2)}"
                        : "Price N/A",
                    style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  ),
                ],
              ),
            ),

            // --- Cart Action Section ---
            IconButton(
              icon: const Icon(Icons.add_shopping_cart, color: Colors.orange),
              onPressed:
                  onAddToCart, // Executes the function passed from HomeScreen
            ),
          ],
        ),
      ),
    );
  }
}
