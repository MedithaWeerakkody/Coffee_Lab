import 'package:flutter/material.dart';
import '../services/StockService.dart';

class AdminStockScreen extends StatefulWidget {
  const AdminStockScreen({super.key});

  @override
  State<AdminStockScreen> createState() => _AdminStockScreenState();
}

class _AdminStockScreenState extends State<AdminStockScreen> {
  final _stockService = StockService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<StockItem>>(
        stream: _stockService.getAllStock(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final stockItems = snapshot.data!;
          return ListView.builder(
            itemCount: stockItems.length,
            itemBuilder: (context, index) {
              final item = stockItems[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('${item.quantity} ${item.unit}'),
                trailing: item.isLowStock
                    ? const Icon(Icons.warning, color: Colors.red)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}