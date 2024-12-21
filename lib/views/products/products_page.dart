import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_app/views/products/cart_page.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/products/new_product.dart';
import 'package:simple_app/views/shared/mydrawer.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/global.dart' as globals;
import '../../models/products.dart';
import 'productdetail_page.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Myproduct> productsList = [];
  late double PageproductsPageWidth, PageproductsPageHeight;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  String status = "No Product Found";
  String? userId = globals.userId; // Fetching userId from globals
  final List<Map<String, dynamic>> cart = [];
  int cartItemCount = 0; // To hold the cart count

  // Pagination variables
  int curpage = 1;
  int numofpage = 1;
  int itemsPerPage = 5; // You can adjust this
  var color;
  int numofresult = 0;

  @override
  void initState() {
    super.initState();
    loadProductsData(); // Initial load of data
  }

  // Search query
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    PageproductsPageHeight = MediaQuery.of(context).size.height;
    PageproductsPageWidth = MediaQuery.of(context).size.width;

    // Filtered product list based on search query
    final filteredProducts = searchQuery.isEmpty
        ? productsList
        : productsList
            .where((product) =>
                product.productTitle!
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                product.productType!
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
            .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
        actions: [
          IconButton(
            onPressed: () {
              loadProductsData(); // Refresh data manually
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  size: 28,
                ),
                if (cartItemCount > 0)
                  Positioned(
                    //top: 0.5,
                    right: -1,
                    bottom:
                        2, // Adjusting to the right to avoid clipping  // Position the count below the icon
                    child: CircleAvatar(
                      radius:
                          8, // Slightly larger radius to ensure the count is not clipped
                      backgroundColor: Colors.red,
                      child: Text(
                        cartItemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12, // Smaller font size
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              if (userId != null) {
                // Ensure userId is not null before navigating
                navigateToCartPage();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User ID is not available')),
                );
              }
            },
          )
        ],
      ),
      body: filteredProducts.isEmpty
          ? Center(
              child: Text(
                status,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: PageproductsPageHeight * 0.05,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: numofpage,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      color =
                          (curpage == index + 1) ? Colors.red : Colors.black;
                      return TextButton(
                        onPressed: () {
                          setState(() {
                            curpage = index + 1;
                          });
                          loadProductsData(); // Reload data for the selected page
                        },
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(color: color, fontSize: 18),
                        ),
                      );
                    },
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products by title or type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                // Product list
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio:
                          0.7, // Slightly reduced the aspect ratio for a more compact grid
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () {
                          // deleteDialog(index); // Uncomment if long press for delete functionality is needed
                        },
                        onTap: () async {
                          // Refresh data when a product is tapped
                          await loadProductsData(); // Refresh products
                          showProductDetails(
                              index); // Navigate to product details
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(16), // Rounded corners
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                ClipRRect(
                                  child: Image.network(
                                    "${MyConfig.servername}/simple_app/assets/products/${filteredProducts[index].productFilename}",
                                    width: double.infinity,
                                    height: 120, // Fixed height for images
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "assets/Not Found Image.png",
                                      fit: BoxFit.cover,
                                      height: 120,
                                    ),
                                  ),
                                ),
                                // Product Title
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    filteredProducts[index]
                                        .productTitle
                                        .toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                // Product Type
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    filteredProducts[index]
                                        .productType
                                        .toString(),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    maxLines: 1,
                                  ),
                                ),
                                // Product Date
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    df.format(DateTime.parse(
                                        filteredProducts[index]
                                            .productDate
                                            .toString())),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    maxLines: 1,
                                  ),
                                ),
                                // Product Description (truncated)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    truncateString(
                                        filteredProducts[index]
                                            .productDescription
                                            .toString(),
                                        45),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                //Product Rating
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,vertical: 4.0),
                                  child: RatingBar.readOnly(
                                    initialRating: filteredProducts[index]
                                            .productRating
                                            ?.toDouble() ??
                                        0.0,
                                    isHalfAllowed: true,
                                    alignment: Alignment.centerLeft,
                                    filledIcon: Icons.star,
                                    emptyIcon: Icons.star_border,
                                    emptyColor: const Color.fromARGB(
                                        255, 113, 113, 113),
                                    filledColor:
                                        const Color.fromARGB(255, 238, 250, 0),
                                    halfFilledColor: const Color.fromARGB(255, 238, 250, 0),
                                    halfFilledIcon: Icons.star_half,
                                    maxRating: 5,
                                    size: 18,
                                  ),
                                ),
                                // Product Price
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "RM${(filteredProducts[index].productPrice?.toDouble() ?? 0.0).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Color.fromARGB(255, 253, 157, 2),
                                        ),
                                      ),Text(
                                    "${(filteredProducts[index].productSold?.toInt() ?? 0)} Sold",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
        elevation: 8,
        onPressed: () async {
          // When navigating to the NewProductPage, wait for the result to trigger reload
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (content) => const NewProductPage()),
          );
          // Refresh data after returning from the NewProductPage
          loadProductsData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String truncateString(String str, int length) {
    if (str.length > length) {
      str = str.substring(0, length);
      return "$str...";
    } else {
      return str;
    }
  }

  Future<void> loadProductsData() async {
    try {
      final response = await http.get(Uri.parse(
          "${MyConfig.servername}/simple_app/api/load_products.php?pageno=$curpage&limit=$itemsPerPage"));
      log(response.body.toString()); // Debug response

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          var result = data['data'];
          if (result != null && result is List) {
            productsList.clear();
            for (var item in result) {
              Myproduct myproduct = Myproduct.fromJson(item);
              productsList.add(myproduct);
            }

            numofpage = int.tryParse(data['numofpage'].toString()) ?? 1;
            numofresult = int.tryParse(data['numberofresult'].toString()) ?? 0;

            setState(() {});
          } else {
            status = "No products found";
          }
        } else {
          status = "No Data";
        }
      } else {
        status = "Error loading data";
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      log("Error: $error");
      status = "An error occurred while loading data";
    }
    setState(() {});
  }

  void showProductDetails(int index) {
    // Get the selected product from the list
    Myproduct selectedProduct = productsList[index];

    // Navigate to the ProductDetailPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: selectedProduct,
          userId: userId!,
        ),
      ),
    );
  }

  void navigateToCartPage() async {
    final cartCount = await loadCartCount(); // Fetch the cart count from API
    setState(() {
      cartItemCount = cartCount; // Update the cart count
    });
    // Now navigate to the cart page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartPage(userId: userId!),
      ),
    );
  }

// Example API call to fetch the cart count (adjust the URL accordingly):
  Future<int> loadCartCount() async {
    final response = await http.post(
      Uri.parse("${MyConfig.servername}/simple_app/api/load_cart2.php"),
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // Ensure 'cart_item_count' exists in the response
      return responseData['cart_item_count'] ?? 0;
    } else {
      return 0; // If error occurs, assume empty cart
    }
  }
}
