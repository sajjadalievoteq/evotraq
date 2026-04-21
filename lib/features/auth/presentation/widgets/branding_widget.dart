import 'package:flutter/cupertino.dart';

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
        ? (layout.width * 0.11).clamp(360.0, 420.0)
        : layout.resolve(
      compact: 80.0,
      medium: 100.0,
      expanded: 130.0,
      large: 120.0,
    );

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Image.asset(
        logoAssetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}