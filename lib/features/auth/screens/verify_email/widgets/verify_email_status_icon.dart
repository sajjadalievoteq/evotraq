import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

class VerifyEmailStatusIcon extends StatelessWidget {
  const VerifyEmailStatusIcon({
    super.key,
    required this.isVerifying,
    required this.isSuccess,
  });

  final bool isVerifying;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final primary = c.primary;
    final success = c.success;
    final error = c.error;

    return TraqIconPop(
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: isVerifying
              ? primary.withOpacity(
                  Theme.of(context).brightness == Brightness.dark
                      ? 0.22
                      : 0.12,
                )
              : (isSuccess
                    ? success.withValues(alpha: 0.14)
                    : error.withValues(alpha: 0.14)),
          borderRadius: BorderRadius.circular(TraqRadius.lg.x),
        ),
        child: isVerifying
            ? Padding(
                padding: const EdgeInsets.all(28),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              )
            : Center(
                child: SvgPicture.asset(
                  isSuccess ? AppAssets.iconCheck : AppAssets.iconMail,
                  width: 48,
                  height: 48,
                  colorFilter: ColorFilter.mode(
                    isSuccess ? success : error,
                    BlendMode.srcIn,
                  ),
                ),
              ),
      ),
    );
  }
}
