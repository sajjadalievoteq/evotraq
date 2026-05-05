import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';

import '../../../../core/config/app_assets.dart';
import '../../../../core/config/constants.dart';
import '../../../../shared/layout/layout_manager.dart';

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
    final maxW = isLarge ? 520.0 : 600.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     layout.isCompact?SizedBox.shrink():   Align(
          alignment: Alignment.topRight,
          child: RichText(
            text: TextSpan(
              style: t.body.copyWith(color: c.fg2),
              children: [
                TextSpan(text: "N 28.40"),
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Transform.translate(
                    offset: const Offset(0, -4), // adjust height here
                    child: Text(
                      "•",
                      style: t.body.copyWith(color: c.fg2),
                    ),
                  ),
                ),
                TextSpan(
                  text: "  •  ",
                  style: t.body.copyWith(color: c.fg2,fontSize: 20),
                ),
                TextSpan(text: "E 28.40"),
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Transform.translate(
                    offset: const Offset(0, -4), // adjust height here
                    child: Text(
                      "•",
                      style: t.body.copyWith(color: c.fg2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        layout.isLarge==false ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              logoAssetPath,
              height:50,
              fit: BoxFit.contain,
            ),
            SizedBox(height:  40),
            Align(
              alignment: Alignment.centerLeft ,
              child: Text(
                'GS1 TRACK & TRACE',
                style: t.mono.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  color: c.sig,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: textAlign,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment:
           Alignment.centerLeft ,
              child: Text(
                'Every package.\nEvery event.\nVerified.',
                style: t.h1.copyWith(
                  fontSize: 20,
                  height: 1.05,
                  color: c.fg0,
                ),

              ),
            ),
            const SizedBox(height: 16),
            Text(
              'A serialization & EPCIS platform for regulated supply chains. GTIN, GLN, SSCC and event-level visibility — at production scale.',
              style: t.body.copyWith(color: c.fg2,fontSize: 12),

            ),
          ],
        ):  Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      logoAssetPath,
                      height: 30 ,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: isLarge ? 56 : 40),
                    Align(
                      alignment:
                      textAlign == TextAlign.left ? Alignment.centerLeft : Alignment.center,
                      child: Text(
                        'GS1 TRACK & TRACE',
                        style: t.mono.copyWith(
                          fontSize: 16,
                          letterSpacing: 1.2,
                          color: c.sig,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: textAlign,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment:
                      textAlign == TextAlign.left ? Alignment.centerLeft : Alignment.center,
                      child: Text(
                        'Every package.\nEvery event.\nVerified.',
                        style: t.h1.copyWith(
                          fontSize: isLarge ? 74 : 46,
                          height: 1.05,
                          color: c.fg0,
                        ),
                        textAlign: textAlign,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'A serialization & EPCIS platform for regulated supply chains. GTIN, GLN, SSCC and event-level visibility — at production scale.',
                      style: t.body.copyWith(color: c.fg2,fontSize: 16),
                      textAlign: textAlign,
                    ),
                  ],
                ),
                Row
                  (
                  spacing: 20,
                  children: [
                    Text(
                      "GS1 EPCIS 2.0",
                      style: t.body.copyWith(color: c.fg2),
                      textAlign: textAlign,
                    ),
                    Container(height: 5,width: 5,
                      decoration: BoxDecoration(
                        color: c.fg2,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "CBV 2.0",
                      style: t.body.copyWith(color: c.fg2),
                      textAlign: textAlign,
                    ),
                    Container(height: 5,width: 5,
                      decoration: BoxDecoration(
                        color: c.fg2,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "DSCSA • EU FMD",
                      style: t.body.copyWith(color: c.fg2),
                      textAlign: textAlign,

                    ),
                  ],
                )

              ],
            ),
          ),
        ),
      ],
    );
  }
}