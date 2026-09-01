import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/traq_background_texture.dart';

class TraqAppBarFlexibleBackground extends StatelessWidget {
  const TraqAppBarFlexibleBackground({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const TraqBackgroundTexture(),
    );
  }
}
