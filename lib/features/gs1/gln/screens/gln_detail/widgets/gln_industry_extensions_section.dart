import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_skeleton_mask.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_skeleton_extension_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_industry_mode_content.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';

class GlnIndustryExtensionsSection extends StatelessWidget {
  const GlnIndustryExtensionsSection({
    super.key,
    required this.glnCodeController,
    required this.gln,
    required this.isEditing,
    this.showFieldSkeleton = false,
    required this.pharmaExtensionKey,
  });

  final TextEditingController glnCodeController;
  final GLN? gln;
  final bool isEditing;
  final bool showFieldSkeleton;
  final GlobalKey<GLNPharmaceuticalExtensionWidgetState> pharmaExtensionKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final industryEnabled = settings.isPharmaceuticalMode;

        final fromPersisted = gln?.glnCode;
        final fromField = GlnFormat.stripGlnInput(glnCodeController.text);
        final currentGlnCode =
            (fromPersisted != null && fromPersisted.isNotEmpty)
            ? fromPersisted
            : (fromField.isNotEmpty ? fromField : null);

        final scopeKey = currentGlnCode ?? '';

        final extension = Gs1IndustryModeContent(
          settings: settings,
          buildPharmaceutical: (_) => KeyedSubtree(
            key: ValueKey<String>('gln_pharma_$scopeKey'),
            child: GLNPharmaceuticalExtensionWidget(
              key: pharmaExtensionKey,
              glnCode: currentGlnCode,
              isEditing: isEditing,
              initialExtension: gln?.pharmaceuticalExtension,
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
