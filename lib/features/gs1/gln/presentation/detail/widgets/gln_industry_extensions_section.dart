import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_industry_mode_content.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/tobacco/widgets/gln_tobacco_extension_widget.dart';

/// Industry-mode extension block (pharma or tobacco) below core GLN master fields.
class GlnIndustryExtensionsSection extends StatelessWidget {
  const GlnIndustryExtensionsSection({
    super.key,
    required this.glnCodeController,
    required this.gln,
    required this.isEditing,
    this.showFieldSkeleton = false,
    required this.pharmaExtensionKey,
    required this.tobaccoExtensionKey,
  });

  final TextEditingController glnCodeController;
  final GLN? gln;
  final bool isEditing;
  final bool showFieldSkeleton;
  final GlobalKey<GLNPharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<GLNTobaccoExtensionWidgetState> tobaccoExtensionKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final tobaccoUiAllowed =
            settings.isTobaccoMode && kTobaccoExtensionEnabled;
        final industryEnabled =
            settings.isPharmaceuticalMode || tobaccoUiAllowed;

        final fromPersisted = gln?.glnCode;
        final fromField =
            GlnFormat.stripGlnInput(glnCodeController.text);
        final currentGlnCode =
            (fromPersisted != null && fromPersisted.isNotEmpty)
                ? fromPersisted
                : (fromField.isNotEmpty ? fromField : null);

        final extension = Gs1IndustryModeContent(
          settings: settings,
          buildPharmaceutical: (_) => GLNPharmaceuticalExtensionWidget(
            key: pharmaExtensionKey,
            glnCode: currentGlnCode,
            isEditing: isEditing,
            initialExtension: gln?.pharmaceuticalExtension,
          ),
          buildTobacco: (_) => GLNTobaccoExtensionWidget(
            key: tobaccoExtensionKey,
            glnCode: currentGlnCode,
            isEditing: isEditing,
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
