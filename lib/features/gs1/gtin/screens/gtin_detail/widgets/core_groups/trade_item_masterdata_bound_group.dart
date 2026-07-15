import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/utils/gtin_detail_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';

/// Presenter — controllers/values owned by [GTINDetailScreen].
class TradeItemMasterdataBoundGroup extends StatelessWidget {
  const TradeItemMasterdataBoundGroup({
    super.key,
    required this.isReadOnly,
    required this.brandNameController,
    required this.manufacturerController,
    required this.unitDescriptorController,
    required this.packSizeController,
    required this.status,
    required this.onUnitDescriptorChanged,
    required this.onStatusChanged,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final TextEditingController brandNameController;
  final TextEditingController manufacturerController;
  final TextEditingController unitDescriptorController;
  final TextEditingController packSizeController;
  final String? status;
  final ValueChanged<String?> onUnitDescriptorChanged;
  final ValueChanged<String?> onStatusChanged;
  final bool showFieldSkeleton;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gs1ValidatedField(
          controller: brandNameController,
          fieldName: 'brand_name',
          label: GtinUiConstants.labelBrandNameRequired,
          readOnly: isReadOnly,
          maxLength: 70,
          validator: GtinFieldValidators.validateProductName,
        ),
        const SizedBox(height: 16),
        Gs1ValidatedField(
          controller: manufacturerController,
          fieldName: 'manufacturer',
          label: GtinUiConstants.labelManufacturerRequired,
          readOnly: isReadOnly,
          maxLength: 200,
          validator: GtinFieldValidators.validateManufacturer,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey(
            'ud_${unitDescriptorController.text.isEmpty ? '' : unitDescriptorController.text}',
          ),
          initialValue: unitDescriptorController.text.isEmpty
              ? null
              : unitDescriptorController.text,
          decoration: const InputDecoration(
            labelText: GtinUiConstants.labelTradeItemUnitDescriptor,
            helperText: GtinUiConstants.helperGdsnUnitDescriptor,
          ),
          items: GtinDetailConstants.unitDescriptorOptions
              .map(
                (level) => DropdownMenuItem(value: level, child: Text(level)),
              )
              .toList(),
          validator: isReadOnly
              ? null
              : GtinFieldValidators.validateUnitDescriptor,
          onChanged: isReadOnly ? null : onUnitDescriptorChanged,
        ),
        const SizedBox(height: 16),
        Gs1ValidatedField(
          controller: packSizeController,
          fieldName: 'packSize',
          label: GtinUiConstants.labelPackSize,
          helperText: GtinUiConstants.helperPackSizeExamples,
          readOnly: isReadOnly,
          validator: GtinFieldValidators.validatePackSizeOptionalInt,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey('st_$status'),
          initialValue: status,
          decoration: const InputDecoration(
            labelText: GtinUiConstants.labelProductLifecycleStatus,
          ),
          items: GtinDetailConstants.statusOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          validator:
              isReadOnly ? null : GtinFieldValidators.validateProductStatus,
          onChanged: isReadOnly ? null : onStatusChanged,
        ),
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionTradeItemData,
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 16),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 16),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 16),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 16),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
      child: body,
    );
  }
}
