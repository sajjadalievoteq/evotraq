import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalDeaSection extends StatelessWidget {
  const GlnPharmaceuticalDeaSection({
    required this.registrationNumberController,
    required this.scheduleAuthorizationController,
    required this.businessActivityController,
    required this.registrationExpiry,
    required this.isEditing,
    required this.onRegistrationExpiryChanged,
    super.key,
  });

  final TextEditingController registrationNumberController;
  final TextEditingController scheduleAuthorizationController;
  final TextEditingController businessActivityController;
  final DateTime? registrationExpiry;
  final bool isEditing;
  final ValueChanged<DateTime?> onRegistrationExpiryChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardDeaRegistration,
      iconAsset: AppAssets.iconSecurity,
      children: [
        GlnPharmaceuticalTextField(
          controller: registrationNumberController,
          label:
              GlnPharmaceuticalExtensionUiConstants.labelDeaRegistrationNumber,
          enabled: isEditing,
          maxLength: 20,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalDateField(
          label:
              GlnPharmaceuticalExtensionUiConstants.labelDeaRegistrationExpiry,
          value: registrationExpiry,
          onChanged: isEditing ? onRegistrationExpiryChanged : null,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: scheduleAuthorizationController,
          label: GlnPharmaceuticalExtensionUiConstants
              .labelDeaScheduleAuthorization,
          enabled: isEditing,
          hint: GlnPharmaceuticalExtensionUiConstants.hintDeaSchedule,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: businessActivityController,
          label: GlnPharmaceuticalExtensionUiConstants.labelDeaBusinessActivity,
          enabled: isEditing,
          maxLength: 100,
        ),
      ],
    );
  }
}
