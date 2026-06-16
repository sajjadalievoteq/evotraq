import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';

import '../../../../core/config/app_assets.dart';
import '../../../../core/config/constants.dart';
import 'package:traqtrace_app/core/layout/layout_manager.dart';

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

    return layout.isLarge == false
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        'EVOTEQ',
                        style: context.text.h2.copyWith(
                          color: c.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              SizedBox(height: 10,),

              Align(
                alignment: Alignment.centerLeft,
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
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Every package.\nEvery event.\nVerified.',
                  style: t.h1.copyWith(
                    fontSize: 20,
                    height: 1.05,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          )
        : Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
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
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Align(
                  alignment: textAlign == TextAlign.left
                      ? Alignment.centerLeft
                      : Alignment.center,
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
                const SizedBox(height: 16),
                Align(
                  alignment: textAlign == TextAlign.left
                      ? Alignment.centerLeft
                      : Alignment.center,
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
              ],
            ),
            Row(
              children: [
                Spacer(),
                Text(
                  "GS1 EPCIS 2.0",
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
                  "CBV 2.0",
                  style: t.body.copyWith(color: c.textMuted),
                  textAlign: textAlign,
                ),
              ],
            ),
          ],
        );
  }
}
