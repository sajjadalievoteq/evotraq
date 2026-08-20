import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:flutter/material.dart';

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
