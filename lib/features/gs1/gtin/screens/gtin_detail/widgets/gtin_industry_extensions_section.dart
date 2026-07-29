import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/data/models/gs1/gtin/gtin_pharmaceutical_extension_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/extensions/pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_industry_mode_content.dart';

class GtinIndustryExtensionsSection extends StatelessWidget {
  const GtinIndustryExtensionsSection({
    super.key,
    required this.pharmaExtensionKey,
    required this.gtinCodeText,
    required this.routeGtinCode,
    required this.isEditing,
    required this.targetMarketCountry,
    this.pharmaceuticalExtension,
    this.deferIndustryExtensionNetworkFetch = false,
    this.industryExtensionFetchResolved = true,
    this.showFieldSkeleton = false,
  });

  final GlobalKey<PharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final String gtinCodeText;
  final String? routeGtinCode;
  final bool isEditing;
  final String? targetMarketCountry;
  final GTINPharmaceuticalExtension? pharmaceuticalExtension;

  final bool deferIndustryExtensionNetworkFetch;
  final bool industryExtensionFetchResolved;

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
        final industryEnabled = settings.isPharmaceuticalMode;

        final scopeKey = _resolvedGtinCode ?? '';

        final extension = Gs1IndustryModeContent(
          settings: settings,
          buildPharmaceutical: (_) => KeyedSubtree(
            key: ValueKey<String>('gtin_pharma_$scopeKey'),
            child: PharmaceuticalExtensionWidget(
              key: pharmaExtensionKey,
              gtinCode: _resolvedGtinCode,
              isEditing: isEditing,
              targetMarketCountry: targetMarketCountry,
              initialExtension: pharmaceuticalExtension,
              deferInitialExtensionFetch: deferIndustryExtensionNetworkFetch,
              extensionFetchResolved: industryExtensionFetchResolved,
            ),
          ),
        );

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
