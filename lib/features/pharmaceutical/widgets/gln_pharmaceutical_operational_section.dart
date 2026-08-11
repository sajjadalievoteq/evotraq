import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalOperationalSection extends StatelessWidget {
  const GlnPharmaceuticalOperationalSection({
    required this.receivingHoursController,
    required this.dispatchHoursController,
    required this.hasWeighbridge,
    required this.hasLoadingDock,
    required this.hasForkliftCapability,
    required this.canReceiveHazmat,
    required this.isEditing,
    required this.onWeighbridgeChanged,
    required this.onLoadingDockChanged,
    required this.onForkliftCapabilityChanged,
    required this.onReceiveHazmatChanged,
    super.key,
  });

  final TextEditingController receivingHoursController;
  final TextEditingController dispatchHoursController;
  final bool hasWeighbridge;
  final bool hasLoadingDock;
  final bool hasForkliftCapability;
  final bool canReceiveHazmat;
  final bool isEditing;
  final ValueChanged<bool> onWeighbridgeChanged;
  final ValueChanged<bool> onLoadingDockChanged;
  final ValueChanged<bool> onForkliftCapabilityChanged;
  final ValueChanged<bool> onReceiveHazmatChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardOperationalDetails,
      iconAsset: AppAssets.iconClock,
      children: [
        GlnPharmaceuticalTextField(
          controller: receivingHoursController,
          label: GlnPharmaceuticalExtensionUiConstants.labelReceivingHours,
          enabled: isEditing,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalTextField(
          controller: dispatchHoursController,
          label: GlnPharmaceuticalExtensionUiConstants.labelDispatchHours,
          enabled: isEditing,
          maxLength: 100,
        ),
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelHasWeighbridge,
          value: hasWeighbridge,
          onChanged: isEditing ? onWeighbridgeChanged : null,
        ),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelHasLoadingDock,
          value: hasLoadingDock,
          onChanged: isEditing ? onLoadingDockChanged : null,
        ),
        GlnPharmaceuticalSwitch(
          label:
              GlnPharmaceuticalExtensionUiConstants.labelHasForkliftCapability,
          value: hasForkliftCapability,
          onChanged: isEditing ? onForkliftCapabilityChanged : null,
        ),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelCanReceiveHazmat,
          value: canReceiveHazmat,
          onChanged: isEditing ? onReceiveHazmatChanged : null,
        ),
      ],
    );
  }
}
