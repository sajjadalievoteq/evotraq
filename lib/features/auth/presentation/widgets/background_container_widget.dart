import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';

class BackgroundContainerWidget extends StatelessWidget {
  final Widget child;

  const BackgroundContainerWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.loginBackground),
            fit: BoxFit.cover,
          ),
        ),
        // Overlay a slight dimming if needed
        child: Container(
          color: Colors.black.withOpacity(0.05),
          child: child,
        ),
      ),
    );
  }
}
