import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_type_badge.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/barcode/widgets/dialog/gs1_barcode_scan_dialog.dart';

class EpcInputScannerTab extends StatelessWidget {
  const EpcInputScannerTab({
    required this.title,
    required this.allowedFormats,
    required this.lastScannedRaw,
    required this.parsedResult,
    required this.errorMessage,
    required this.onScanData,
    required this.onAdd,
    super.key,
  });

  final String title;
  final List<String> allowedFormats;
  final String? lastScannedRaw;
  final EPCParseResult? parsedResult;
  final String? errorMessage;
  final ValueChanged<String> onScanData;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final canAdd = parsedResult != null && errorMessage == null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gs1BarcodeScanTrigger(
              title: title,
              allowedFormats: allowedFormats,
              onScanResult: (result) {
                if (result.isValid) onScanData(result.data);
              },
            ),
            if (lastScannedRaw != null) ...[
              const SizedBox(height: 12),
              Text('Last scan', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              SelectableText(
                lastScannedRaw!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (parsedResult != null) EpcInputTypeBadge(result: parsedResult!),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: canAdd ? onAdd : null,
              icon: const TraqIcon(AppAssets.iconPlus),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}
