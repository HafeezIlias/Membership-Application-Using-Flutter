import 'dart:async';
import 'dart:convert';

import 'package:simple_app/models/user.dart';
import 'package:simple_app/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:simple_app/myconfig.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BillScreen extends StatefulWidget {
  final double totalprice;
  final User user;
  final String checkoutType; // "product" or "membership"
  final List<dynamic>? selectedItems; // For product checkout
  final Map<String, dynamic>? membershipDetails; // For membership checkout

  const BillScreen({
    super.key,
    required this.totalprice,
    required this.user,
    required this.checkoutType,
    this.selectedItems,
    this.membershipDetails,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  bool isLoading = true; // To manage the loading spinner
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    String url;

    if (widget.checkoutType == "product") {
  // Prepare a summary for the description
  String description;
  if (widget.selectedItems != null && widget.selectedItems!.isNotEmpty) {
    int totalItems = widget.selectedItems!.length;
    List<String> productNames = widget.selectedItems!
        .map((item) => item['product_name'] as String)
        .take(3) // Take the first 3 product names only
        .toList();
    String productSummary = productNames.join(", ");
    description =
        "Total Items: $totalItems. Products: $productSummary..."; // Add ellipsis if truncated
  } else {
    description = "Product Checkout";
  }
  // For product checkout
  url = '${MyConfig.servername}/simple_app/api/payment.php'
      '?userid=${widget.user.userid}'
      '&email=${widget.user.useremail}'
      '&phone=${widget.user.userphone}'
      '&name=${widget.user.username}'
      '&amount=${widget.totalprice.toStringAsFixed(2)}'
      '&selected_items=${Uri.encodeComponent(jsonEncode(widget.selectedItems))}'
      '&checkout_type=${widget.checkoutType}';
} else if (widget.checkoutType == "membership") {
      // For membership checkout
      if (widget.membershipDetails == null) {
        throw Exception("Membership details are missing for membership checkout.");
      }

      url = '${MyConfig.servername}/simple_app/api/payment.php'
          '?userid=${widget.user.userid}'
          '&email=${widget.user.useremail}'
          '&phone=${widget.user.userphone}'
          '&name=${widget.user.username}'
          '&amount=${widget.totalprice.toStringAsFixed(2)}'
          '&membership_id=${widget.membershipDetails?["membership_id"]}'
          '&checkout_type=${widget.checkoutType}';
    } else {
      throw Exception("Invalid checkout type");
    }
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              isLoading = true; // Show loading spinner when the page starts loading
            });
          },
          onPageFinished: (_) {
            setState(() {
              isLoading = false; // Hide loading spinner when the page finishes loading
            });
          },
          onNavigationRequest: (request) {
            if (request.url.contains("success")) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment Successful")),
              );
              // Handle navigation after success
            } else if (request.url.contains("failed")) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Payment Failed")),
              );
              // Handle navigation after failure
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child:
                  CircularProgressIndicator(), // Show a spinner while loading
            ),
        ],
      ),
    );
  }
}
