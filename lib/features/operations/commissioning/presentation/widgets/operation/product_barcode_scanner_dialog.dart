import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scanner_widget.dart';
import 'package:traqtrace_app/features/operations/commissioning/presentation/widgets/operation/wired_scanner_ready_prompt.dart';
import 'package:traqtrace_app/shared/models/scan_result.dart';

class CommissioningProductBarcodeScannerDialog extends StatefulWidget {
  const CommissioningProductBarcodeScannerDialog({
    super.key,
    required this.useCameraScanner,
    required this.onBarcodeDetected,
  });

  final bool useCameraScanner;
  final ValueChanged<String> onBarcodeDetected;

  @override
  State<CommissioningProductBarcodeScannerDialog> createState() =>
      _CommissioningProductBarcodeScannerDialogState();
}

class _CommissioningProductBarcodeScannerDialogState
    extends State<CommissioningProductBarcodeScannerDialog> {
  bool _handled = false;

  final _captureController = TextEditingController();
  final _captureFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (!widget.useCameraScanner) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _captureFocusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    _captureController.dispose();
    _captureFocusNode.dispose();
    super.dispose();
  }

  void _onDetected(String rawBarcode) {
    if (_handled) return;
    _handled = true;
    widget.onBarcodeDetected(rawBarcode);
  }

  void _onWiredSubmit(String value) {
    final trimmed = value.trim();
    _captureController.clear();
    if (trimmed.isNotEmpty) _onDetected(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);
    final dialogSize = Size(
      (size.width * 0.85).clamp(300.0, 560.0),
      (size.height * 0.72).clamp(360.0, 640.0),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: dialogSize.width,
        height: dialogSize.height,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.4),
                border: Border(
                  bottom: BorderSide(color: cs.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Scan Product Barcode',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.useCameraScanner
                  ? GS1BarcodeScannerWidget(
                      scanMode: ScanMode.single,
                      onGS1BarcodeDetected: _onDetected,
                    )
                  : CommissioningWiredScannerReadyPrompt(
                      captureController: _captureController,
                      captureFocusNode: _captureFocusNode,
                      onSubmitted: _onWiredSubmit,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
