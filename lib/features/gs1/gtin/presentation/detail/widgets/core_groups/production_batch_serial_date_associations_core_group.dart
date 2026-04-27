import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class ProductionBatchSerialDateAssociationsCoreGroup extends StatefulWidget {
  const ProductionBatchSerialDateAssociationsCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<ProductionBatchSerialDateAssociationsCoreGroup> createState() =>
      _ProductionBatchSerialDateAssociationsCoreGroupState();
}

class _ProductionBatchSerialDateAssociationsCoreGroupState
    extends State<ProductionBatchSerialDateAssociationsCoreGroup> {
  // Doc (Tables 79-80): REQUESTED BY LAW / NOT REQUESTED BUT ALLOCATED / NOT ALLOCATED
  String? _hasBatchNumberIndicator = 'REQUESTED BY LAW';
  String? _hasSerialNumberIndicator = 'REQUESTED BY LAW';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget sectionLabel(String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sectionLabel('8. Production, Batch, Serial & Date Associations (Core)'),
        DropdownButtonFormField<String>(
          initialValue: _hasBatchNumberIndicator,
          decoration: const InputDecoration(
            labelText: 'Has Batch Number Indicator',
            helperText:
                'Doc: default REQUESTED BY LAW for pharma; drives AI(10) encoding.',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'REQUESTED BY LAW',
              child: Text('REQUESTED BY LAW'),
            ),
            DropdownMenuItem(
              value: 'NOT REQUESTED BUT ALLOCATED',
              child: Text('NOT REQUESTED BUT ALLOCATED'),
            ),
            DropdownMenuItem(
              value: 'NOT ALLOCATED',
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
            helperText:
                'Doc: default REQUESTED BY LAW for pharma; drives AI(21)/SGTIN.',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'REQUESTED BY LAW',
              child: Text('REQUESTED BY LAW'),
            ),
            DropdownMenuItem(
              value: 'NOT REQUESTED BUT ALLOCATED',
              child: Text('NOT REQUESTED BUT ALLOCATED'),
            ),
            DropdownMenuItem(
              value: 'NOT ALLOCATED',
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

