import 'dart:convert';

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_app/models/products.dart';
import 'package:simple_app/myconfig.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/views/products/edit_product.dart';

class ProductDetailPage extends StatefulWidget {
  final Myproduct product;
  final String userId; // Pass user ID from the parent widget

  const ProductDetailPage(
      {super.key, required this.product, required this.userId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Myproduct currentProduct;
  int quantityToBuy = 1;

  @override
  void initState() {
    super.initState();
    currentProduct = widget.product; // Initialize with the passed product
  }

  @override
  Widget build(BuildContext context) {
    final double pageWidth = MediaQuery.of(context).size.width;
    final double pageHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              // Navigate to edit page
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (content) => EditProduct(
                    product: widget.product,
                  ),
                ),
              );
              setState(() {}); // Refresh the UI after returning
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "${MyConfig.servername}/simple_app/assets/products/${currentProduct.productFilename}",
                width: pageWidth,
                height: pageHeight / 3,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/Not Found Image.png",
                  width: pageWidth,
                  height: pageHeight / 3,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentProduct.productTitle.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  
                  "${(currentProduct.productSold?.toInt() ?? 0)} Sold",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Type: ${currentProduct.productType}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: \RM${(currentProduct.productPrice?.toDouble() ?? 0.0).toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Stock Left: ${currentProduct.productStock ?? 0}",
              style: TextStyle(
                fontSize: 16,
                color: (currentProduct.productStock ?? 0) > 0
                    ? Colors.black
                    : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            // Product Description
            const Text('Description:', style: TextStyle(fontSize: 18)),
            Text(
              currentProduct.productDescription.toString(),
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            //Product Rating
            RatingBar.readOnly(
              initialRating: currentProduct.productRating?.toDouble() ?? 0.0,
              isHalfAllowed: true,
              alignment: Alignment.centerLeft,
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              emptyColor: const Color.fromARGB(255, 113, 113, 113),
              filledColor: const Color.fromARGB(255, 238, 250, 0),
              halfFilledColor: const Color.fromARGB(255, 238, 250, 0),
              halfFilledIcon: Icons.star_half,
              maxRating: 5,
              size: 25,
            ),
            // Product Date Added
            Text(
              "Added on: ${DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.parse(currentProduct.productDate.toString()))}",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Quantity Selector
            Row(
              children: [
                const Text(
                  "Quantity:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantityToBuy > 1
                            ? () {
                                setState(() {
                                  quantityToBuy--;
                                });
                              }
                            : null,
                      ),
                      Text(
                        "$quantityToBuy",
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed:
                            quantityToBuy < (currentProduct.productStock ?? 0)
                                ? () {
                                    setState(() {
                                      quantityToBuy++;
                                    });
                                  }
                                : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add to Cart Button
            ElevatedButton.icon(
              onPressed: (currentProduct.productStock ?? 0) > 0
                  ? () {
                      addToCart(widget.userId, currentProduct.productId!,
                          quantityToBuy);
                    }
                  : null,
              icon: const Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
              ),
              label: const Text(
                "Add to Cart",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: (currentProduct.productStock ?? 0) > 0
                    ? Colors.orange
                    : Colors.grey,
                minimumSize: Size(pageWidth, 50), // Full width button
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('${MyConfig.servername}/simple_app/api/addtocart.php'),
        body: {
          'user_id': userId,
          'product_id': productId,
          'quantity': quantity.toString()
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Product added to cart successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to add product: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Server error. Please try again later.')),
        );
      }
    } catch (error) {
      print('User ID: ' + userId.toString());
      print('Product ID: ' +
          productId.toString() +
          ' Quantity: ' +
          quantity.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }
}
