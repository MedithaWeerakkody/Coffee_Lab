import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as OrderModel;
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new order
  Future<String?> createOrder({
    required String userId,
    required List<CartItem> items,
    required double total,
  }) async {
    try {
      final orderData = {
        'userId': userId,
        'items': items.map((item) => item.toMap()).toList(),
        'total': total,
        'status': 'Pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      DocumentReference docRef = await _firestore
          .collection('orders')
          .add(orderData);

      return docRef.id;
    } catch (e) {
      print('Create order error: $e');
      return null;
    }
  }

  // Get user orders with error handling
  Stream<List<OrderModel.Order>> getUserOrders(String userId) {
    try {
      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            var orders = snapshot.docs
                .map((doc) => OrderModel.Order.fromMap({...doc.data(), 'id': doc.id}))
                .toList();
            
            // Sort in memory instead of using composite index
            orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            return orders;
          })
          .handleError((error) {
            print('Error fetching orders: $error');
            return <OrderModel.Order>[];
          });
    } catch (e) {
      print('getUserOrders error: $e');
      // Return empty stream on error
      return Stream.value(<OrderModel.Order>[]);
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': status});
    } catch (e) {
      print('Update order status error: $e');
    }
  }
}
