import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalWholesaleSection extends StatelessWidget {
  const GlnPharmaceuticalWholesaleSection({
    required this.licenseNumberController,
    required this.vawdAccreditationNumberController,
    required this.licenseExpiry,
    required this.isAuthorizedTradingPartner,
    required this.atpVerificationDate,
    required this.vawdAccredited,
    required this.vawdExpiryDate,
    required this.isEditing,
    required this.onLicenseExpiryChanged,
    required this.onAuthorizedTradingPartnerChanged,
    required this.onAtpVerificationDateChanged,
    required this.onVawdAccreditedChanged,
    required this.onVawdExpiryDateChanged,
    super.key,
  });

  final TextEditingController licenseNumberController;
  final TextEditingController vawdAccreditationNumberController;
  final DateTime? licenseExpiry;
  final bool isAuthorizedTradingPartner;
  final DateTime? atpVerificationDate;
  final bool vawdAccredited;
  final DateTime? vawdExpiryDate;
  final bool isEditing;
  final ValueChanged<DateTime?> onLicenseExpiryChanged;
  final ValueChanged<bool> onAuthorizedTradingPartnerChanged;
  final ValueChanged<DateTime?> onAtpVerificationDateChanged;
  final ValueChanged<bool> onVawdAccreditedChanged;
  final ValueChanged<DateTime?> onVawdExpiryDateChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardWholesaleDistribution,
      iconAsset: NavIcons.logistics,
      children: [
        GlnPharmaceuticalTextField(
          controller: licenseNumberController,
          label:
              GlnPharmaceuticalExtensionUiConstants.labelWholesaleLicenseNumber,
          enabled: isEditing,
          maxLength: 50,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalDateField(
          label:
              GlnPharmaceuticalExtensionUiConstants.labelWholesaleLicenseExpiry,
          value: licenseExpiry,
          onChanged: isEditing ? onLicenseExpiryChanged : null,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants
              .labelAuthorizedTradingPartner,
          value: isAuthorizedTradingPartner,
          onChanged: isEditing ? onAuthorizedTradingPartnerChanged : null,
        ),
        if (isAuthorizedTradingPartner) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalDateField(
            label:
                GlnPharmaceuticalExtensionUiConstants.labelAtpVerificationDate,
            value: atpVerificationDate,
            onChanged: isEditing ? onAtpVerificationDateChanged : null,
          ),
        ],
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelVawdAccredited,
          value: vawdAccredited,
          onChanged: isEditing ? onVawdAccreditedChanged : null,
        ),
        if (vawdAccredited) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalTextField(
            controller: vawdAccreditationNumberController,
            label: GlnPharmaceuticalExtensionUiConstants
                .labelVawdAccreditationNumber,
            enabled: isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          GlnPharmaceuticalDateField(
            label: GlnPharmaceuticalExtensionUiConstants.labelVawdExpiryDate,
            value: vawdExpiryDate,
            onChanged: isEditing ? onVawdExpiryDateChanged : null,
          ),
        ],
      ],
    );
  }
}
