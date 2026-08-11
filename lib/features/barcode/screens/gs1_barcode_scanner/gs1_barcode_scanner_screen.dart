import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/services/scanner_detection_service.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/core/utils/gs1/gs1_parser.dart';
import 'package:traqtrace_app/data/models/barcode/barcode_details.dart';
import 'package:traqtrace_app/data/services/barcode/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/barcode/models/scan_mode.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_details_view.dart';
import 'package:traqtrace_app/features/barcode/screens/gs1_barcode_scanner/widgets/barcode_scanner_view.dart';

typedef GS1BarcodeCallback =
    void Function(
      String gs1ElementString,
      Map<String, dynamic> parsedBarcode,
      Map<String, dynamic>? verificationResult,
    );

class GS1BarcodeScannerScreen extends StatefulWidget {
  final String? title;

  final GS1BarcodeCallback? onBarcodeDetected;

  final bool verifyWithBackend;

  final ScanMode scanMode;

  final bool embedded;

  const GS1BarcodeScannerScreen({
    Key? key,
    this.title,
    this.onBarcodeDetected,
    this.verifyWithBackend = true,
    this.scanMode = ScanMode.single,
    this.embedded = false,
  }) : super(key: key);

  @override
  State<GS1BarcodeScannerScreen> createState() =>
      _GS1BarcodeScannerScreenState();
}

class _GS1BarcodeScannerScreenState extends State<GS1BarcodeScannerScreen> {
  GS1BarcodeApiService? _apiService;
  late final ScannerDetectionService _scannerDetection;

  BarcodeDetails? _details;
  Map<String, dynamic>? _verificationResult;
  bool _isProcessing = false;
  String? _errorMessage;

  Key _scannerKey = UniqueKey();

  bool _isCameraActive = false;

  bool _isWiredActive = false;

  Timer? _autoConfirmTimer;

  String _wiredBuffer = '';

  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocusNode = FocusNode();
  final FocusNode _wiredFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _scannerDetection = ScannerDetectionService();
    _scannerDetection.addListener(_onScannerDetectionChanged);
    try {
      _apiService = getIt<GS1BarcodeApiService>();
    } catch (_) {}

    if (_scannerDetection.supportsWired) {
      _isWiredActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _wiredFocusNode.requestFocus();
      });
    }
  }

  void _onScannerDetectionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _autoConfirmTimer?.cancel();
    _scannerDetection.removeListener(_onScannerDetectionChanged);
    _manualController.dispose();
    _manualFocusNode.dispose();
    _wiredFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleDetection(
    String raw, {
    bool fromWiredScanner = false,
  }) async {
    if (_isProcessing) return;
    if (_details != null && widget.scanMode == ScanMode.single) return;

    if (fromWiredScanner) {
      _scannerDetection.onWiredScannerBurst();
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    try {
      final details = extractBarcodeDetails(raw.trim());

      Map<String, dynamic>? verResult;
      if (widget.verifyWithBackend && details.isValid && _apiService != null) {
        verResult = await _apiService!.verifyGS1Barcode(
          details.gs1ElementString,
        );
      }

      if (mounted) {
        setState(() {
          _details = details;
          _verificationResult = verResult;
          _isProcessing = false;
          _isCameraActive = false;
          _manualController.clear();
        });

        if (widget.onBarcodeDetected != null) {
          _autoConfirmTimer?.cancel();
          _autoConfirmTimer = Timer(const Duration(seconds: 2), () {
            if (mounted && _details != null) _useBarcode();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error processing barcode: $e';
          _isProcessing = false;
        });
      }
    }
  }

  void _scanAgain() {
    _autoConfirmTimer?.cancel();
    _autoConfirmTimer = null;
    _scannerDetection.resetWiredConfirmation();
    setState(() {
      _details = null;
      _verificationResult = null;
      _errorMessage = null;
      _isCameraActive = false;
      _wiredBuffer = '';
      _scannerKey = UniqueKey();
      if (_scannerDetection.supportsWired) {
        _isWiredActive = true;
      } else {
        _isWiredActive = false;
      }
    });
    if (_isWiredActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _wiredFocusNode.requestFocus();
      });
    }
  }

  void _useBarcode() {
    final d = _details!;
    widget.onBarcodeDetected?.call(
      d.rawBarcode,
      Gs1Parser.parseBarcode(d.rawBarcode),
      _verificationResult,
    );
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _handleWiredKeyEvent(KeyEvent event) {
    if (!_isWiredActive || event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_wiredBuffer.isNotEmpty) {
        _handleDetection(_wiredBuffer, fromWiredScanner: true);
        _wiredBuffer = '';
      }
    } else if (event.character != null && event.character!.isNotEmpty) {
      _wiredBuffer += event.character!;
    }
  }

  void _toggleCamera() {
    setState(() {
      _isCameraActive = !_isCameraActive;
      if (_isCameraActive) {
        _isWiredActive = false;
        _wiredBuffer = '';
        _scannerKey = UniqueKey();
      } else if (_scannerDetection.supportsWired) {
        _isWiredActive = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _wiredFocusNode.requestFocus(),
        );
      }
    });
  }

  void _toggleWired() {
    setState(() {
      _isWiredActive = !_isWiredActive;
      if (_isWiredActive) {
        _isCameraActive = false;
        _wiredBuffer = '';
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _wiredFocusNode.requestFocus(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _details != null
        ? BarcodeDetailsView(
            details: _details!,
            verificationResult: _verificationResult,
            isProcessing: _isProcessing,
            onScanAgain: _scanAgain,
            onUse: widget.onBarcodeDetected != null ? _useBarcode : null,
            autoConfirm: widget.onBarcodeDetected != null,
          )
        : BarcodeScannerView(
            wiredFocusNode: _wiredFocusNode,
            manualController: _manualController,
            manualFocusNode: _manualFocusNode,
            scannerKey: _scannerKey,
            scanMode: widget.scanMode,
            availability: _scannerDetection.availability,
            isScannable: _scannerDetection.isScannable,
            showCameraButton: _scannerDetection.canOfferCamera,
            showWiredToggle:
                _scannerDetection.supportsWired &&
                _scannerDetection.canOfferCamera,
            isCameraActive: _isCameraActive,
            isWiredActive: _isWiredActive,
            isProcessing: _isProcessing,
            errorMessage: _errorMessage,
            onKeyEvent: _handleWiredKeyEvent,
            onToggleCamera: _toggleCamera,
            onToggleWired: _toggleWired,
            onDetected: _handleDetection,
            onCameraBecameAvailable: _scannerDetection.reportCameraAvailable,
            onCameraUnavailable: _scannerDetection.reportCameraUnavailable,
            onDismissError: () => setState(() => _errorMessage = null),
          );

    if (!widget.embedded) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'Scan GS1 Barcode')),
        body: body,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              TraqIcon(
                NavIcons.generateVerifyBarcode,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title ?? 'Scan GS1 Barcode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: TraqIcon(AppAssets.iconX),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outlineVariant),
        Expanded(child: body),
      ],
    );
  }
}
