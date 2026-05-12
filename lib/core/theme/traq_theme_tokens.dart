part of 'traq_theme.dart';

class TraqSpacing {
  // 4-pt scale used throughout the designs
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Common paddings
  static const EdgeInsets cardPad = EdgeInsets.all(20);
  static const EdgeInsets surfacePad = EdgeInsets.all(16);
  static const EdgeInsets pagePad =
      EdgeInsets.symmetric(horizontal: 24, vertical: 24);

  // Component heights
  static const double buttonH = 36;
  static const double buttonHLarge = 44;
  static const double inputH = 44;
  static const double topbarH = 64;
  static const double sidebarW = 240;
  static const double sidebarWClose = 64;
}

class TraqRadius {
  // Tight corners: 4px default
  static const Radius xs = Radius.circular(2);
  static const Radius sm = Radius.circular(3);
  static const Radius md = Radius.circular(4);
  static const Radius lg = Radius.circular(8);
  static const Radius pill = Radius.circular(999);

  static const BorderRadius card = BorderRadius.all(md);
  static const BorderRadius input = BorderRadius.all(md);
  static const BorderRadius button = BorderRadius.all(md);
  static const BorderRadius chip = BorderRadius.all(sm);
}

class TraqDuration {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 400);
  static const Cubic ease = Cubic(0.4, 0.0, 0.2, 1.0);
}

class TraqShadows {
  static List<BoxShadow> sm({required Brightness brightness}) => [
        BoxShadow(
          color: brightness == Brightness.dark
              ? const Color(0x66000000)
              : const Color(0x0F000000),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> md({required Brightness brightness}) => [
        BoxShadow(
          color: brightness == Brightness.dark
              ? const Color(0x99000000)
              : const Color(0x1F000000),
          blurRadius: 24,
          spreadRadius: -8,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> lg({required Brightness brightness}) => [
        BoxShadow(
          color: brightness == Brightness.dark
              ? const Color(0xB3000000)
              : const Color(0x2E000000),
          blurRadius: 48,
          spreadRadius: -12,
          offset: const Offset(0, 24),
        ),
      ];

  static List<BoxShadow> primaryGlow(TraqColors c) => [
        BoxShadow(color: c.primaryGlow, blurRadius: 16, spreadRadius: -2),
      ];
}
