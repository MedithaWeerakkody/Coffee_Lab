import 'package:flutter/material.dart';
import '../services/AdminService.dart';
import '../../models/menu_item.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final _adminService = AdminService();
  String _selectedCategory = 'All';

  static const _brown = Color(0xFF3D1F1A);
  static const _brownLight = Color(0xFF7C3A2E);
  static const _bg = Color(0xFFF5F0EB);

  final _categories = [
    'All', 'Coffee', 'Pastry', 'Breakfast',
    'Dessert', 'Salad', 'Sandwich', 'Beverage'
  ];

  void _showAddEditDialog({MenuItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MenuItemForm(
        item: item,
        onSave: (newItem) async {
          if (item == null) {
            await _adminService.addMenuItem(newItem);
          } else {
            await _adminService.updateMenuItem(item.id, newItem);
          }
        },
      ),
    );
  }

  void _confirmDelete(MenuItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Remove "${item.name}" from the menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _adminService.deleteMenuItem(item.id);
              if (mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Menu management',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            color: Colors.white,
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: _categories
                  .map((c) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = c),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: _selectedCategory == c
                                ? _brown
                                : const Color(0xFFF5F0EB),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            c,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _selectedCategory == c
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Menu items list
          Expanded(
            child: StreamBuilder<List<MenuItem>>(
              stream: _adminService.getAllMenuItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF7C3A2E)));
                }

                var items = snapshot.data ?? [];
                if (_selectedCategory != 'All') {
                  items = items
                      .where((i) => i.category == _selectedCategory)
                      .toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.menu_book_outlined,
                            color: Colors.grey, size: 48),
                        const SizedBox(height: 12),
                        Text('No items in $_selectedCategory',
                            style:
                                const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddEditDialog(),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _MenuItemCard(
                    item: items[i],
                    onEdit: () => _showAddEditDialog(item: items[i]),
                    onDelete: () => _confirmDelete(items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: _brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuItemCard(
      {required this.item,
      required this.onEdit,
      required this.onDelete});

  static const _brown = Color(0xFF3D1F1A);
  static const _brownLight = Color(0xFF7C3A2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl.startsWith('http')
                ? Image.network(
                    item.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _brown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F0EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                            fontSize: 10, color: _brownLight),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _brownLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined,
                    color: _brownLight, size: 20),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFFF5F0EB),
      child: const Icon(Icons.coffee,
          color: Color(0xFF7C3A2E), size: 28),
    );
  }
}

// ─── Add / Edit form ──────────────────────────────────────────────────────────

class _MenuItemForm extends StatefulWidget {
  final MenuItem? item;
  final Future<void> Function(MenuItem) onSave;

  const _MenuItemForm({this.item, required this.onSave});

  @override
  State<_MenuItemForm> createState() => _MenuItemFormState();
}

class _MenuItemFormState extends State<_MenuItemForm> {
  late TextEditingController _name;
  late TextEditingController _price;
  late TextEditingController _description;
  late TextEditingController _imageUrl;
  String _category = 'Coffee';
  bool _saving = false;

  static const _brown = Color(0xFF3D1F1A);
  static const _brownLight = Color(0xFF7C3A2E);

  final _categories = [
    'Coffee', 'Pastry', 'Breakfast',
    'Dessert', 'Salad', 'Sandwich', 'Beverage'
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.item?.name ?? '');
    _price = TextEditingController(
        text: widget.item?.price.toStringAsFixed(2) ?? '');
    _description =
        TextEditingController(text: widget.item?.description ?? '');
    _imageUrl =
        TextEditingController(text: widget.item?.imageUrl ?? '');
    _category = widget.item?.category ?? 'Coffee';
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _price.text.isEmpty) return;
    setState(() => _saving = true);
    try {
      final newItem = MenuItem(
        id: widget.item?.id ?? '',
        name: _name.text.trim(),
        price: double.tryParse(_price.text) ?? 0.0,
        description: _description.text.trim(),
        imageUrl: _imageUrl.text.trim(),
        category: _category,
      );
      await widget.onSave(newItem);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item == null ? 'Add menu item' : 'Edit menu item',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _brown,
            ),
          ),
          const SizedBox(height: 16),
          _field(_name, 'Item name', Icons.fastfood_outlined),
          const SizedBox(height: 10),
          _field(_price, 'Price (USD)', Icons.attach_money,
              keyboard: TextInputType.number),
          const SizedBox(height: 10),
          _field(_description, 'Description', Icons.description_outlined),
          const SizedBox(height: 10),
          _field(_imageUrl, 'Image URL', Icons.image_outlined),
          const SizedBox(height: 10),

          // Category dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F4F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                items: _categories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _category = v ?? 'Coffee'),
              ),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      widget.item == null ? 'Add item' : 'Save changes',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Icon(icon, color: _brownLight, size: 18),
        filled: true,
        fillColor: const Color(0xFFF8F4F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brownLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 14),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _description.dispose();
    _imageUrl.dispose();
    super.dispose();
  }
}