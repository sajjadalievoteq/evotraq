import 'package:flutter/material.dart';


abstract final class NativeSplashColors {
  static const Color lightBackground = Color(0xFFF2F2EF);
  static const Color darkBackground = Color(0xFF1C1C1B);

  static Color forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : lightBackground;
  }
}
