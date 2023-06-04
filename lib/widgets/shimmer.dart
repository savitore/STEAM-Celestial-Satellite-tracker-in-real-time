import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect{

  Widget shimmer(Widget child) {
    return Shimmer(
      direction: ShimmerDirection.ltr,
      gradient: const LinearGradient(
        colors: [
          Colors.white,
          Colors.grey,
          Colors.white,
        ],
        begin: Alignment(-1.0, -0.5), // Set the start point of the gradient
        end: Alignment(2.0, 0.5), // Set the end point of the gradient
      ),
      child: child,
    );
  }

}