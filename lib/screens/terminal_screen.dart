import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ussd_launcher/ussd_launcher.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/business_profile_provider.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../widgets/product_form_modal.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class _AppLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback? onResumed;

  _AppLifecycleObserver({this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed?.call();
    }
  }
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<CartItem> _cart = [];
  String _searchQuery = '';
  List<String> _ussdMessages = [];

  double get _cartTotal => _cart.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

  @override
  void initState() {
    super.initState();
    // Set up USSD message listener
    UssdLauncher.setUssdMessageListener(_onUssdMessageReceived);
  }

  void _onUssdMessageReceived(String message) {
    if (mounted) {
      setState(() {
        _ussdMessages.add(message);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    final existingIndex = _cart.indexWhere((i) => i.product.id == product.id);
    if (existingIndex != -1) {
      setState(() {
        _cart[existingIndex].quantity++;
      });
    } else {
      setState(() {
        _cart.add(CartItem(product: product));
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  Future<void> _processPayment(BuildContext context, String paymentMethod) async {
    if (_cart.isEmpty) return;

    if (paymentMethod == 'MTN MoMo') {
      await _startMoMoPayment(context);
    } else {
      _completeTransaction(context, paymentMethod, null);
    }
  }

  Future<void> _startMoMoPayment(BuildContext context) async {
    // Request CALL_PHONE permission first
    PermissionStatus status = await Permission.phone.request();
    
    if (!mounted) return;
    
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone permission is required to use MTN MoMo')),
      );
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
      return;
    }
    
    // Check if accessibility is enabled (required for background USSD)
    bool isAccessibilityEnabled = await UssdLauncher.isAccessibilityEnabled();
    
    if (!mounted) return;
    
    if (!isAccessibilityEnabled) {
      // Ask user to enable accessibility
      bool? enableAccessibility = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Accessibility Required'),
          content: const Text('Please enable accessibility for this app in Settings, then come back and tap MTN MoMo again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      
      if (!mounted) return;
      
      if (enableAccessibility == true) {
        await UssdLauncher.openAccessibilitySettings();
      }
    } else {
      // Accessibility enabled! Show dialog to collect customer phone!
      final phoneController = TextEditingController();
      
      if (!mounted) return;
      
      String? customerPhone = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quick Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Customer Phone'),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: '077xxxxxxx',
                ),
              ),
              const SizedBox(height: 16),
              Text('Amount (UGX): ${NumberFormat("#,###").format(_cartTotal)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, phoneController.text),
              child: const Text('Send', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
      
      if (!mounted) return;
      
      if (customerPhone != null && customerPhone.isNotEmpty) {
        // Now run multi-session USSD!
        try {
          // Get available SIM cards
          List<Map<String, dynamic>> simCards = await UssdLauncher.getSimCards();
          int selectedSlotIndex = simCards.isNotEmpty ? (simCards[0]['slotIndex'] as int? ?? 0) : 0;
          
          // Format customer phone (remove leading 0, add 256 if needed)
          String formattedPhone = customerPhone;
          if (formattedPhone.startsWith('0')) {
            formattedPhone = '256${formattedPhone.substring(1)}';
          }
          
          // Format amount as integer
          String formattedAmount = _cartTotal.toInt().toString();
          
          // List of options to send: [phone, amount, 1 (confirm)]
          List<String> ussdOptions = [formattedPhone, formattedAmount, '1'];
          
          // Run multi-session USSD
          await UssdLauncher.multisessionUssd(
            code: '*165*3#',
            slotIndex: selectedSlotIndex,
            options: ussdOptions,
          );
          
          if (mounted) {
            _completeTransaction(context, 'MTN MoMo', customerPhone);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Error: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _completeTransaction(
    BuildContext context,
    String paymentMethod,
    String? customerPhone,
  ) async {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final businessProfileProvider =
        Provider.of<BusinessProfileProvider>(context, listen: false);
    
    // Calculate savings if savings are activated
    double? savingsDeducted;
    if (businessProfileProvider.profile?.savingsPercentage != null &&
        businessProfileProvider.profile!.savingsPercentage! > 0) {
      savingsDeducted = (_cartTotal * businessProfileProvider.profile!.savingsPercentage!) / 100;
      // Add savings to total savings
      await businessProfileProvider.addSavings(savingsDeducted);
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      total: _cartTotal,
      paymentMethod: paymentMethod,
      customerPhone: customerPhone,
      items: _cart
          .map((item) => TransactionItem(
                productId: item.product.id,
                quantity: item.quantity,
                priceAtTime: item.product.price,
              ))
          .toList(),
      savingsDeducted: savingsDeducted,
    );

    for (var cartItem in _cart) {
      final product = cartItem.product;
      product.stockQuantity -= cartItem.quantity;
      await productProvider.updateProduct(product);
    }

    await transactionProvider.addTransaction(transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction completed successfully!')),
      );
      _clearCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TERMINAL'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'SEARCH NAME OR BARCODE',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          List<Product> products = productProvider.products;
          if (_searchQuery.isNotEmpty) {
            products = productProvider.searchProducts(_searchQuery);
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No products added yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const _StockPlaceholder()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('ADD FIRST PRODUCT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 120,
                            child: product.imagePath != null
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: Image.file(
                                      File(product.imagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                                  ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'UGX ${NumberFormat('#,###').format(product.price)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () => _addToCart(product),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC107),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      minimumSize: const Size(double.infinity, 32),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Icon(Icons.add, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_cart.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.3),
                        blurRadius: 5,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _cart.length,
                              itemBuilder: (context, index) {
                                final item = _cart[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFFFFC107),
                                    child: Text(item.quantity.toString()),
                                  ),
                                  title: Text(item.product.name),
                                  subtitle: Text(
                                      'UGX ${NumberFormat('#,###').format(item.product.price)}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () => _removeFromCart(index),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  Text(
                                    'UGX ${NumberFormat('#,###').format(_cartTotal)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () => _showPaymentOptions(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                ),
                                child: const Text('Quick Payment',
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'SELECT PAYMENT METHOD',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _processPayment(context, 'MTN MoMo');
                },
                icon: const Icon(Icons.phone_android, size: 28),
                label: const Text(
                  'MTN Mobile Money',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7931E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _processPayment(context, 'Cash');
                },
                icon: const Icon(Icons.money, size: 28),
                label: const Text(
                  'Cash',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockPlaceholder extends StatelessWidget {
  const _StockPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock')),
      body: const Center(
        child: Text('Please use the Stock tab from bottom navigation'),
      ),
    );
  }
}
