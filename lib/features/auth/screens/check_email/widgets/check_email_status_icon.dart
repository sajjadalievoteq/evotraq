import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class CheckEmailStatusIcon extends StatelessWidget {
  const CheckEmailStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return TraqIconPop(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: primary.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.12,
          ),
          borderRadius: BorderRadius.circular(TraqRadius.lg.x),
        ),
        child: Center(
          child: SvgPicture.asset(
            AppAssets.iconMail,
            width: 48,
            height: 48,
            colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
