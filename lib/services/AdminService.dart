import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as OrderModel;
import '../models/reservation.dart';
import '../models/menu_item.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Check if current user is admin ───────────────────────────────────────
  Future<bool> isAdmin(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('admins').doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('isAdmin error: $e');
      return false;
    }
  }

  // ─── Dashboard stats ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final now = DateTime.now();
      final todayStart =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      final ordersSnap = await _firestore.collection('orders').get();
      final allOrders = ordersSnap.docs;

      final todayOrders = allOrders.where((doc) {
        final data = doc.data();
        return (data['timestamp'] ?? 0) >= todayStart;
      }).toList();

      double todayRevenue = 0;
      for (var doc in todayOrders) {
        todayRevenue += (doc.data()['total'] ?? 0.0).toDouble();
      }

      final pendingOrders = allOrders.where((doc) {
        return doc.data()['status'] == 'Pending';
      }).length;

      final reservationsSnap =
          await _firestore.collection('reservations').get();
      final todayReservations = reservationsSnap.docs.where((doc) {
        final data = doc.data();
        return (data['date'] ?? 0) >= todayStart;
      }).length;

      return {
        'todayRevenue': todayRevenue,
        'totalOrders': allOrders.length,
        'pendingOrders': pendingOrders,
        'todayReservations': todayReservations,
      };
    } catch (e) {
      print('getDashboardStats error: $e');
      return {};
    }
  }

  // ─── All orders (admin) ───────────────────────────────────────────────────
  Stream<List<OrderModel.Order>> getAllOrders() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      var orders = snapshot.docs
          .map((doc) =>
              OrderModel.Order.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return orders;
    });
  }

  // ─── Update order status ──────────────────────────────────────────────────
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  // ─── Update reservation status ───────────────────────────────────────────
  Future<void> updateReservationStatus(String reservationId, String status) async {
    await _firestore
        .collection('reservations')
        .doc(reservationId)
        .update({'status': status});
  }

  // ─── All reservations (admin) ─────────────────────────────────────────────
  Stream<List<Reservation>> getAllReservations() {
    return _firestore.collection('reservations').snapshots().map((snapshot) {
      var reservations = snapshot.docs
          .map((doc) =>
              Reservation.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      reservations.sort((a, b) => b.date.compareTo(a.date));
      return reservations;
    });
  }

  // ─── Menu items (admin) ───────────────────────────────────────────────────
  Stream<List<MenuItem>> getMenuItems() {
    return _firestore.collection('menu').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) =>
                MenuItem.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Stream<List<MenuItem>> getAllMenuItems() {
    return getMenuItems();
  }

  Future<void> addMenuItem(MenuItem item) async {
    await _firestore.collection('menu').add(item.toMap());
  }

  Future<void> updateMenuItem(String id, MenuItem item) async {
    await _firestore.collection('menu').doc(id).update(item.toMap());
  }

  Future<void> deleteMenuItem(String id) async {
    await _firestore.collection('menu').doc(id).delete();
  }

  // ─── Recent orders for dashboard ─────────────────────────────────────────
  Stream<List<OrderModel.Order>> getRecentOrders({int limit = 5}) {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      var orders = snapshot.docs
          .map((doc) =>
              OrderModel.Order.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return orders.take(limit).toList();
    });
  }
}
