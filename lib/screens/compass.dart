import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {


  double? heading =0.0;

  @override
  void initState() {
    FlutterCompass.events!.listen((event) {
      setState(() {
        heading=event.heading;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundCardColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeColors.textPrimary,
        leading: IconButton(icon : const Icon(Icons.arrow_back), onPressed: () { Navigator.pop(context); },),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text('Compass',overflow: TextOverflow.visible,style: TextStyle(fontWeight: FontWeight.bold,color: ThemeColors.textPrimary,fontSize: 40),),
                ],
              ),
              const SizedBox(height: 30),
              Text("${heading!.ceil()}°",style: TextStyle(color: ThemeColors.primaryColor,fontSize: 26,fontWeight: FontWeight.bold),),
              const SizedBox(height: 50),
              Transform.rotate(
                angle: ((heading ?? 0) * (pi/180) * -1),
                child: Image.asset("assets/compass.png",fit: BoxFit.fill,),
              )
            ],
          ),
        ),
      ),
    );
  }
}
