
import 'package:flutter/material.dart';
import 'package:simple_app/views/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Navigate to LoginPage after 3 seconds with a mounted check
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: const Color.fromRGBO(29, 89, 78, 100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Logo Simple App.png',
              height: 150,
              width: 200,
              ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 255, 255, 255),
              strokeWidth: 5,
            ),
          ],
        ),
      ),
    );
  }
}
