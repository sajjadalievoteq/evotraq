import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_format.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart';
import 'package:traqtrace_app/features/tobacco/widgets/gln_tobacco_extension_widget.dart';

/// Industry-mode extension block (pharma or tobacco) below core GLN master fields.
class GlnIndustryExtensionsSection extends StatelessWidget {
  const GlnIndustryExtensionsSection({
    super.key,
    required this.glnCodeController,
    required this.gln,
    required this.isEditing,
    required this.pharmaExtensionKey,
    required this.tobaccoExtensionKey,
  });

  final TextEditingController glnCodeController;
  final GLN? gln;
  final bool isEditing;
  final GlobalKey<GLNPharmaceuticalExtensionWidgetState> pharmaExtensionKey;
  final GlobalKey<GLNTobaccoExtensionWidgetState> tobaccoExtensionKey;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemSettingsCubit, SystemSettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final fromPersisted = gln?.glnCode;
        final fromField =
            GlnFormat.stripGlnInput(glnCodeController.text);
        final currentGlnCode =
            (fromPersisted != null && fromPersisted.isNotEmpty)
                ? fromPersisted
                : (fromField.isNotEmpty ? fromField : null);

        if (settings.isPharmaceuticalMode) {
          return GLNPharmaceuticalExtensionWidget(
            key: pharmaExtensionKey,
            glnCode: currentGlnCode,
            isEditing: isEditing,
          );
        }

        if (settings.isTobaccoMode && kTobaccoExtensionEnabled) {
          return GLNTobaccoExtensionWidget(
            key: tobaccoExtensionKey,
            glnCode: currentGlnCode,
            isEditing: isEditing,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
