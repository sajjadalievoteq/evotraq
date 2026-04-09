import 'package:flutter/material.dart';

/// A custom loading indicator widget for use throughout the app
class AppLoadingIndicator extends StatelessWidget {
  /// Default constructor
  const AppLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}
