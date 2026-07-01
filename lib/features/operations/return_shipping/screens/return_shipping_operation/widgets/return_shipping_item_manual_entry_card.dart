import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Manual EPC entry card for the item scan step.
class ReturnShippingItemManualEntryCard extends StatelessWidget {
  const ReturnShippingItemManualEntryCard({
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
              icon: TraqIcon(AppAssets.iconPlus),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
