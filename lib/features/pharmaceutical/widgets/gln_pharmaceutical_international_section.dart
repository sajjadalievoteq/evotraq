import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalInternationalSection extends StatelessWidget {
  const GlnPharmaceuticalInternationalSection({
    required this.emaSiteIdController,
    required this.pmdaSiteIdController,
    required this.anvisaSiteIdController,
    required this.nmpaSiteIdController,
    required this.isEditing,
    super.key,
  });

  final TextEditingController emaSiteIdController;
  final TextEditingController pmdaSiteIdController;
  final TextEditingController anvisaSiteIdController;
  final TextEditingController nmpaSiteIdController;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title:
          GlnPharmaceuticalExtensionUiConstants.cardInternationalRegulatoryIds,
      iconAsset: AppAssets.iconGlobe,
      children: [
        GlnPharmaceuticalTextField(
          controller: emaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelEmaSiteId,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: pmdaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelPmdaSiteId,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: anvisaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelAnvisaSiteId,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: nmpaSiteIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelNmpaSiteId,
          enabled: isEditing,
          maxLength: 50,
        ),
      ],
    );
  }
}
