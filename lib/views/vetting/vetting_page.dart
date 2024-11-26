import 'package:flutter/material.dart';

class VettingPage extends StatefulWidget {
  const VettingPage({super.key});

  @override
  State<VettingPage> createState() => _VettingPageState();
}

class _VettingPageState extends State<VettingPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:  Center(child: Text('Vetting Page')),);
  }
}