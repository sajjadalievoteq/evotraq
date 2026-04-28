import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class ProductionBatchSerialDateAssociationsCoreGroup extends StatefulWidget {
  const ProductionBatchSerialDateAssociationsCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Production, Batch, Serial & Date Associations'),
        DropdownButtonFormField<String>(
          initialValue: _hasBatchNumberIndicator,
          decoration: const InputDecoration(
            labelText: 'Has Batch Number Indicator',
    helperText: 'Required for traceability in pharmaceutical products',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'REQUESTED_BY_LAW',
              child: Text('REQUESTED BY LAW'),
            ),
            DropdownMenuItem(
              value: 'NOT_REQUESTED_BUT_ALLOCATED',
              child: Text('NOT REQUESTED BUT ALLOCATED'),
            ),
            DropdownMenuItem(
              value: 'NOT_ALLOCATED',
              child: Text('NOT ALLOCATED'),
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
            labelText: 'Has Serial Number Indicator',
            helperText: 'Required for pharmaceutical serialization and traceability',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'REQUESTED_BY_LAW',
              child: Text('REQUESTED BY LAW'),
            ),
            DropdownMenuItem(
              value: 'NOT_REQUESTED_BUT_ALLOCATED',
              child: Text('NOT REQUESTED BUT ALLOCATED'),
            ),
            DropdownMenuItem(
              value: 'NOT_ALLOCATED',
              child: Text('NOT ALLOCATED'),
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
  }
}

