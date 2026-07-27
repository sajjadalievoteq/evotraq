import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/animation/traq_animation_constants.dart';
import 'package:traqtrace_app/core/animation/traq_staggered_entrance.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/constants.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

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

  /// One entrance controller for the branding panel (not one per section).
  Widget _entrance({required List<Widget> children}) {
    return TraqStaggeredEntrance(
      slide: TraqEntranceSlide.fromRight,
      slidePx: TraqAnimationConstants.brandingSlidePx,
      duration: TraqAnimationConstants.brandingEntrance,
      stagger: TraqAnimationConstants.brandingStagger,
      beginScale: 1,
      children: children,
    );
  }

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
          return _entrance(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'traq',
                    style: context.text.h2.copyWith(
                      color: c.textPrimary,
                      fontSize: 62,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'GS1 TRACK & TRACE',
                    style: t.mono.copyWith(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: c.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: textAlign,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Every package.\nEvery event.\nVerified.',
                    style: t.h1.copyWith(
                      fontSize: 20,
                      height: 1.05,
                      color: c.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final align = textAlign == TextAlign.left
            ? Alignment.centerLeft
            : Alignment.center;

        final panelHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : null;

        // Single child entrance preserves spaceBetween layout with one ticker.
        return SizedBox(
          height: panelHeight,
          width: layoutWidth,
          child: _entrance(
            children: [
              SizedBox(
                height: panelHeight,
                width: layoutWidth,
                child: Column(
                  crossAxisAlignment: crossAxisAlignment,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'traq',
                          style: context.text.h2.copyWith(
                            color: c.textPrimary,
                            fontSize: 62,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'EVOTEQ',
                          style: context.text.h2.copyWith(
                            color: c.textPrimary,
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
