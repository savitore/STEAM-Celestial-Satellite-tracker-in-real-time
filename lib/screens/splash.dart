import 'dart:async';

import 'package:flutter/material.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/screens/home.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  final _imageRows = [
    [
      'assets/liquid_galaxy.png',
    ],
    [
      'assets/gsoc.png',
      'assets/LGEU.png',
      'assets/lglab.png',
      'assets/gdgLleida.png',
      'assets/wtmLleida.png',
      'assets/Laboratoris_TIC.png',
      'assets/PCiTAL.png',
    ],
    [
      'assets/android.png',
      'assets/arduino.png',
    ]
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Home()));
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: Image.asset('assets/logo.png'),
              ),
              ..._imageRows
                  .map(
                    (images) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: images
                            .map(
                              (img) => Container(
                                alignment: Alignment.center,
                                width: screenWidth / (images.length + 1),
                                height: screenHeight / 5,
                                child: Image.asset(img),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
