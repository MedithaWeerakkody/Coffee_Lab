import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_navigation.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _selectedPaymentMethod = 'card';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    // Basic validation for card payment
    if (_selectedPaymentMethod == 'card' &&
        !_formKey.currentState!.validate()) {
      return;
    }

    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
      _showErrorSnackBar('Your cart is empty');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final user = _authService.currentUser;
      if (user != null) {
        final orderId = await _orderService.createOrder(
          userId: user.uid,
          items: cart.items,
          total: cart.totalAmount,
        );

        if (orderId != null && mounted) {
          cart.clearCart();
          _showSuccessDialog();
        } else {
          _showErrorSnackBar('Failed to create order');
        }
      } else {
        _showErrorSnackBar('User not authenticated');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Order Placed!'),
        content: const Text('Your delicious coffee order has been received.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home', (route) => false),
            child: const Text(
              'Back to Home',
              style: TextStyle(color: Color(0xFF5D4037)),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final brownColor = const Color(0xFF5D4037);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E0E0), // Wireframe background
      appBar: AppBar(
        backgroundColor: brownColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Payment', style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.name} x${item.quantity}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              'Rs. ${(item.price * item.quantity).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(
                      height: 24,
                      thickness: 1,
                      color: Colors.black54,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total :',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rs. ${cart.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

              // 2. Payment Method Selector (Radio Buttons)
              Row(
                children: [
                  Radio<String>(
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    activeColor: Colors.black,
                    onChanged: (val) =>
                        setState(() => _selectedPaymentMethod = val!),
                  ),
                  const Text('Credit Card'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'cash',
                    groupValue: _selectedPaymentMethod,
                    activeColor: Colors.black,
                    onChanged: (val) =>
                        setState(() => _selectedPaymentMethod = val!),
                  ),
                  const Text('Cash'),
                ],
              ),

              const SizedBox(height: 10),

              // 3. Conditional Content: Card Form OR Cash Message
              if (_selectedPaymentMethod == 'card') ...[
                const Text(
                  'Card Information',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildTextField(_nameController, 'Cardholder Name'),
                const SizedBox(height: 12),
                _buildTextField(
                  _cardNumberController,
                  'Card Number',
                  isNumber: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_expiryController, 'Expiry Data'),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildTextField(
                        _cvvController,
                        'CVV',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                _buildActionButton(
                  'Pay Rs. ${cart.totalAmount.toStringAsFixed(2)}',
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'You will pay in cash when you pick your order',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                _buildActionButton('Place Order'),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }

  // Helper Widget for TextFields to match wireframe style
  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5D4037)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  // Helper Widget for the big brown button
  Widget _buildActionButton(String label) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D4037),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
