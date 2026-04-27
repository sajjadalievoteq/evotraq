import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/pharmaceutical/models/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/tobacco/models/gtin_tobacco_extension_model.dart';
import 'package:traqtrace_app/features/tobacco/widgets/tobacco_extension_widget.dart';

/// Pharma or tobacco extension blocks driven by [SystemSettingsCubit] industry mode.
class GtinIndustryExtensionsSection extends StatelessWidget {
  const GtinIndustryExtensionsSection({
    super.key,
    required this.pharmaExtensionKey,
    required this.tobaccoExtensionKey,
    required this.gtinCodeText,
    required this.routeGtinCode,
    required this.isEditing,
    this.pharmaceuticalExtension,
    this.tobaccoExtension,
  });

  final GlobalKey<PharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<TobaccoExtensionWidgetState> tobaccoExtensionKey;
  final String gtinCodeText;
  final String? routeGtinCode;
  final bool isEditing;
  final GTINPharmaceuticalExtension? pharmaceuticalExtension;
  final GTINTobaccoExtension? tobaccoExtension;

  String? get _resolvedGtinCode {
    if (gtinCodeText.isNotEmpty) return gtinCodeText;
    return routeGtinCode;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, settingsState) {
        return settingsState.settings.isPharmaceuticalMode
            ? PharmaceuticalExtensionWidget(
                key: pharmaExtensionKey,
                gtinCode: _resolvedGtinCode,
                isEditing: isEditing,
                initialExtension: pharmaceuticalExtension,
              )
            : TobaccoExtensionWidget(
                key: tobaccoExtensionKey,
                gtinCode: _resolvedGtinCode,
                isEditing: isEditing,
                initialExtension: tobaccoExtension,
              );
      },
    );
  }
}
