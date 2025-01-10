import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/models/user.dart';

class MembershipHistoryPage extends StatefulWidget {
  final User user;
  const MembershipHistoryPage({super.key, required this.user});

  @override
  State<MembershipHistoryPage> createState() => _MembershipHistoryPageState();
}

class _MembershipHistoryPageState extends State<MembershipHistoryPage> {
  List<dynamic> history = [];
  String status = "Loading...";

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final response = await http.post(
      Uri.parse("${MyConfig.servername}/simple_app/api/load_purchased_membership.php"),
      body: {'user_id': widget.user.userid},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        history = data['data'];
        if (history.isEmpty) {
          status = "No purchases found.";
        }
      });
    } else {
      setState(() {
        status = "Error loading history";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership History'),
        backgroundColor: const Color.fromARGB(255, 253, 157, 2),
      ),
      body: history.isEmpty
          ? Center(
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return _buildHistoryCard(index);
                },
              ),
            ),
    );
  }

  Widget _buildHistoryCard(int index) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(history[index]['payment_status']),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history[index]['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Amount: RM${history[index]['payment_amount']}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        history[index]['payment_status'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: history[index]['payment_status'] == 'Paid'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Purchased on: ${history[index]['purchase_date']}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
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

  Widget _buildIcon(String status) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: status == 'Paid' ? Colors.green : Colors.red,
      child: Icon(
        status == 'Paid' ? Icons.check_circle : Icons.error,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
