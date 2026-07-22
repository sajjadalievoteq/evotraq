import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';


class ProductionBatchSerialDateAssociationsCoreGroup extends StatelessWidget {
  const ProductionBatchSerialDateAssociationsCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.hasBatchNumberIndicator,
    required this.hasSerialNumberIndicator,
    required this.onBatchChanged,
    required this.onSerialChanged,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final String? hasBatchNumberIndicator;
  final String? hasSerialNumberIndicator;
  final ValueChanged<String?> onBatchChanged;
  final ValueChanged<String?> onSerialChanged;
  final bool showFieldSkeleton;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('batch_$hasBatchNumberIndicator'),
          initialValue: hasBatchNumberIndicator,
          decoration: const InputDecoration(
            labelText: GtinUiConstants.labelHasBatchNumberIndicator,
            helperText: GtinUiConstants.helperBatchIndicatorPharma,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: GtinUiConstants.batchSerialValueRequestedByLaw,
              child: Text(GtinUiConstants.batchSerialRequestedByLaw),
            ),
            DropdownMenuItem(
              value: GtinUiConstants.batchSerialValueNotRequestedButAllocated,
              child: Text(GtinUiConstants.batchSerialNotRequestedButAllocated),
            ),
            DropdownMenuItem(
              value: GtinUiConstants.batchSerialValueNotAllocated,
              child: Text(GtinUiConstants.batchSerialNotAllocated),
            ),
          ],
          validator: isReadOnly
              ? null
              : GtinFieldValidators.validateHasBatchNumberIndicator,
          onChanged: isReadOnly ? null : onBatchChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('serial_$hasSerialNumberIndicator'),
          initialValue: hasSerialNumberIndicator,
          decoration: const InputDecoration(
            labelText: GtinUiConstants.labelHasSerialNumberIndicator,
            helperText: GtinUiConstants.helperSerialIndicatorPharma,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: GtinUiConstants.batchSerialValueRequestedByLaw,
              child: Text(GtinUiConstants.batchSerialRequestedByLaw),
            ),
            DropdownMenuItem(
              value: GtinUiConstants.batchSerialValueNotRequestedButAllocated,
              child: Text(GtinUiConstants.batchSerialNotRequestedButAllocated),
            ),
            DropdownMenuItem(
              value: GtinUiConstants.batchSerialValueNotAllocated,
              child: Text(GtinUiConstants.batchSerialNotAllocated),
            ),
          ],
          validator: isReadOnly
              ? null
              : (v) => GtinFieldValidators.validateHasSerialNumberIndicator(
                  v,
                  batchIndicator: hasBatchNumberIndicator,
                ),
          onChanged: isReadOnly ? null : onSerialChanged,
        ),
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionProductionBatchSerialDateAssociations,
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
        ],
      ),
      child: body,
    );
  }
}
