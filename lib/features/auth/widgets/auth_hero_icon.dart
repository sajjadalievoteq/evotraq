import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthHeroIcon extends StatelessWidget {
  const AuthHeroIcon({
    super.key,
    required this.asset,
    required this.color,
    this.size = 80,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
