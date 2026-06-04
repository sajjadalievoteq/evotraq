import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/di/injection.dart';
import 'package:traqtrace_app/core/utils/barcode_utils.dart';
import 'package:traqtrace_app/data/services/gs1_barcode_api_service.dart';
import 'package:traqtrace_app/features/barcode/services/gs1_barcode_parser.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scanner_widget.dart';

/// Callback fired when the user confirms a scanned barcode.
typedef GS1BarcodeCallback = void Function(
  String gs1ElementString,
  Map<String, dynamic> parsedBarcode,
  Map<String, dynamic>? verificationResult,
);

/// Central GS1 barcode scanner screen.
///
/// Scans a barcode (camera or manual entry), parses it with
/// [extractBarcodeDetails], determines its type (SGTIN / GTIN / SSCC / GLN)
/// and presents a rich detail preview before optionally firing [onBarcodeDetected].
class GS1BarcodeScannerScreen extends StatefulWidget {
  final String? title;

  /// Optional callback. When provided a "Use Barcode" confirm button is shown.
  final GS1BarcodeCallback? onBarcodeDetected;

  /// Whether to verify the scanned barcode against the backend API.
  final bool verifyWithBackend;

  /// Single = stop scanning after first hit. Continuous = keep scanning.
  final ScanMode scanMode;

  const GS1BarcodeScannerScreen({
    Key? key,
    this.title,
    this.onBarcodeDetected,
    this.verifyWithBackend = true,
    this.scanMode = ScanMode.single,
  }) : super(key: key);

  @override
  State<GS1BarcodeScannerScreen> createState() =>
      _GS1BarcodeScannerScreenState();
}

class _GS1BarcodeScannerScreenState extends State<GS1BarcodeScannerScreen> {
  GS1BarcodeApiService? _apiService;

  BarcodeDetails? _details;
  Map<String, dynamic>? _verificationResult;
  bool _isProcessing = false;
  String? _errorMessage;

  /// Changing this key forces [GS1BarcodeScannerWidget] to rebuild and
  /// restart the camera — used by "Scan Again".
  Key _scannerKey = UniqueKey();

  /// Whether the camera scanner is active (mobile only).
  bool _isCameraActive = false;

  /// Whether wired scanner keyboard-listener is active.
  bool _isWiredActive = false;

  /// Buffer for wired-scanner keystrokes.
  String _wiredBuffer = '';

  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocusNode = FocusNode();
  final FocusNode _wiredFocusNode = FocusNode();

  /// True only on Android / iOS — camera not supported on desktop or web.
  bool get _cameraSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    try {
      _apiService = getIt<GS1BarcodeApiService>();
    } catch (_) {
      // DI not configured for this service — verification skipped.
    }
  }

  @override
  void dispose() {
    _manualController.dispose();
    _manualFocusNode.dispose();
    _wiredFocusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Core detection handler
  // ---------------------------------------------------------------------------

  Future<void> _handleDetection(String raw) async {
    if (_isProcessing) return;
    if (_details != null && widget.scanMode == ScanMode.single) return;

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
        verResult = await _apiService!.verifyGS1Barcode(details.gs1ElementString);
      }

      if (mounted) {
        setState(() {
          _details = details;
          _verificationResult = verResult;
          _isProcessing = false;
          _manualController.clear();
        });
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
    setState(() {
      _details = null;
      _verificationResult = null;
      _errorMessage = null;
      _isCameraActive = false;
      _isWiredActive = false;
      _wiredBuffer = '';
      _scannerKey = UniqueKey();
    });
  }

  void _useBarcode() {
    final d = _details!;
    widget.onBarcodeDetected?.call(
      d.rawBarcode,
      GS1BarcodeParser.parseGS1Barcode(d.rawBarcode),
      _verificationResult,
    );
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Scan GS1 Barcode'),
      ),
      body: _details != null ? _buildDetailsView() : _buildScannerView(),
    );
  }

  Widget _buildScannerView() {
    final colorScheme = Theme.of(context).colorScheme;

    return KeyboardListener(
      focusNode: _wiredFocusNode,
      onKeyEvent: (event) {
        if (!_isWiredActive) return;
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            if (_wiredBuffer.isNotEmpty) {
              _handleDetection(_wiredBuffer);
              _wiredBuffer = '';
            }
          } else if (event.character != null &&
              event.character!.isNotEmpty) {
            _wiredBuffer += event.character!;
          }
        }
      },
      child: Column(
        children: [
          // ── Scanner-mode buttons ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                if (_cameraSupported) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isCameraActive = !_isCameraActive;
                          if (_isCameraActive) {
                            _isWiredActive = false;
                            _wiredBuffer = '';
                            _scannerKey = UniqueKey();
                          }
                        });
                      },
                      icon: Icon(
                        _isCameraActive
                            ? Icons.camera_alt
                            : Icons.camera_alt_outlined,
                        size: 16,
                      ),
                      label: Text(
                        _isCameraActive ? 'Stop Camera' : 'Scan with Camera',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: _isCameraActive
                          ? OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.error,
                              side: BorderSide(color: colorScheme.error),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isWiredActive = !_isWiredActive;
                        if (_isWiredActive) {
                          _isCameraActive = false;
                          _wiredBuffer = '';
                          // request focus so keyboard events are captured
                          WidgetsBinding.instance.addPostFrameCallback(
                              (_) => _wiredFocusNode.requestFocus());
                        }
                      });
                    },
                    icon: Icon(
                      _isWiredActive
                          ? Icons.keyboard
                          : Icons.keyboard_outlined,
                      size: 16,
                    ),
                    label: Text(
                      _isWiredActive ? 'Disconnect' : 'Wired Scanner',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: _isWiredActive
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

          // ── Camera view ──────────────────────────────────────────────
          if (_isCameraActive && _cameraSupported)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GS1BarcodeScannerWidget(
                    key: _scannerKey,
                    onGS1BarcodeDetected: _handleDetection,
                    scanMode: widget.scanMode,
                  ),
                ),
              ),
            ),

          // ── Wired scanner status banner ───────────────────────────────
          if (_isWiredActive)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sensors,
                        color: colorScheme.onPrimaryContainer, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Wired scanner active — scan a barcode now',
                      style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

          // ── Error strip ───────────────────────────────────────────────
          if (_errorMessage != null)
            _ErrorBanner(
              message: _errorMessage!,
              onDismiss: () => setState(() => _errorMessage = null),
            ),

          // ── Manual input — always visible ─────────────────────────────
          _ManualInputSection(
            controller: _manualController,
            focusNode: _manualFocusNode,
            isProcessing: _isProcessing,
            onSubmit: _handleDetection,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView() {
    return _BarcodeDetailsView(
      details: _details!,
      verificationResult: _verificationResult,
      isProcessing: _isProcessing,
      onScanAgain: _scanAgain,
      onUse: widget.onBarcodeDetected != null ? _useBarcode : null,
    );
  }
}

// =============================================================================
// Type chip
// =============================================================================

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final Gs1BarcodeType type;

  static const _labels = {
    Gs1BarcodeType.sgtin: 'SGTIN',
    Gs1BarcodeType.gtin: 'GTIN',
    Gs1BarcodeType.sscc: 'SSCC',
    Gs1BarcodeType.gln: 'GLN',
    Gs1BarcodeType.unknown: 'Unknown',
  };

  Color _color(ColorScheme cs) {
    switch (type) {
      case Gs1BarcodeType.sgtin:   return cs.primary;
      case Gs1BarcodeType.gtin:    return Colors.teal.shade600;
      case Gs1BarcodeType.sscc:    return Colors.orange.shade700;
      case Gs1BarcodeType.gln:     return Colors.purple.shade600;
      case Gs1BarcodeType.unknown: return cs.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(Theme.of(context).colorScheme);
    return Chip(
      label: Text(
        _labels[type] ?? 'Unknown',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

// =============================================================================
// Details view
// =============================================================================

class _BarcodeDetailsView extends StatelessWidget {
  const _BarcodeDetailsView({
    required this.details,
    required this.isProcessing,
    required this.onScanAgain,
    this.verificationResult,
    this.onUse,
  });

  final BarcodeDetails details;
  final Map<String, dynamic>? verificationResult;
  final bool isProcessing;
  final VoidCallback onScanAgain;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rows = details.displayRows;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Type + validity badges ───────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _TypeChip(type: details.type),
              if (details.isValid)
                Chip(
                  avatar: Icon(Icons.check_circle, size: 14,
                      color: Colors.green.shade700),
                  label: Text('Valid',
                      style: TextStyle(
                          fontSize: 12, color: Colors.green.shade700)),
                  backgroundColor: Colors.green.shade50,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )
              else
                Chip(
                  avatar: Icon(Icons.warning_amber_rounded, size: 14,
                      color: Colors.orange.shade700),
                  label: Text('Invalid GS1',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade700)),
                  backgroundColor: Colors.orange.shade50,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 6),

          // GS1 element string (monospace, subtle)
          SelectableText(
            details.gs1ElementString,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 16),

          // ── Detail rows ─────────────────────────────────────────────
          Card(
            child: rows.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No parseable fields found in this barcode.'),
                  )
                : Column(
                    children: rows.asMap().entries.map((entry) {
                      final isLast = entry.key == rows.length - 1;
                      final label = entry.value.key;
                      final value = entry.value.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurface
                                          .withOpacity(0.55),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: colorScheme.outlineVariant,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
          ),

          // ── Backend verification ─────────────────────────────────────
          if (verificationResult != null) ...[
            const SizedBox(height: 12),
            _VerificationCard(result: verificationResult!),
          ],

          const SizedBox(height: 24),

          // ── Action buttons ───────────────────────────────────────────
          if (isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onScanAgain,
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Scan Again'),
                  ),
                ),
                if (onUse != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onUse,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Use Barcode'),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Verification card
// =============================================================================

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.result});
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final ok = result['verified'] == true || result['valid'] == true;
    return Card(
      color: ok ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              ok ? Icons.verified : Icons.info_outline,
              color: ok ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ok ? 'Backend Verified' : 'Backend Result',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: ok
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                  if (result['message'] != null)
                    Text(
                      result['message'].toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Manual input section
// =============================================================================

class _ManualInputSection extends StatelessWidget {
  const _ManualInputSection({
    required this.controller,
    required this.focusNode,
    required this.isProcessing,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isProcessing;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or enter barcode manually',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isProcessing,
            decoration: const InputDecoration(
              hintText: 'e.g. (01)12345678901234(21)SN001',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.keyboard_alt_outlined),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) onSubmit(v.trim());
            },
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: isProcessing
                  ? null
                  : () {
                      final v = controller.text.trim();
                      if (v.isNotEmpty) onSubmit(v);
                    },
              child: isProcessing
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Parse Barcode'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Web placeholder
// =============================================================================

class _WebCameraPlaceholder extends StatelessWidget {
  const _WebCameraPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 64, color: Colors.white.withOpacity(0.25)),
            const SizedBox(height: 12),
            Text(
              'Camera not available on web',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 4),
            Text(
              'Use the input below to enter a barcode manually',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Error banner
// =============================================================================

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.error_outline,
                color: colorScheme.onErrorContainer, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                    color: colorScheme.onErrorContainer, fontSize: 13),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close,
                  color: colorScheme.onErrorContainer, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

