import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Screen {
  late double screenWidth;
  late double screenHeight;
  late double scaleFactor;

  Screen(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    scaleFactor = screenWidth /
        400; // Base scaling factor for width around a medium screen width (e.g., 400px)
  }
}
