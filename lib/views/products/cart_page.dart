import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simple_app/models/cart.dart';
import 'package:simple_app/models/user.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/payments/bill_page.dart';

class CartPage extends StatefulWidget {
  final User user;
  const CartPage({super.key, required this.user});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  List<CartItem> selectedItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          final isSelected = selectedItems.contains(item);

                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Image.network(
                                "${MyConfig.servername}/simple_app/assets/products/${item.productFilename}",
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error, size: 80),
                              ),
                              title: Text(
                                item.productTitle ?? 'No Title',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'RM ${(item.productPrice ?? 0).toStringAsFixed(2)} x ${item.quantity}',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove,
                                            color: Colors.red),
                                        onPressed: item.quantity! > 1
                                            ? () => updateQuantity(
                                                item, item.quantity! - 1)
                                            : null,
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add,
                                            color: Colors.green),
                                        onPressed: () => updateQuantity(
                                            item, item.quantity! + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedItems.add(item);
                                    } else {
                                      selectedItems.remove(item);
                                    }
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: RM ${calculateSelectedTotalPrice().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 253, 157, 2),
                minimumSize: const Size(120, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: selectedItems.isNotEmpty
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillScreen(
                            totalprice: calculateSelectedTotalPrice(),
                            selectedItems: selectedItems.map((item) {
                              return {
                                'product_id': item.productId,
                                'product_name': item.productTitle,
                                'quantity': item.quantity,
                                'price': item.productPrice,
                              };
                            }).toList(),
                            checkoutType: "product",
                            user: widget.user,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text(
                'Checkout',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadCartItems() async {
    try {
      final response = await http.post(
        Uri.parse("${MyConfig.servername}/simple_app/api/load_cart2.php"),
        body: {'user_id': widget.user.userid},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            cartItems = (responseData['cart_items'] as List)
                .map((item) => CartItem.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${MyConfig.servername}/simple_app/api/update_cart_quantity.php'),
        body: {
          'user_id': widget.user.userid,
          'product_id': item.productId.toString(),
          'quantity': newQuantity.toString(),
        },
      );

      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          item.quantity = newQuantity;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quantity updated to $newQuantity'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to update quantity: ${responseData['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  double calculateSelectedTotalPrice() {
    return selectedItems.fold(
        0.0,
        (total, item) =>
            total + (item.productPrice ?? 0) * (item.quantity ?? 0));
  }
}
