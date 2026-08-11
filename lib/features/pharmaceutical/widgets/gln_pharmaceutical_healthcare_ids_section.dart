import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalHealthcareIdsSection extends StatelessWidget {
  const GlnPharmaceuticalHealthcareIdsSection({
    required this.npiNumberController,
    required this.ncpdpIdController,
    required this.medicareProviderNumberController,
    required this.medicaidProviderNumberController,
    required this.isEditing,
    super.key,
  });

  final TextEditingController npiNumberController;
  final TextEditingController ncpdpIdController;
  final TextEditingController medicareProviderNumberController;
  final TextEditingController medicaidProviderNumberController;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardHealthcareIdentifiers,
      iconAsset: AppAssets.iconNumbers,
      children: [
        GlnPharmaceuticalTextField(
          controller: npiNumberController,
          label: GlnPharmaceuticalExtensionUiConstants.labelNpiNumber,
          enabled: isEditing,
          maxLength: 15,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: ncpdpIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelNcpdpId,
          enabled: isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: medicareProviderNumberController,
          label:
              GlnPharmaceuticalExtensionUiConstants.labelMedicareProviderNumber,
          enabled: isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: medicaidProviderNumberController,
          label:
              GlnPharmaceuticalExtensionUiConstants.labelMedicaidProviderNumber,
          enabled: isEditing,
          maxLength: 20,
        ),
      ],
    );
  }
}
