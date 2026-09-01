import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class TraqBackgroundTexture extends StatelessWidget {
  const TraqBackgroundTexture({
    super.key,
    this.textureOpacity = 0.2,
    this.overlayOpacity = 0.1,
    this.fit = BoxFit.cover,
  });

  final double textureOpacity;
  final double overlayOpacity;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: textureOpacity,
          child: SvgPicture.asset(
            AppAssets.traqBackgroundSvg,
            fit: fit,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        if (overlayOpacity > 0)
          ColoredBox(color: Colors.black.withValues(alpha: overlayOpacity)),
      ],
    );
  }
}
