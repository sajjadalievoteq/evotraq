import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/constants.dart';

class AppBackgroundLayer extends StatelessWidget {
  const AppBackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Constants.loginBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: ColoredBox(color: Colors.black.withOpacity(0.05)),
    );
  }
}
