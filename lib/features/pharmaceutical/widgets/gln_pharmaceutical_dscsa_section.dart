import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalDscsaSection extends StatelessWidget {
  const GlnPharmaceuticalDscsaSection({
    required this.interoperabilitySystemController,
    required this.isDscsaCompliant,
    required this.complianceDate,
    required this.hasSerializationCapability,
    required this.hasAggregationCapability,
    required this.isEditing,
    required this.onDscsaCompliantChanged,
    required this.onComplianceDateChanged,
    required this.onSerializationCapabilityChanged,
    required this.onAggregationCapabilityChanged,
    super.key,
  });

  final TextEditingController interoperabilitySystemController;
  final bool isDscsaCompliant;
  final DateTime? complianceDate;
  final bool hasSerializationCapability;
  final bool hasAggregationCapability;
  final bool isEditing;
  final ValueChanged<bool> onDscsaCompliantChanged;
  final ValueChanged<DateTime?> onComplianceDateChanged;
  final ValueChanged<bool> onSerializationCapabilityChanged;
  final ValueChanged<bool> onAggregationCapabilityChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardDscsaCompliance,
      iconAsset: AppAssets.iconVerified,
      children: [
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelDscsaCompliant,
          value: isDscsaCompliant,
          onChanged: isEditing ? onDscsaCompliantChanged : null,
        ),
        if (isDscsaCompliant) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalDateField(
            label:
                GlnPharmaceuticalExtensionUiConstants.labelDscsaComplianceDate,
            value: complianceDate,
            onChanged: isEditing ? onComplianceDateChanged : null,
          ),
        ],
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants
              .labelSerializationCapability,
          value: hasSerializationCapability,
          onChanged: isEditing ? onSerializationCapabilityChanged : null,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label:
              GlnPharmaceuticalExtensionUiConstants.labelAggregationCapability,
          value: hasAggregationCapability,
          onChanged: isEditing ? onAggregationCapabilityChanged : null,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: interoperabilitySystemController,
          label:
              GlnPharmaceuticalExtensionUiConstants.labelInteroperabilitySystem,
          enabled: isEditing,
          maxLength: 200,
        ),
      ],
    );
  }
}
