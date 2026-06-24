import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';

/// Manual EPC entry card for the item scan step.
class ShippingItemManualEntryCard extends StatelessWidget {
  const ShippingItemManualEntryCard({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  final TextEditingController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EpcEntryField(
              controller: controller,
              label: 'Item Barcode',
              hintText: 'Enter GTIN, SGTIN, or barcode',
              onEditingComplete: onAdd,
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
