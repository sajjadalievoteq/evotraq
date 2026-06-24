import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SsccTobaccoBatchTrackingSection extends StatelessWidget {
  const SsccTobaccoBatchTrackingSection({
    super.key,
    required this.isEditing,
    required this.containsMultipleBatches,
    required this.onContainsMultipleBatchesChanged,
    required this.primaryBatchNumberController,
  });

  final bool isEditing;
  final bool containsMultipleBatches;
  final ValueChanged<bool> onContainsMultipleBatchesChanged;
  final TextEditingController primaryBatchNumberController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manufacturing Batch Tracking',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Contains Multiple Batches'),
          subtitle: const Text('Container has products from multiple batches'),
          value: containsMultipleBatches,
          onChanged: isEditing ? onContainsMultipleBatchesChanged : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: primaryBatchNumberController,
          decoration: const InputDecoration(
            labelText: 'Primary Batch Number',
            hintText: 'Main batch in container',
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
