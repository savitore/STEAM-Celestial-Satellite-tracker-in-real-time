import 'dart:async';

import 'package:flutter/material.dart';

import 'home.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()));
    });

    return Container(
      height: double.infinity,
      color: Colors.white,
      child: Image.asset('assets/mainLogo.jpg'),
    );
  }
}

