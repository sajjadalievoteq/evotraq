import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/data/models/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/extensions/pharmaceutical_extension_widget.dart';
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
    required this.targetMarketCountry,
    this.pharmaceuticalExtension,
    this.tobaccoExtension,
    this.showFieldSkeleton = false,
  });

  final GlobalKey<PharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<TobaccoExtensionWidgetState> tobaccoExtensionKey;
  final String gtinCodeText;
  final String? routeGtinCode;
  final bool isEditing;
  final String? targetMarketCountry;
  final GTINPharmaceuticalExtension? pharmaceuticalExtension;
  final GTINTobaccoExtension? tobaccoExtension;
  final bool showFieldSkeleton;

  String? get _resolvedGtinCode {
    if (gtinCodeText.isNotEmpty) return gtinCodeText;
    return routeGtinCode;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final tobaccoUiAllowed =
            settings.isTobaccoMode && kTobaccoExtensionEnabled;

        final industryEnabled =
            settings.isPharmaceuticalMode || tobaccoUiAllowed;

        final Widget extension;
        if (settings.isPharmaceuticalMode) {
          extension = PharmaceuticalExtensionWidget(
            key: pharmaExtensionKey,
            gtinCode: _resolvedGtinCode,
            isEditing: isEditing,
            targetMarketCountry: targetMarketCountry,
            initialExtension: pharmaceuticalExtension,
          );
        } else if (tobaccoUiAllowed) {
          extension = TobaccoExtensionWidget(
            key: tobaccoExtensionKey,
            gtinCode: _resolvedGtinCode,
            isEditing: isEditing,
            initialExtension: tobaccoExtension,
          );
        } else {
          extension = const SizedBox.shrink();
        }

        if (!industryEnabled) return extension;

        return GtinFieldSkeletonMask(
          show: showFieldSkeleton,
          child: extension,
          skeletonBuilder: (c) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1, color: c),
              const SizedBox(height: 8),
              GtinSkeletonExtensionTile(color: c),
            ],
          ),
        );
      },
    );
  }
}
