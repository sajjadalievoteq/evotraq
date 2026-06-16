import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/widgets/barcode_scanner.dart';

class AggregationBarcodeScanDialog extends StatelessWidget {
  const AggregationBarcodeScanDialog({
    super.key,
    required this.title,
    required this.allowedFormats,
  });

  final String title;
  final List<String> allowedFormats;

  static Future<ScanResult?> show(
    BuildContext context, {
    required String title,
    required List<String> allowedFormats,
  }) {
    return showDialog<ScanResult>(
      context: context,
      builder: (ctx) => AggregationBarcodeScanDialog(
        title: title,
        allowedFormats: allowedFormats,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(
              title: Text(title),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: BarcodeScanner(
                allowedFormats: allowedFormats,
                onScanResult: (result) => Navigator.pop(context, result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
