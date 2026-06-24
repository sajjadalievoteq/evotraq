import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/models/scan_result.dart';
import 'package:traqtrace_app/core/services/gs1_scan_pipeline.dart';
import 'package:traqtrace_app/features/barcode/models/scan_mode.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner_screen.dart';

/// Universal GS1 barcode scan dialog — the single entry point for scanning
/// anywhere in the app (forms, operations, standalone flows).
///
/// ```dart
/// // Returns a parsed [ScanResult] after the user confirms.
/// final result = await GS1BarcodeScanDialog.show(
///   context,
///   title: 'Scan Item',
///   allowedFormats: const ['SGTIN'],
/// );
///
/// // Returns the raw GS1 element string.
/// final raw = await GS1BarcodeScanDialog.showRaw(context, title: 'Scan GTIN');
///
/// // Suffix icon for text fields.
/// suffixIcon: GS1BarcodeScanDialog.iconButton(
///   context: context,
///   title: 'Scan Barcode',
///   onResult: (result) => ...,
/// ),
///
/// // Embedded trigger card for operation screens.
/// Gs1BarcodeScanTrigger(onScanResult: ..., title: 'Scan Item'),
/// ```
abstract final class GS1BarcodeScanDialog {
  GS1BarcodeScanDialog._();

  static Future<ScanResult?> show(
    BuildContext context, {
    required String title,
    List<String> allowedFormats = const [],
    bool verifyWithBackend = false,
    ScanMode scanMode = ScanMode.single,
  }) async {
    ScanResult? result;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final size = MediaQuery.sizeOf(ctx);
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 720,
              maxHeight: size.height * 0.88,
              minWidth: 320,
              minHeight: 420,
            ),
            child: GS1BarcodeScannerScreen(
              embedded: true,
              title: title,
              verifyWithBackend: verifyWithBackend,
              scanMode: scanMode,
              onBarcodeDetected: (gs1ElementString, _, __) {
                final pipelineResult =
                    Gs1ScanPipeline.processScan(gs1ElementString);
                if (!pipelineResult.isValid) {
                  result = pipelineResult;
                  return;
                }

                if (!_isAllowedType(
                    pipelineResult.barcodeType, allowedFormats)) {
                  result = ScanResult.error(
                    data: gs1ElementString,
                    error:
                        'Barcode type not allowed: ${pipelineResult.barcodeType ?? 'Unknown'}',
                  );
                  return;
                }

                result = ScanResult.success(
                  data: pipelineResult.data,
                  barcodeType: pipelineResult.barcodeType,
                  metadata: {
                    ...?pipelineResult.metadata,
                    'timestamp': DateTime.now().toIso8601String(),
                  },
                );
              },
            ),
          ),
        );
      },
    );

    return result;
  }

  static Future<String?> showRaw(
    BuildContext context, {
    required String title,
    List<String> allowedFormats = const [],
    bool verifyWithBackend = false,
    ScanMode scanMode = ScanMode.single,
  }) async {
    final result = await show(
      context,
      title: title,
      allowedFormats: allowedFormats,
      verifyWithBackend: verifyWithBackend,
      scanMode: scanMode,
    );
    if (result == null || !result.isValid) return null;
    return result.data;
  }

  /// Scanner [IconButton] for [InputDecoration.suffixIcon] and toolbars.
  static Widget iconButton({
    required BuildContext context,
    required String title,
    required ValueChanged<ScanResult> onResult,
    List<String> allowedFormats = const [],
    bool verifyWithBackend = false,
    ScanMode scanMode = ScanMode.single,
    String tooltip = 'Scan barcode',
  }) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner),
      tooltip: tooltip,
      onPressed: () async {
        final result = await show(
          context,
          title: title,
          allowedFormats: allowedFormats,
          verifyWithBackend: verifyWithBackend,
          scanMode: scanMode,
        );
        if (result != null) onResult(result);
      },
    );
  }

  static bool _isAllowedType(String? barcodeType, List<String> allowedFormats) {
    if (allowedFormats.isEmpty) return true;
    if (barcodeType == null || barcodeType == 'UNKNOWN') return true;
    return allowedFormats.contains(barcodeType);
  }
}

/// Compact card with an "Open Scanner" button — embed in operation wizards.
class Gs1BarcodeScanTrigger extends StatelessWidget {
  const Gs1BarcodeScanTrigger({
    super.key,
    required this.onScanResult,
    this.allowedFormats = const [],
    this.showPreview = true,
    this.height,
    this.validateGS1 = true,
    this.title = 'Scan Barcode',
    this.scanMode = ScanMode.single,
  });

  final ValueChanged<ScanResult> onScanResult;
  final List<String> allowedFormats;
  final bool showPreview;
  final double? height;
  final bool validateGS1;
  final String title;
  final ScanMode scanMode;

  Future<void> _openScanner(BuildContext context) async {
    final result = await GS1BarcodeScanDialog.show(
      context,
      title: title,
      allowedFormats: allowedFormats,
      verifyWithBackend: validateGS1,
      scanMode: scanMode,
    );
    if (result != null) onScanResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner,
            size: showPreview ? 48 : 40,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Scan a GS1 barcode',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Camera, wired scanner, or manual entry',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => _openScanner(context),
            icon: const Icon(Icons.qr_code_scanner, size: 18),
            label: const Text('Open Scanner'),
          ),
          if (allowedFormats.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Allowed formats: ${allowedFormats.join(', ')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
