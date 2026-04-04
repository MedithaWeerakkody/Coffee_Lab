import 'package:flutter/material.dart';
import '../services/AdminService.dart';
import '../../models/order.dart' as OrderModel;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService();
  Map<String, dynamic>? _stats;

  static const _brown = Color(0xFF3D1F1A);
  static const _brownLight = Color(0xFF7C3A2E);
  static const _cream = Color(0xFFF0C9B0);
  static const _bg = Color(0xFFF5F0EB);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _adminService.getDashboardStats();
    if (mounted) setState(() => _stats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: _cream,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.coffee, color: _cream, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Coffee lab',
              style: TextStyle(
                  color: _cream,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _cream.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Admin',
                style: TextStyle(color: _cream, fontSize: 12)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: _brownLight,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Text(
                'Good ${_greeting()}, Admin',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _brown,
                ),
              ),
              const Text(
                'Here\'s what\'s happening today',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Stats grid
              if (_stats == null)
                const Center(child: CircularProgressIndicator(color: _brownLight))
              else ...[
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.6,
                  children: [
                    _StatCard(
                      label: 'Today\'s revenue',
                      value:
                          '\$${(_stats!['todayRevenue'] as double).toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      color: const Color(0xFF2E7D32),
                      bg: const Color(0xFFE8F5E9),
                    ),
                    _StatCard(
                      label: 'Orders today',
                      value: '${_stats!['todayOrders']}',
                      icon: Icons.receipt_long,
                      color: _brownLight,
                      bg: const Color(0xFFFDF0EA),
                    ),
                    _StatCard(
                      label: 'Pending orders',
                      value: '${_stats!['pendingOrders']}',
                      icon: Icons.pending_actions,
                      color: const Color(0xFFE65100),
                      bg: const Color(0xFFFFF3E0),
                    ),
                    _StatCard(
                      label: 'Reservations',
                      value: '${_stats!['todayReservations']}',
                      icon: Icons.event_seat,
                      color: const Color(0xFF1565C0),
                      bg: const Color(0xFFE3F2FD),
                    ),
                  ],
                ),

                // Low stock alert
                if ((_stats!['lowStockItems'] as int) > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFFCA28), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: Color(0xFFE65100), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          '${_stats!['lowStockItems']} item(s) running low on stock',
                          style: const TextStyle(
                            color: Color(0xFF856404),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 24),

              // Recent orders
              const Text(
                'Recent orders',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _brown,
                ),
              ),
              const SizedBox(height: 12),

              StreamBuilder<List<OrderModel.Order>>(
                stream: _adminService.getRecentOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: _brownLight));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const _EmptyState(message: 'No orders yet');
                  }
                  final orders = snapshot.data!;
                  return Column(
                    children: orders
                        .map((order) => _OrderCard(
                              order: order,
                              onStatusChange: (status) => _adminService
                                  .updateOrderStatus(order.id, status),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration:
                BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel.Order order;
  final Function(String) onStatusChange;

  const _OrderCard({required this.order, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF3D1F1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.items.length} item(s) · \$${order.total.toStringAsFixed(2)}',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          _StatusBadge(status: order.status),
        ],
      ),
    );
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
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status,
          style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ),
    );
  }
}