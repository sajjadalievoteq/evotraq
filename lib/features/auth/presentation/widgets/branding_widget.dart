import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    this.logoAssetPath = Constants.logoImage,
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
    final logoSize = prominent && layout.isLarge
        ? (layout.width * 0.11).clamp(2180.0, 2200.0)
        : layout.resolve(
      compact: 150.0,
      medium: 200.0,
      expanded: 340.0,
      large: 300.0,
    );

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(logoAssetPath),
        ),
      ),
    );
  }
}