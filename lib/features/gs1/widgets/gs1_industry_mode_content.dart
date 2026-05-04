import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';

/// Picks pharmaceutical vs tobacco child based on [settings] (same rules for GTIN/GLN).
class Gs1IndustryModeContent extends StatelessWidget {
  const Gs1IndustryModeContent({
    super.key,
    required this.settings,
    required this.buildPharmaceutical,
    required this.buildTobacco,
  });

  final SystemSettings settings;
  final Widget Function(BuildContext context) buildPharmaceutical;
  final Widget Function(BuildContext context) buildTobacco;

  @override
  Widget build(BuildContext context) {
    final tobaccoUiAllowed =
        settings.isTobaccoMode && kTobaccoExtensionEnabled;
    if (settings.isPharmaceuticalMode) {
      return buildPharmaceutical(context);
    }
    if (tobaccoUiAllowed) {
      return buildTobacco(context);
    }
    return const SizedBox.shrink();
  }
}
