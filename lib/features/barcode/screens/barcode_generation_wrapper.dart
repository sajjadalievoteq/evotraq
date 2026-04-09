import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/barcode/screens/barcode_generation_screen.dart';

/// A wrapper widget that provides the necessary services for barcode generation
class BarcodeGenerationWrapper extends StatelessWidget {
  const BarcodeGenerationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BarcodeGenerationScreen();
  }
}
