import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TraqIcon extends StatelessWidget {
  const TraqIcon(
    this.asset, {
    super.key,
    this.size = 16,
    this.color,
  });

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? IconTheme.of(context).color ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,

        colorFilter: ColorFilter.mode(resolved, BlendMode.srcIn),
      ),
    );
  }
}
