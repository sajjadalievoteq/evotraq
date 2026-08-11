import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalFdaSection extends StatelessWidget {
  const GlnPharmaceuticalFdaSection({
    required this.establishmentIdController,
    required this.registrationNumberController,
    required this.establishmentTypeController,
    required this.registrationDate,
    required this.registrationExpiry,
    required this.isEditing,
    required this.onRegistrationDateChanged,
    required this.onRegistrationExpiryChanged,
    super.key,
  });

  final TextEditingController establishmentIdController;
  final TextEditingController registrationNumberController;
  final TextEditingController establishmentTypeController;
  final DateTime? registrationDate;
  final DateTime? registrationExpiry;
  final bool isEditing;
  final ValueChanged<DateTime?> onRegistrationDateChanged;
  final ValueChanged<DateTime?> onRegistrationExpiryChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardFdaEstablishment,
      iconAsset: AppAssets.iconVerified,
      children: [
        GlnPharmaceuticalTextField(
          controller: establishmentIdController,
          label: GlnPharmaceuticalExtensionUiConstants.labelFdaEstablishmentId,
          enabled: isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: registrationNumberController,
          label:
              GlnPharmaceuticalExtensionUiConstants.labelFdaRegistrationNumber,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: establishmentTypeController,
          label:
              GlnPharmaceuticalExtensionUiConstants.labelFdaEstablishmentType,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GlnPharmaceuticalDateField(
                label:
                    GlnPharmaceuticalExtensionUiConstants.labelRegistrationDate,
                value: registrationDate,
                onChanged: isEditing ? onRegistrationDateChanged : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlnPharmaceuticalDateField(
                label: GlnPharmaceuticalExtensionUiConstants
                    .labelRegistrationExpiry,
                value: registrationExpiry,
                onChanged: isEditing ? onRegistrationExpiryChanged : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
