import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalClinicalTrialSection extends StatelessWidget {
  const GlnPharmaceuticalClinicalTrialSection({
    required this.phaseAuthorizedController,
    required this.irbApprovalNumberController,
    required this.isClinicalTrialSite,
    required this.irbApprovalExpiry,
    required this.isEditing,
    required this.onClinicalTrialSiteChanged,
    required this.onIrbApprovalExpiryChanged,
    super.key,
  });

  final TextEditingController phaseAuthorizedController;
  final TextEditingController irbApprovalNumberController;
  final bool isClinicalTrialSite;
  final DateTime? irbApprovalExpiry;
  final bool isEditing;
  final ValueChanged<bool> onClinicalTrialSiteChanged;
  final ValueChanged<DateTime?> onIrbApprovalExpiryChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardClinicalTrialSite,
      iconAsset: AppAssets.iconScience,
      children: [
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants
              .labelClinicalTrialSiteSwitch,
          value: isClinicalTrialSite,
          onChanged: isEditing ? onClinicalTrialSiteChanged : null,
        ),
        if (isClinicalTrialSite) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalTextField(
            controller: phaseAuthorizedController,
            label: GlnPharmaceuticalExtensionUiConstants
                .labelClinicalTrialPhaseAuthorized,
            enabled: isEditing,
            hint: GlnPharmaceuticalExtensionUiConstants.hintClinicalTrialPhase,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          GlnPharmaceuticalTextField(
            controller: irbApprovalNumberController,
            label: GlnPharmaceuticalExtensionUiConstants.labelIrbApprovalNumber,
            enabled: isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          GlnPharmaceuticalDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelIrbApprovalExpiry,
            value: irbApprovalExpiry,
            onChanged: isEditing ? onIrbApprovalExpiryChanged : null,
          ),
        ],
      ],
    );
  }
}
