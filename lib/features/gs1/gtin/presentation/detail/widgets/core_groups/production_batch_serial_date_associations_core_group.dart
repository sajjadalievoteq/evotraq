import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

class ProductionBatchSerialDateAssociationsCoreGroup extends StatefulWidget {
  const ProductionBatchSerialDateAssociationsCoreGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

  @override
  State<ProductionBatchSerialDateAssociationsCoreGroup> createState() =>
      ProductionBatchSerialDateAssociationsCoreGroupState();
}

class ProductionBatchSerialDateAssociationsCoreGroupState
    extends State<ProductionBatchSerialDateAssociationsCoreGroup> {
  // Store backend-compatible codes; display space-separated labels.
  String? _hasBatchNumberIndicator = 'REQUESTED_BY_LAW';
  String? _hasSerialNumberIndicator = 'REQUESTED_BY_LAW';

  String? get hasBatchNumberIndicator => _hasBatchNumberIndicator;
  String? get hasSerialNumberIndicator => _hasSerialNumberIndicator;

  void setFromGtin({
    required String? hasBatchNumberIndicator,
    required String? hasSerialNumberIndicator,
  }) {
    _hasBatchNumberIndicator = (hasBatchNumberIndicator ?? 'REQUESTED_BY_LAW').trim();
    _hasSerialNumberIndicator =
        (hasSerialNumberIndicator ?? 'REQUESTED_BY_LAW').trim();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(
          GtinUiConstants.sectionProductionBatchSerialDateAssociations,
        ),
        DropdownButtonFormField<String>(
          initialValue: _hasBatchNumberIndicator,
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
          validator:
              widget.isReadOnly ? null : GtinFieldValidators.validateHasBatchNumberIndicator,
          onChanged: widget.isReadOnly
              ? null
              : (v) => setState(() => _hasBatchNumberIndicator = v),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _hasSerialNumberIndicator,
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
          validator: widget.isReadOnly
              ? null
              : (v) => GtinFieldValidators.validateHasSerialNumberIndicator(
                    v,
                    batchIndicator: _hasBatchNumberIndicator,
                  ),
          onChanged: widget.isReadOnly
              ? null
              : (v) => setState(() => _hasSerialNumberIndicator = v),
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(
          GtinUiConstants.sectionProductionBatchSerialDateAssociations,
        ),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
        ],
      ),
    );
  }
}

