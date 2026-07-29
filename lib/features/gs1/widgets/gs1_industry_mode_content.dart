import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/system_settings_model.dart';

class Gs1IndustryModeContent extends StatelessWidget {
  const Gs1IndustryModeContent({
    super.key,
    required this.settings,
    required this.buildPharmaceutical,
  });

  final SystemSettings settings;
  final Widget Function(BuildContext context) buildPharmaceutical;

  @override
  Widget build(BuildContext context) {
    if (settings.isPharmaceuticalMode) {
      return buildPharmaceutical(context);
    }
    return const SizedBox.shrink();
  }
}
