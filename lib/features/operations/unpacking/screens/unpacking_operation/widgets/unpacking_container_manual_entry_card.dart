import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/sscc_entry_field.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

/// Manual SSCC entry card for the container scan step.
class UnpackingContainerManualEntryCard extends StatelessWidget {
  const UnpackingContainerManualEntryCard({
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
            SsccEntryField(
              controller: controller,
              label: 'Container SSCC / Barcode',
              hintText: 'Enter the SSCC or container barcode',
              onEditingComplete: onAdd,
              validator: (_) => null,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: TraqIcon(AppAssets.iconPlus),
              label: const Text('Add Container'),
            ),
          ],
        ),
      ),
    );
  }
}
