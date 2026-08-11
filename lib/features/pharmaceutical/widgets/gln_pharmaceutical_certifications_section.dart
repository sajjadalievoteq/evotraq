import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalCertificationsSection extends StatelessWidget {
  const GlnPharmaceuticalCertificationsSection({
    required this.isoTypeController,
    required this.isoNumberController,
    required this.jcahoNumberController,
    required this.isIsoCertified,
    required this.isoExpiry,
    required this.isJcahoAccredited,
    required this.jcahoExpiry,
    required this.isEditing,
    required this.onIsoCertifiedChanged,
    required this.onIsoExpiryChanged,
    required this.onJcahoAccreditedChanged,
    required this.onJcahoExpiryChanged,
    super.key,
  });

  final TextEditingController isoTypeController;
  final TextEditingController isoNumberController;
  final TextEditingController jcahoNumberController;
  final bool isIsoCertified;
  final DateTime? isoExpiry;
  final bool isJcahoAccredited;
  final DateTime? jcahoExpiry;
  final bool isEditing;
  final ValueChanged<bool> onIsoCertifiedChanged;
  final ValueChanged<DateTime?> onIsoExpiryChanged;
  final ValueChanged<bool> onJcahoAccreditedChanged;
  final ValueChanged<DateTime?> onJcahoExpiryChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants
          .cardCertificationsAccreditations,
      iconAsset: AppAssets.iconWorkspacePremium,
      children: [
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelIsoCertified,
          value: isIsoCertified,
          onChanged: isEditing ? onIsoCertifiedChanged : null,
        ),
        if (isIsoCertified) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalTextField(
            controller: isoTypeController,
            label:
                GlnPharmaceuticalExtensionUiConstants.labelIsoCertificationType,
            enabled: isEditing,
            hint:
                GlnPharmaceuticalExtensionUiConstants.hintIsoCertificationType,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          GlnPharmaceuticalTextField(
            controller: isoNumberController,
            label: GlnPharmaceuticalExtensionUiConstants
                .labelIsoCertificationNumber,
            enabled: isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          GlnPharmaceuticalDateField(
            label: GlnPharmaceuticalExtensionUiConstants
                .labelIsoCertificationExpiry,
            value: isoExpiry,
            onChanged: isEditing ? onIsoExpiryChanged : null,
          ),
        ],
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelJcahoAccredited,
          value: isJcahoAccredited,
          onChanged: isEditing ? onJcahoAccreditedChanged : null,
        ),
        if (isJcahoAccredited) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalTextField(
            controller: jcahoNumberController,
            label: GlnPharmaceuticalExtensionUiConstants
                .labelJcahoAccreditationNumber,
            enabled: isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          GlnPharmaceuticalDateField(
            label: GlnPharmaceuticalExtensionUiConstants
                .labelJcahoAccreditationExpiry,
            value: jcahoExpiry,
            onChanged: isEditing ? onJcahoExpiryChanged : null,
          ),
        ],
      ],
    );
  }
}
