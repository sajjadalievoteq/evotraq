import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SsccTobaccoTaxStampSection extends StatelessWidget {
  const SsccTobaccoTaxStampSection({
    super.key,
    required this.isEditing,
    required this.taxStampAggregationLevel,
    required this.onTaxStampAggregationLevelChanged,
    required this.aggregatedStampCountController,
    required this.taxStampAuthorityIdController,
  });

  final bool isEditing;
  final String? taxStampAggregationLevel;
  final ValueChanged<String?> onTaxStampAggregationLevelChanged;
  final TextEditingController aggregatedStampCountController;
  final TextEditingController taxStampAuthorityIdController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tax Stamp Aggregation',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Aggregation Level',
            border: OutlineInputBorder(),
          ),
          value: taxStampAggregationLevel,
          items: const [
            DropdownMenuItem(value: 'PACK', child: Text('Pack')),
            DropdownMenuItem(value: 'CARTON', child: Text('Carton')),
            DropdownMenuItem(value: 'MASTERCASE', child: Text('Master Case')),
            DropdownMenuItem(value: 'PALLET', child: Text('Pallet')),
            DropdownMenuItem(value: 'CONTAINER', child: Text('Container')),
          ],
          onChanged: isEditing ? onTaxStampAggregationLevelChanged : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: aggregatedStampCountController,
          decoration: const InputDecoration(
            labelText: 'Aggregated Stamp Count',
            hintText: 'Total number of tax stamps in container',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          enabled: isEditing,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: taxStampAuthorityIdController,
          decoration: const InputDecoration(
            labelText: 'Tax Stamp Authority ID',
            hintText: 'Issuing authority identifier',
            border: OutlineInputBorder(),
          ),
          enabled: isEditing,
          maxLength: 100,
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
        ),
      ],
    );
  }
}
