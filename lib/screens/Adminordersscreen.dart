import 'package:flutter/material.dart';
import '../services/AdminService.dart';
import '../../models/order.dart' as OrderModel;

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _adminService = AdminService();
  String _filter = 'All';

  static const _brown = Color(0xFF3D1F1A);
  static const _brownLight = Color(0xFF7C3A2E);
  static const _bg = Color(0xFFF5F0EB);

  final _filters = ['All', 'Pending', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Orders',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filters
                  .map((f) => GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _filter == f
                                ? _brown
                                : const Color(0xFFF5F0EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _filter == f
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Orders list
          Expanded(
            child: StreamBuilder<List<OrderModel.Order>>(
              stream: _adminService.getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF7C3A2E)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No orders found',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                var orders = snapshot.data!;
                if (_filter != 'All') {
                  orders = orders
                      .where((o) =>
                          o.status.toLowerCase() ==
                          _filter.toLowerCase())
                      .toList();
                }

                if (orders.isEmpty) {
                  return Center(
                    child: Text('No $_filter orders',
                        style: const TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (_, i) =>
                      _OrderDetailCard(
                        order: orders[i],
                        onStatusChange: (status) =>
                            _adminService.updateOrderStatus(
                                orders[i].id, status),
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  final OrderModel.Order order;
  final Function(String) onStatusChange;

  const _OrderDetailCard(
      {required this.order, required this.onStatusChange});

  static const _brown = Color(0xFF3D1F1A);
  static const _brownLight = Color(0xFF7C3A2E);

  void _showStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update order status',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _brown)),
            const SizedBox(height: 16),
            ...['Pending', 'Completed', 'Cancelled'].map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _statusIcon(s),
                title: Text(s,
                    style: const TextStyle(fontSize: 14)),
                trailing: order.status == s
                    ? const Icon(Icons.check,
                        color: Color(0xFF7C3A2E), size: 18)
                    : null,
                onTap: () {
                  onStatusChange(s);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFD4EDDA),
            child: Icon(Icons.check,
                color: Color(0xFF2D6A4F), size: 14));
      case 'pending':
        return const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFFFF3CD),
            child: Icon(Icons.access_time,
                color: Color(0xFF856404), size: 14));
      case 'cancelled':
        return const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFF8D7DA),
            child: Icon(Icons.close,
                color: Color(0xFF842029), size: 14));
      default:
        return const CircleAvatar(radius: 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _brown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.timestamp),
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
          ),

          // Items
          const Divider(height: 1, thickness: 0.5),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              children: order.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.name} x${item.quantity}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87),
                            ),
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4F1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _brown,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showStatusSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _brown,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Update status',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (status.toLowerCase()) {
      case 'completed':
        bg = const Color(0xFFD4EDDA);
        text = const Color(0xFF2D6A4F);
        break;
      case 'pending':
        bg = const Color(0xFFFFF3CD);
        text = const Color(0xFF856404);
        break;
      case 'cancelled':
        bg = const Color(0xFFF8D7DA);
        text = const Color(0xFF842029);
        break;
      default:
        bg = const Color(0xFFE2E3E5);
        text = const Color(0xFF383D41);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}