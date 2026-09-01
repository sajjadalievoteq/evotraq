import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:flutter/material.dart';

import '../config/app_assets.dart';

class AppBackgroundLayer extends StatelessWidget {
  const AppBackgroundLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(children:[
        Opacity(
          opacity: 0.2,
          child: SvgPicture.asset(
            AppAssets.traqBackgroundSvg,
            fit: BoxFit.fitWidth,
          ),
        ),
        ColoredBox(color: Colors.black.withOpacity(0.05))]),
    );
  }
}
