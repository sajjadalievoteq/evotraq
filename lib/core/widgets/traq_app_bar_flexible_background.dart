import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class TraqAppBarFlexibleBackground extends StatelessWidget {
  const TraqAppBarFlexibleBackground({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            image: const DecorationImage(
              image: AssetImage(AppAssets.traqBackgroundPng),
              fit: BoxFit.cover,
              opacity: 0.2,
            ),
          ),
        ),
        ColoredBox(color: Colors.black.withOpacity(0.1)),
      ],
    );
  }
}
