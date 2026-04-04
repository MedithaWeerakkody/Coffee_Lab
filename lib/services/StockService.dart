import 'package:cloud_firestore/cloud_firestore.dart';

class StockItem {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final double lowStockThreshold;

  StockItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.lowStockThreshold,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  double get stockPercent =>
      (quantity / (lowStockThreshold * 5)).clamp(0.0, 1.0);

  factory StockItem.fromMap(Map<String, dynamic> map) {
    return StockItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'kg',
      lowStockThreshold: (map['lowStockThreshold'] ?? 10.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
    };
  }
}

class StockService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<StockItem>> getAllStock() {
    return _firestore.collection('stock').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) =>
                StockItem.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  Future<void> addStockItem(StockItem item) async {
    await _firestore.collection('stock').add(item.toMap());
  }

  Future<void> updateStockItem(String id, StockItem item) async {
    await _firestore.collection('stock').doc(id).update(item.toMap());
  }

  Future<void> updateQuantity(String id, double quantity) async {
    await _firestore
        .collection('stock')
        .doc(id)
        .update({'quantity': quantity});
  }

  Future<void> deleteStockItem(String id) async {
    await _firestore.collection('stock').doc(id).delete();
  }

  // Seed default stock items if collection is empty
  Future<void> seedDefaultStock() async {
    final snap = await _firestore.collection('stock').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final defaults = [
      StockItem(id: '', name: 'Coffee Beans', quantity: 35, unit: 'kg', lowStockThreshold: 10),
      StockItem(id: '', name: 'Milk', quantity: 12, unit: 'L', lowStockThreshold: 10),
      StockItem(id: '', name: 'Flour', quantity: 4, unit: 'kg', lowStockThreshold: 10),
      StockItem(id: '', name: 'Sugar', quantity: 18, unit: 'kg', lowStockThreshold: 8),
      StockItem(id: '', name: 'Eggs', quantity: 24, unit: 'pcs', lowStockThreshold: 20),
      StockItem(id: '', name: 'Butter', quantity: 8, unit: 'kg', lowStockThreshold: 5),
      StockItem(id: '', name: 'Cream', quantity: 6, unit: 'L', lowStockThreshold: 5),
      StockItem(id: '', name: 'Chocolate', quantity: 3, unit: 'kg', lowStockThreshold: 5),
    ];
    for (final item in defaults) {
      await _firestore.collection('stock').add(item.toMap());
    }
  }
}
