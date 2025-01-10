import 'dart:convert';
import 'dart:developer';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/models/membership.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/models/user.dart';
import 'package:simple_app/views/membership/membership_history.dart';
import 'package:simple_app/views/payments/bill_page.dart';
import 'package:simple_app/views/shared/mydrawer.dart';

class MembershipPage extends StatefulWidget {
  final User user;

  const MembershipPage({super.key, required this.user});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  List<Membership> memberships = [];
  late double pageWidth, pageHeight;
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadMemberships();
  }

  @override
  Widget build(BuildContext context) {
    pageWidth = MediaQuery.of(context).size.width;
    pageHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Membership Types"),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadMemberships,
          ),
        ],
      ),
      body: memberships.isEmpty
          ? Center(
              child: Text(
                status,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            )
          : _buildGridView(),
      drawer: MyDrawer(user: widget.user),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MembershipHistoryPage(user: widget.user)),
          );
        },
        icon: const Icon(Icons.history),
        label: const Text("View History"),
      ),
    );
  }

  // --- Widgets ---
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: memberships.length,
      itemBuilder: (context, index) {
        return _buildCard(index);
      },
    );
  }

  Widget _buildCard(int index) {
    return Card(
      shadowColor: Colors.grey.shade300,
      color: Colors.white,
      elevation: 4,
      child: InkWell(
        onTap: () => _showDetailsDialog(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: pageHeight / 6,
              width: double.infinity,
              child: Image.network(
                "${MyConfig.servername}/simple_app/assets/membership/${memberships[index].membershipFilename}",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/Not Found Image.png", // Placeholder for broken links
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Membership Type Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                memberships[index].name!,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ), // Product Description (truncated)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                truncateString(memberships[index].description.toString(), 45),
                style: const TextStyle(fontSize: 12, color: Colors.black),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            //Product Rating
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: RatingBar.readOnly(
                initialRating:
                    memberships[index].membershipRating?.toDouble() ?? 0.0,
                isHalfAllowed: true,
                alignment: Alignment.centerLeft,
                filledIcon: Icons.star,
                emptyIcon: Icons.star_border,
                emptyColor: const Color.fromARGB(255, 113, 113, 113),
                filledColor: const Color.fromARGB(255, 238, 250, 0),
                halfFilledColor: const Color.fromARGB(255, 238, 250, 0),
                halfFilledIcon: Icons.star_half,
                maxRating: 5,
                size: 18,
              ),
            ),
            // Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "RM${memberships[index].price}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 253, 157, 2),
                    ),
                  ),
                  // Sold
                  Text(
                    "${(memberships[index].membershipsold?.toInt() ?? 0)} Sold",
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
    );
  }

  // --- API Calls ---
  Future<void> loadMemberships() async {
    try {
      final response = await http.get(
        Uri.parse("${MyConfig.servername}/simple_app/api/load_membership.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            memberships = (data['data'] as List)
                .map((item) => Membership.fromJson(item))
                .toList();
          });
        } else {
          setState(() {
            status = "No Memberships Found";
          });
        }
      } else {
        setState(() {
          status = "Error Loading Memberships";
        });
      }
    } catch (e) {
      log(e.toString());
      setState(() {
        status = "Error: $e";
      });
    }
  }

  // --- Dialogs ---
  void _showDetailsDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(memberships[index].name!),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description: ${memberships[index].description}'),
                Text('Price: RM${memberships[index].price}'),
                Text('Duration: ${memberships[index].duration} days'),
                Text('Benefits: ${memberships[index].benefits}'),
                Text('Terms: ${memberships[index].terms}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BillScreen(
                      totalprice: double.tryParse(memberships[index].price!) ??
                          0.0, // Ensure null safety for `price`
                      membershipDetails: {
                        "membership_id": memberships[index].id,
                        "name": memberships[index].name,
                      }, // Pass membership details
                      checkoutType: "membership",
                      user: widget.user,
                    ),
                  ),
                );
              },
              child: const Text("Buy",
                  style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close",
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        );
      },
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
}
