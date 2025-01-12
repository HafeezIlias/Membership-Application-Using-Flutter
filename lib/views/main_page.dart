import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/events/events_page.dart';
import 'package:simple_app/views/members/members_page.dart';
import 'package:simple_app/views/newsletter/newsletter_page.dart';
import 'package:simple_app/views/payments/payments_page.dart';
import 'package:simple_app/views/products/products_page.dart';
import 'package:simple_app/views/shared/mydrawer.dart';
// import 'package:simple_app/views/vetting/vetting_page.dart';
import 'package:simple_app/views/membership/membership_page.dart';
import 'package:simple_app/models/news.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';

class MainPage extends StatefulWidget {
  final User user;

  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<News> newsList = [];
  final DateFormat df = DateFormat('dd/MM/yyyy hh:mm a');
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadNewsData();
    _updateMembershipStatus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        drawer: MyDrawer(user: widget.user,),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Latest News'),
              ),
              _buildNewsSection(),
              const SizedBox(height: 16),
              _buildQuickAccessSection(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Profile Section ---

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(color: Colors.orangeAccent),
      child: Row(
        children: [
          // IconButton(onPressed: (){
          //   MyDrawer();
          // }, icon: Icon(Icons.menu , color: Colors.white,),),
          ClipOval(
            child: Image.network(
              "${MyConfig.servername}/simple_app/assets/profileImage/${widget.user.userprofileimage}",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/user.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.username?? "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 Text(
                  widget.user.userrole?? "Role Undefined",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
    );
  }

  // --- News Section ---
Widget _buildNewsSection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showNewsDetailsDialog(index),
            child: Container(
              width: 300,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 5,
                    spreadRadius: 2,
                  )
                ],
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truncateString(newsList[index].newsTitle ?? '', 30),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      df.format(DateTime.parse(
                          newsList[index].newsDate ?? DateTime.now().toString())),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        truncateString(newsList[index].newsDetails ?? '', 100),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  // --- Quick Access Section ---
  Widget _buildQuickAccessSection() {
    Widget buildQuickAccessButton(
        String label, IconData icon, VoidCallback onPressed) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orangeAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        padding: const EdgeInsets.all(16),
        children: [
          buildQuickAccessButton('Newsletter', Icons.article, () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NewsletterPage(user: widget.user,)));
          }),
          buildQuickAccessButton('Events', Icons.event, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => EventsPage(user: widget.user,)));
          }),
          buildQuickAccessButton('Members', Icons.group, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MembersPage(user: widget.user,)));
          }),
          buildQuickAccessButton('Payments', Icons.payment, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PaymentsPage()));
          }),
          buildQuickAccessButton('Products', Icons.shopping_bag, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProductsPage(user: widget.user,)));
          }),
          buildQuickAccessButton('Membership', Icons.badge, () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MembershipPage(user: widget.user,)));
          }),
        ],
      ),
    );
  }

  // --- Show News Details Dialog ---
  void showNewsDetailsDialog(int index) {
    if (index < 0 || index >= newsList.length) {
      print("Error: Index $index is out of bounds for newsList");
      return;
    }

    News news = newsList[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(news.newsTitle ?? "No Title"),
          content: Text(news.newsDetails ?? "No Details"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsletterPage(user: widget.user)),                 
                );
              },
              child: const Text("Learn More"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // --- Load News Data ---
  void loadNewsData() async {
    try {
      final response = await http.get(
        Uri.parse("${MyConfig.servername}/simple_app/api/load_news.php"),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == "success") {
          var result = data['data']['news'];
          newsList.clear();

          for (var item in result) {
            newsList.add(News.fromJson(item));
          }
          setState(() {});
        }
      }
    } catch (error) {
      print("Error fetching news data: $error");
    }
  }

  // --- Utility ---
  String truncateString(String str, int length) {
    return (str.length > length) ? "${str.substring(0, length)}..." : str;
  }
   Future<void> _updateMembershipStatus() async {
    final url = '${MyConfig.servername}/simple_app/api/update_membership_status.php?user_id=${widget.user.userid}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Membership statuses updated successfully: ${response.body}');
      } else {
        print('Failed to update membership statuses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
