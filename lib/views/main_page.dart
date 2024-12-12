import 'package:flutter/material.dart';
import 'package:simple_app/views/events/events_page.dart';
import 'package:simple_app/views/members/members_page.dart';
import 'package:simple_app/views/newsletter/newsletter_page.dart';
import 'package:simple_app/views/payments/payments_page.dart';
import 'package:simple_app/views/products/products_page.dart';
import 'package:simple_app/views/shared/mydrawer.dart';
import 'package:simple_app/views/vetting/vetting_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.username});
  final String username;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget buildQuickAccessButton(String label, IconData icon, VoidCallback onPressed) {
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,  // Ensure scaffoldKey is used
        drawer: MyDrawer(username: widget.username), // Your drawer widget here
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  color: Colors.orangeAccent
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/Logo Simple App.png', // Your image path
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Admin',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // Open the drawer when the settings icon is pressed
                        scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable News/Events Section
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Example count for news/events
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(left: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Short description of the event or news goes here.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Quick Access Section
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: const EdgeInsets.all(16),
                  children: [
                    buildQuickAccessButton('Newsletter', Icons.article, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NewsletterPage()),
                      );
                    }),
                    buildQuickAccessButton('Events', Icons.event, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EventsPage()),
                      );
                    }),
                    buildQuickAccessButton('Members', Icons.group, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MembersPage()),
                      );
                    }),
                    buildQuickAccessButton('Payments', Icons.payment, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentsPage()),
                      );
                    }),
                    buildQuickAccessButton('Products', Icons.shopping_bag, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductsPage()),
                      );
                    }),
                    buildQuickAccessButton('Vetting', Icons.verified, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VettingPage()),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
