import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/services/scanner_detection_service.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/barcode/models/scan_mode.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_error_banner.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_manual_input_section.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/wired_scanner_ready_view.dart';
import 'package:traqtrace_app/features/barcode/widgets/scanner/gs1_barcode_scanner_widget.dart';

class BarcodeScannerView extends StatelessWidget {
  const BarcodeScannerView({
    super.key,
    required this.wiredFocusNode,
    required this.manualController,
    required this.manualFocusNode,
    required this.scannerKey,
    required this.scanMode,
    required this.availability,
    required this.isScannable,
    required this.showCameraButton,
    required this.showWiredToggle,
    required this.isCameraActive,
    required this.isWiredActive,
    required this.isProcessing,
    required this.errorMessage,
    required this.onKeyEvent,
    required this.onToggleCamera,
    required this.onToggleWired,
    required this.onDetected,
    required this.onCameraBecameAvailable,
    required this.onCameraUnavailable,
    required this.onDismissError,
  });

  final FocusNode wiredFocusNode;
  final TextEditingController manualController;
  final FocusNode manualFocusNode;
  final Key scannerKey;
  final ScanMode scanMode;
  final ScannerAvailability availability;
  final bool isScannable;
  final bool showCameraButton;
  final bool showWiredToggle;
  final bool isCameraActive;
  final bool isWiredActive;
  final bool isProcessing;
  final String? errorMessage;
  final ValueChanged<KeyEvent> onKeyEvent;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleWired;
  final ValueChanged<String> onDetected;
  final VoidCallback onCameraBecameAvailable;
  final VoidCallback onCameraUnavailable;
  final VoidCallback onDismissError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return KeyboardListener(
      focusNode: wiredFocusNode,
      onKeyEvent: onKeyEvent,
      child: Column(
        children: [
          if (isScannable && (showCameraButton || showWiredToggle))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  if (showCameraButton) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleCamera,
                        icon: const TraqIcon(AppAssets.iconCamera, size: 16),
                        label: Text(
                          isCameraActive ? 'Stop Camera' : 'Scan with Camera',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: isCameraActive
                            ? OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                side: BorderSide(color: colorScheme.error),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (showWiredToggle)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onToggleWired,
                        icon: const TraqIcon(AppAssets.iconKeyboard, size: 16),
                        label: Text(
                          isWiredActive ? 'Disconnect' : 'Wired Scanner',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: isWiredActive
                            ? OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(color: colorScheme.primary),
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          if (isCameraActive && showCameraButton)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GS1BarcodeScannerWidget(
                    key: scannerKey,
                    onGS1BarcodeDetected: onDetected,
                    scanMode: scanMode,
                    onCameraBecameAvailable: onCameraBecameAvailable,
                    onCameraUnavailable: onCameraUnavailable,
                  ),
                ),
              ),
            ),
          if (isWiredActive)
            Expanded(
              flex: 3,
              child: WiredScannerReadyView(
                availability: availability,
                isProcessing: isProcessing,
              ),
            ),
          if (errorMessage != null)
            BarcodeErrorBanner(
              message: errorMessage!,
              onDismiss: onDismissError,
            ),
          BarcodeManualInputSection(
            controller: manualController,
            focusNode: manualFocusNode,
            isProcessing: isProcessing,
            onSubmit: onDetected,
          ),
        ],
      ),
    );
  }
}
