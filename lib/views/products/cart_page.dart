import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/models/cart.dart';

class CartPage extends StatefulWidget {
  final String userId;

  const CartPage({super.key, required this.userId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  late double PageWidth, PageHeight;
  bool isLoading = true;

  int curpage = 1;
  int numofpage = 1;
  int itemsPerPage = 10; // Adjust this to set the number of items per page
  var color;
  int numofresult = 0;

  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      loadCartItems();
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    PageHeight = MediaQuery.of(context).size.height;
    PageWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : Expanded(
                child: Column(
                    children: [
                      SizedBox(
                        height: PageHeight * 0.05,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: numofpage,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            color = (curpage == index + 1)
                                ? Colors.red
                                : Colors.black;
                            return TextButton(
                              onPressed: () {
                                setState(() {
                                  curpage = index + 1;
                                });
                                loadCartItems(); // Reload data for the selected page
                              },
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(color: color, fontSize: 18),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
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
                                ),
                                title: Text(
                                  item.productTitle ?? 'No Title',
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'RM ${item.productPrice?.toStringAsFixed(2)} x ${item.quantity}',
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
                                        Text('${item.quantity}',
                                            style: const TextStyle(fontSize: 16)),
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
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    removeItemFromCart(item);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: RM ${cartItems.fold(0.0, (total, item) => total + (item.productPrice ?? 0) * (item.quantity ?? 0))}',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 253, 157, 2),
                minimumSize: const Size(120, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              onPressed: cartItems.isNotEmpty
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Proceed to Checkout')),
                      );
                    }
                  : null,
              child: const Text('Checkout', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadCartItems() async {
    try {
      final items = await fetchCartItems();
      setState(() {
        cartItems = items;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart items: $error')),
      );
    }
  }

  Future<List<CartItem>> fetchCartItems() async {
    if (widget.userId.isEmpty) {
      throw Exception('User ID is missing');
    }

    try {
      final response = await http.post(
        Uri.parse(
            "${MyConfig.servername}/simple_app/api/load_cart2.php?pageno=$curpage&limit=$itemsPerPage"),
        body: {
          'user_id': widget.userId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          // Set pagination variables
          numofpage = int.tryParse(responseData['numofpage'].toString()) ?? 1;
          numofresult =
              int.tryParse(responseData['numberofresult'].toString()) ?? 0;

          // Map cart items to CartItem objects
          return (responseData['cart_items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
        } else {
          throw Exception(
              'Failed to load cart items: ${responseData['message']}');
        }
      } else {
        throw Exception(
            'Failed to load cart items: Server returned status ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to load cart items: $error');
    }
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${MyConfig.servername}/simple_app/api/update_cart_quantity.php'),
        body: {
          'user_id': widget.userId,
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

  Future<void> removeItemFromCart(CartItem item) async {
    try {
      final response = await http.post(
        Uri.parse('${MyConfig.servername}/simple_app/api/remove_cart_item.php'),
        body: {
          'user_id': widget.userId,
          'product_id': item.productId.toString(),
        },
      );

      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          cartItems.remove(item);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item removed from cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to remove item: ${responseData['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }
}
