import 'package:traqtrace_app/core/consts/app_consts.dart';
import 'package:traqtrace_app/core/layout/app_layout_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/theme/traq_theme_tokens.dart';
import 'package:traqtrace_app/features/auth/widgets/auth_branding_entrance.dart';

class AuthBrandingSection extends StatelessWidget {
  const AuthBrandingSection({
    super.key,
    required this.layout,
    required this.primary,
    required this.textSecondary,
    this.prominent = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
    this.title = Constants.appName,
    this.subtitle = Constants.appTagline,
    this.logoAssetPath = AppAssets.logo,
  });

  final AppLayoutData layout;
  final Color primary;
  final Color textSecondary;
  final bool prominent;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;
  final String title;
  final String subtitle;
  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final c = context.colors;
    final isLarge = layout.isLarge;

    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : TraqAnimationConstants.brandingSlidePx;

        if (!isLarge) {
          return AuthBrandingEntrance(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 48,
                          child: SvgPicture.asset(
                            logoAssetPath,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              c.textPrimary,
                              BlendMode.srcIn,
                            ),
                            alignment: Alignment.centerLeft,
                            semanticsLabel: title,
                          ),
                        ),
                        const SizedBox(height: TraqSpacing.xs),
                        Text(
                          'EVOTEQ',
                          style: t.mono.copyWith(
                            color: c.primary,
                            fontSize: 12,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TraqSpacing.xxxl),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GS1 TRACK & TRACE',
                        style: t.mono.copyWith(
                          fontSize: 11,
                          letterSpacing: 1.4,
                          color: c.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: TraqSpacing.sm),
                      Text(
                        'Every package.\nEvery event.\nVerified.',
                        style: t.h1.copyWith(
                          fontSize: 22,
                          height: 1.12,
                          color: c.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }

        final align = textAlign == TextAlign.left
            ? Alignment.centerLeft
            : Alignment.center;

        final panelHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : null;

        return SizedBox(
          height: panelHeight,
          width: layoutWidth,
          child: AuthBrandingEntrance(
            children: [
              SizedBox(
                height: panelHeight,
                width: layoutWidth,
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 230,
                          height: 62,
                          child: SvgPicture.asset(
                            logoAssetPath,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              c.textPrimary,
                              BlendMode.srcIn,
                            ),
                            alignment: Alignment.centerLeft,
                            semanticsLabel: title,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'EVOTEQ',
                          style: context.text.h2.copyWith(
                            color: c.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Align(
                          alignment: align,
                          child: Text(
                            'GS1 TRACK & TRACE',
                            style: t.mono.copyWith(
                              fontSize: 16,
                              letterSpacing: 1.2,
                              color: c.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: textAlign,
                          ),
                        ),
                        Align(
                          alignment: align,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              'Every package.\nEvery event.\nVerified.',
                              style: t.h1.copyWith(
                                fontSize: isLarge ? 44 : 36,
                                height: 1.05,
                                color: c.textPrimary,
                              ),
                              textAlign: textAlign,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          'GS1 EPCIS 2.0',
                          style: t.body.copyWith(color: c.textMuted),
                          textAlign: textAlign,
                        ),
                        const SizedBox(width: 20),
                        Container(
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            color: c.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'CBV 2.0',
                          style: t.body.copyWith(color: c.textMuted),
                          textAlign: textAlign,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
