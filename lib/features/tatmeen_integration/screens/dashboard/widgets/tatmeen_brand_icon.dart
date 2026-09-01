import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

class TatmeenBrandIcon extends StatelessWidget {
  const TatmeenBrandIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SvgPicture.asset(
        AppAssets.iconTatmeenIntegration,
        width: size,
        height: size,
      ),
    );
  }
}