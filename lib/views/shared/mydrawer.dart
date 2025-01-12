import 'package:flutter/material.dart';
import 'package:simple_app/models/user.dart';
import 'package:simple_app/myconfig.dart';
import 'package:simple_app/views/Setting/setting_page.dart';
import 'package:simple_app/views/events/events_page.dart';
import 'package:simple_app/views/auth/login_page.dart';
import 'package:simple_app/views/main_page.dart';
import 'package:simple_app/views/members/members_page.dart';
import 'package:simple_app/views/membership/membership_page.dart';
import 'package:simple_app/views/newsletter/newsletter_page.dart';
import 'package:simple_app/views/products/products_page.dart';

class MyDrawer extends StatelessWidget {

  final User user;
  const MyDrawer({super.key,required this.user}); // Pass username in the constructor

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.orangeAccent),
            accountName: Text(
              'Welcome ${user.username}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: null, // You can add an email if you want
            currentAccountPicture:  CircleAvatar(
              backgroundImage: NetworkImage("${MyConfig.servername}/simple_app/assets/profileImage/${user.userprofileimage}"),
            ),
          ),
          _buildDrawerItem(
            context,
            title: "Home",
            icon: Icons.home,
            destination: MainPage(user: user,),
          ),
          _buildDrawerItem(
            context,
            title: "Newsletter",
            icon: Icons.mail,
            destination: NewsletterPage(user: user,),
          ),
          _buildDrawerItem(
            context,
            title: "Events",
            icon: Icons.event,
            destination: EventsPage(user: user,),
          ),
          _buildDrawerItem(
            context,
            title: "Members",
            icon: Icons.group,
            destination: MembersPage(user: user,), // Placeholder for Members page
          ),
          _buildDrawerItem(
            context,
            title: "Membership",
            icon: Icons.badge,
            destination: MembershipPage(user: user,), 
          ),
          _buildDrawerItem(
            context,
            title: "Payments",
            icon: Icons.payment,
            destination: MainPage(user: user,), // Placeholder for Payments page
          ),
          _buildDrawerItem(
            context,
            title: "Products",
            icon: Icons.shopping_cart,
            destination: ProductsPage(user: user,),
          ),
          _buildDrawerItem(
            context,
            title: "Vetting",
            icon: Icons.check_circle,
            destination: MainPage(user: user,), // Placeholder for Vetting page
          ),
          _buildDrawerItem(
            context,
            title: "Settings",
            icon: Icons.settings,
            destination: SettingsPage(user: user,), // Placeholder for Settings page
          ),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.exit_to_app,color: Colors.orangeAccent,),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Logout Success"),
                backgroundColor: Colors.green,
              ));
              Navigator.push(
                context,
                _buildPageRoute(
                  context,
                  const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to create a custom ListTile with an icon and a page route
  ListTile _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget destination,
  }) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon, color: Colors.orangeAccent),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.push(
          context,
          _buildPageRoute(context, destination),
        );
      },
    );
  }

  // Helper method to create a custom PageRoute with a slide transition
  PageRouteBuilder _buildPageRoute(BuildContext context, Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide in from the right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
