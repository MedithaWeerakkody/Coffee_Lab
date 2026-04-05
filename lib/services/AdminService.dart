import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as OrderModel;
import '../models/reservation.dart';
import '../models/menu_item.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Admin secret code (only authorised staff know this) ─────────────────
  static const String _adminSecretCode = "COFFEEADMIN2025";

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

  // ─── Create a new admin account (Auth + Firestore) ────────────────────────
  Future<bool> createAdminAccount({
    required String email,
    required String password,
    required String fullName,
    required String authCode,
  }) async {
    // 1. Verify the secret code
    if (authCode != _adminSecretCode) {
      throw Exception("Invalid admin authorization code.");
    }

    // 2. Create the user in Firebase Authentication
    UserCredential userCred;
    try {
      userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Optionally update display name
      await userCred.user?.updateDisplayName(fullName.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e.code));
    }

    // 3. Add a document to the 'admins' collection
    final uid = userCred.user!.uid;
    final adminData = {
      'uid': uid,
      'email': email.trim(),
      'fullName': fullName.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'admin',
    };
    await _firestore.collection('admins').doc(uid).set(adminData);

    // Also create/update a corresponding document in the 'users' collection
    // so AuthService.getUserRole and sign-in logic see the admin role.
    final userDoc = {
      'id': uid,
      'email': email.trim(),
      'name': fullName.trim(),
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('users').doc(uid).set(userDoc);

    return true;
  }

  // Helper to translate Firebase Auth errors
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An admin account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters with letters, numbers & symbols.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Failed to create admin account. Try again.';
    }
  }

  // ─── (Optional) Seed the first admin if collection is empty ──────────────
  Future<void> seedFirstAdmin() async {
    final snapshot = await _firestore.collection('admins').limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // already exists

    try {
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "admin@coffeelab.com",
        password: "Admin123!",
      );
      final seedAdminData = {
        'uid': userCred.user!.uid,
        'email': 'admin@coffeelab.com',
        'fullName': 'Master Admin',
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'admin',
      };
      await _firestore.collection('admins').doc(userCred.user!.uid).set(seedAdminData);

      // Mirror to users collection so sign-in route recognizes admin role
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'id': userCred.user!.uid,
        'email': 'admin@coffeelab.com',
        'name': 'Master Admin',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Default admin created: admin@coffeelab.com / Admin123!');
    } catch (e) {
      print('Admin seeding error: $e');
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

      // Provide all expected keys used by the dashboard UI.
      // Some UIs expect `todayOrders` and `lowStockItems` keys.
      return {
        'todayRevenue': todayRevenue,
        'totalOrders': allOrders.length,
        'todayOrders': todayOrders.length,
        'pendingOrders': pendingOrders,
        'todayReservations': todayReservations,
        // lowStockItems not tracked here yet; default to 0 to avoid crashes.
        'lowStockItems': 0,
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