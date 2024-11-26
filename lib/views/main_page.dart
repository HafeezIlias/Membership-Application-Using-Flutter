import 'package:flutter/material.dart';
import 'package:simple_app/views/events/events_page.dart';
import 'package:simple_app/views/members/members_page.dart';
import 'package:simple_app/views/newsletter/newsletter_page.dart';
import 'package:simple_app/views/payments/payments_page.dart';
import 'package:simple_app/views/products/products_page.dart';
import 'package:simple_app/views/vetting/vetting_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Widget buildButton(String text, VoidCallback onPressed) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: const Color.fromARGB(255, 253, 157, 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  height: 100,
                  color: const Color.fromARGB(0, 181, 209, 40),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: 6, // Adjust the number of items if needed
                  itemBuilder: (context, index) {
                    const buttonLabels = [
                      "Newsletter",
                      "Events",
                      "Members",
                      "Payments",
                      "Products",
                      "Vetting"
                    ];
                    final pages = [
                      NewsletterPage(),
                      EventsPage(),
                      MembersPage(),
                      PaymentsPage(),
                      ProductsPage(),
                      VettingPage(),
                    ];
                    return buildButton(buttonLabels[index], () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => pages[index]),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
