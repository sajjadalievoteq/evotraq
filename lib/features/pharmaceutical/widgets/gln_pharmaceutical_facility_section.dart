import 'package:traqtrace_app/data/models/gs1/gln/gln_pharmaceutical_types.dart';
import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_extension_ui_constants.dart';
import 'package:traqtrace_app/features/pharmaceutical/widgets/gln_pharmaceutical_section.dart';

class GlnPharmaceuticalFacilitySection extends StatelessWidget {
  const GlnPharmaceuticalFacilitySection({
    required this.facilityType,
    required this.isEditing,
    required this.onChanged,
    super.key,
  });

  final HealthcareFacilityType facilityType;
  final bool isEditing;
  final ValueChanged<HealthcareFacilityType> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlnPharmaceuticalSection(
      title: GlnPharmaceuticalExtensionUiConstants.cardHealthcareFacilityType,
      iconAsset: AppAssets.iconMedical,
      children: [
        DropdownButtonFormField<HealthcareFacilityType>(
          value: facilityType,
          dropdownColor: context.colors.surface,
          decoration: const InputDecoration(
            labelText: GlnPharmaceuticalExtensionUiConstants.labelFacilityType,
            border: OutlineInputBorder(),
          ),
          items: HealthcareFacilityType.values.map((type) {
            return DropdownMenuItem(value: type, child: Text(type.displayName));
          }).toList(),
          onChanged: isEditing
              ? (value) {
                  if (value != null) onChanged(value);
                }
              : null,
        ),
      ],
    );
  }
}
