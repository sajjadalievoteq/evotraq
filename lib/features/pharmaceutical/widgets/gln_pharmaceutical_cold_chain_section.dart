import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_date_field.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_numeric_range_fields.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_switch.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_text_field.dart';

class GlnPharmaceuticalColdChainSection extends StatelessWidget {
  const GlnPharmaceuticalColdChainSection({
    required this.coldStorageMinController,
    required this.coldStorageMaxController,
    required this.freezerMinController,
    required this.freezerMaxController,
    required this.crtMinController,
    required this.crtMaxController,
    required this.humidityMinController,
    required this.humidityMaxController,
    required this.gdpCertificationNumberController,
    required this.hasColdChainCapability,
    required this.hasFreezerCapability,
    required this.hasControlledRoomTemp,
    required this.hasHumidityControl,
    required this.gdpCertified,
    required this.gdpCertificationExpiry,
    required this.isEditing,
    required this.onColdChainCapabilityChanged,
    required this.onFreezerCapabilityChanged,
    required this.onControlledRoomTempChanged,
    required this.onHumidityControlChanged,
    required this.onGdpCertifiedChanged,
    required this.onGdpCertificationExpiryChanged,
    super.key,
  });

  final TextEditingController coldStorageMinController;
  final TextEditingController coldStorageMaxController;
  final TextEditingController freezerMinController;
  final TextEditingController freezerMaxController;
  final TextEditingController crtMinController;
  final TextEditingController crtMaxController;
  final TextEditingController humidityMinController;
  final TextEditingController humidityMaxController;
  final TextEditingController gdpCertificationNumberController;
  final bool hasColdChainCapability;
  final bool hasFreezerCapability;
  final bool hasControlledRoomTemp;
  final bool hasHumidityControl;
  final bool gdpCertified;
  final DateTime? gdpCertificationExpiry;
  final bool isEditing;
  final ValueChanged<bool> onColdChainCapabilityChanged;
  final ValueChanged<bool> onFreezerCapabilityChanged;
  final ValueChanged<bool> onControlledRoomTempChanged;
  final ValueChanged<bool> onHumidityControlChanged;
  final ValueChanged<bool> onGdpCertifiedChanged;
  final ValueChanged<DateTime?> onGdpCertificationExpiryChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardColdChainStorage,
      iconAsset: AppAssets.iconSparkle,
      children: [
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelColdChainCapability,
          value: hasColdChainCapability,
          onChanged: isEditing ? onColdChainCapabilityChanged : null,
        ),
        if (hasColdChainCapability) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalNumericRangeFields(
            minimumController: coldStorageMinController,
            maximumController: coldStorageMaxController,
            minimumLabel: GlnPharmaceuticalExtensionUiConstants.labelMinTempC,
            maximumLabel: GlnPharmaceuticalExtensionUiConstants.labelMaxTempC,
            isEditing: isEditing,
          ),
        ],
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelFreezerCapability,
          value: hasFreezerCapability,
          onChanged: isEditing ? onFreezerCapabilityChanged : null,
        ),
        if (hasFreezerCapability) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalNumericRangeFields(
            minimumController: freezerMinController,
            maximumController: freezerMaxController,
            minimumLabel:
                GlnPharmaceuticalExtensionUiConstants.labelFreezerMinC,
            maximumLabel:
                GlnPharmaceuticalExtensionUiConstants.labelFreezerMaxC,
            isEditing: isEditing,
          ),
        ],
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants
              .labelControlledRoomTemperature,
          value: hasControlledRoomTemp,
          onChanged: isEditing ? onControlledRoomTempChanged : null,
        ),
        if (hasControlledRoomTemp) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalNumericRangeFields(
            minimumController: crtMinController,
            maximumController: crtMaxController,
            minimumLabel: GlnPharmaceuticalExtensionUiConstants.labelCrtMinC,
            maximumLabel: GlnPharmaceuticalExtensionUiConstants.labelCrtMaxC,
            isEditing: isEditing,
          ),
        ],
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelHumidityControl,
          value: hasHumidityControl,
          onChanged: isEditing ? onHumidityControlChanged : null,
        ),
        if (hasHumidityControl) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalNumericRangeFields(
            minimumController: humidityMinController,
            maximumController: humidityMaxController,
            minimumLabel:
                GlnPharmaceuticalExtensionUiConstants.labelMinHumidityPct,
            maximumLabel:
                GlnPharmaceuticalExtensionUiConstants.labelMaxHumidityPct,
            isEditing: isEditing,
          ),
        ],
        const SizedBox(height: 12),
        GlnPharmaceuticalSwitch(
          label: GlnPharmaceuticalExtensionUiConstants.labelGdpCertified,
          value: gdpCertified,
          onChanged: isEditing ? onGdpCertifiedChanged : null,
        ),
        if (gdpCertified) ...[
          const SizedBox(height: 12),
          GlnPharmaceuticalTextField(
            controller: gdpCertificationNumberController,
            label: GlnPharmaceuticalExtensionUiConstants
                .labelGdpCertificationNumber,
            enabled: isEditing,
            maxLength: 50,
          ),
          const SizedBox(height: 12),
          GlnPharmaceuticalDateField(
            label: GlnPharmaceuticalExtensionUiConstants
                .labelGdpCertificationExpiry,
            value: gdpCertificationExpiry,
            onChanged: isEditing ? onGdpCertificationExpiryChanged : null,
          ),
        ],
      ],
    );
  }
}
