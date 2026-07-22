import 'package:flutter/material.dart';
import 'package:traqtrace_app/data/models/gs1/gln/gln_model.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/sgtin/widgets/sgtin_info_row.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/core/widgets/gln_selector.dart';


class InformationProviderManufacturerCoreGroup extends StatelessWidget {
  const InformationProviderManufacturerCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.informationProviderNameController,
    required this.informationProviderGln,
    required this.manufacturerGln,
    required this.onInformationProviderGlnChanged,
    required this.onManufacturerGlnChanged,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final TextEditingController informationProviderNameController;
  final GLN? informationProviderGln;
  final GLN? manufacturerGln;
  final ValueChanged<GLN?> onInformationProviderGlnChanged;
  final ValueChanged<GLN?> onManufacturerGlnChanged;

  String? _glnDisplay(GLN? gln) {
    if (gln == null) return null;
    final code = gln.glnCode.trim();
    if (code.isEmpty) return null;
    return '$code – ${gln.locationName}';
  }

  String? get _informationProviderName {
    final t = informationProviderNameController.text.trim();
    return t.isEmpty ? null : t;
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isReadOnly) ...[
          SgtinInfoRow(
            GtinUiConstants.labelInformationProviderGln,
            _glnDisplay(informationProviderGln),
          ),
          const SizedBox(height: 12),
          SgtinInfoRow(
            'Information Provider Name',
            _informationProviderName,
          ),
          const SizedBox(height: 12),
          SgtinInfoRow(
            GtinUiConstants.labelManufacturerGlnField,
            _glnDisplay(manufacturerGln),
          ),
        ] else ...[
          GLNSelector(
            label: GtinUiConstants.labelInformationProviderGln,
            hintText: 'Search and select information provider location',
            initialValue: informationProviderGln,
            onChanged: onInformationProviderGlnChanged,
          ),
          const SizedBox(height: 12),
          Gs1ValidatedField(
            controller: informationProviderNameController,
            fieldName: 'information_provider_name',
            label: 'Information Provider Name',
            readOnly: isReadOnly,
            maxLength: 200,
            validator: GtinFieldValidators.validateInformationProviderName,
          ),
          const SizedBox(height: 12),
          GLNSelector(
            label: GtinUiConstants.labelManufacturerGlnField,
            hintText: 'Search and select manufacturer location',
            initialValue: manufacturerGln,
            onChanged: onManufacturerGlnChanged,
          ),
        ],
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionInformationProviderManufacturer,
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
        ],
      ),
      child: body,
    );
  }
}
