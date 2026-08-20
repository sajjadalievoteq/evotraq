import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/services/scanner_detection_service.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_presenter.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_manual_tab.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_input_scanner_tab.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/features/barcode/widgets/dialog/gs1_barcode_scan.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';

enum _EpcInputMode { scanner, manual }

class EPCInputWidget extends StatefulWidget {
  const EPCInputWidget({
    required this.onItemAdded,
    this.allowedTypes,
    this.placeholder,
    this.label,
    this.scannerAvailable,
    this.onParseFallback,
    super.key,
  });

  final void Function(EPCParseResult result) onItemAdded;
  final List<EPCType>? allowedTypes;
  final String? placeholder;
  final String? label;
  final bool? scannerAvailable;

  final Future<EPCParseResult?> Function(String input)? onParseFallback;

  @override
  State<EPCInputWidget> createState() => _EPCInputWidgetState();
}

class _EPCInputWidgetState extends State<EPCInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScannerDetectionService _scannerDetection = ScannerDetectionService();

  EPCParseResult? _lastParsed;
  String? _errorMessage;
  final Set<String> _sessionItems = {};

  _EpcInputMode _mode = _EpcInputMode.manual;
  String? _lastScannedRaw;
  bool _scannerOpenedForTab = false;

  bool get _isScannable =>
      widget.scannerAvailable ?? _scannerDetection.isScannable;

  @override
  void dispose() {
    _controller.dispose();
    _scannerDetection.dispose();
    super.dispose();
  }

  List<String> get _allowedFormatStrings {
    final types =
        widget.allowedTypes ??
        EPCType.values.where((t) => t != EPCType.unknown).toList();
    return types
        .map((t) => t.name.toUpperCase())
        .where((s) => s != 'UNKNOWN')
        .toList();
  }

  bool _isTypeAllowed(EPCType type) {
    final allowed = widget.allowedTypes;
    if (allowed == null || allowed.isEmpty) return type != EPCType.unknown;
    return allowed.contains(type);
  }

  Future<void> _tryParse(String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _lastParsed = null;
        _errorMessage = null;
      });
      return;
    }

    try {
      final result = parseToEPC(trimmed);
      if (!_isTypeAllowed(result.type)) {
        setState(() {
          _lastParsed = null;
          _errorMessage =
              '${result.typeLabel} is not allowed for this operation';
        });
        return;
      }
      setState(() {
        _lastParsed = result;
        _errorMessage = null;
      });
    } on EPCParseException catch (e) {
      if (widget.onParseFallback != null) {
        final fallback = await widget.onParseFallback!(trimmed);
        if (!mounted) return;
        if (fallback != null && _isTypeAllowed(fallback.type)) {
          setState(() {
            _lastParsed = fallback;
            _errorMessage = null;
          });
          return;
        }
      }
      setState(() {
        _lastParsed = null;
        _errorMessage = e.message;
      });
    }
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (_errorMessage != null) return _errorMessage;
    if (_lastParsed == null) {
      return 'Not a valid EPC or barcode';
    }
    return null;
  }

  void _handleAdd({EPCParseResult? result}) {
    final parsed = result ?? _lastParsed;
    if (parsed == null) {
      setState(() => _errorMessage ??= 'Enter or scan a valid EPC first');
      return;
    }
    if (!_isTypeAllowed(parsed.type)) {
      setState(() {
        _errorMessage = '${parsed.typeLabel} is not allowed for this operation';
      });
      return;
    }

    if (_sessionItems.contains(parsed.epc)) {
      context.showWarning(
        'Item already scanned in this session',
        title: 'Duplicate item',
      );
    }

    _sessionItems.add(parsed.epc);
    widget.onItemAdded(parsed);

    setState(() {
      _controller.clear();
      _lastParsed = null;
      _errorMessage = null;
      _lastScannedRaw = null;
      _scannerOpenedForTab = false;
    });
  }

  Future<void> _openScanner() async {
    final result = await GS1BarcodeScanDialog.show(
      context,
      title: widget.label ?? 'Scan EPC',
      allowedFormats: _allowedFormatStrings,
    );
    if (!mounted || result == null || !result.isValid) return;

    final raw = result.data;
    setState(() => _lastScannedRaw = raw);

    try {
      final parsed = parseToEPC(raw);
      if (!_isTypeAllowed(parsed.type)) {
        setState(() {
          _lastParsed = null;
          _errorMessage =
              '${parsed.typeLabel} is not allowed for this operation';
        });
        return;
      }
      setState(() {
        _lastParsed = parsed;
        _errorMessage = null;
      });
    } on EPCParseException catch (e) {
      if (widget.onParseFallback != null) {
        final fallback = await widget.onParseFallback!(raw);
        if (!mounted) return;
        if (fallback != null && _isTypeAllowed(fallback.type)) {
          setState(() {
            _lastParsed = fallback;
            _errorMessage = null;
          });
          return;
        }
      }
      setState(() {
        _lastParsed = null;
        _errorMessage = e.message;
      });
    }
  }

  void _onModeChanged(Set<_EpcInputMode> modes) {
    final mode = modes.first;
    setState(() {
      _mode = mode;
      _scannerOpenedForTab = false;
      _lastParsed = null;
      _errorMessage = null;
      _lastScannedRaw = null;
    });

    if (mode == _EpcInputMode.scanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _scannerOpenedForTab) return;
        _scannerOpenedForTab = true;
        _openScanner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isScannable) {
      return EpcInputManualTab(
        controller: _controller,
        label: widget.label ?? 'Item Barcode',
        hintText: widget.placeholder ?? 'Enter SGTIN or SSCC barcode',
        parsedResult: _lastParsed,
        validator: _fieldValidator,
        onChanged: _tryParse,
        onAdd: _handleAdd,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_EpcInputMode>(
          segments: const [
            ButtonSegment(
              value: _EpcInputMode.scanner,
              icon: TraqIcon(AppAssets.iconQr),
              label: Text('Camera / Scanner'),
            ),
            ButtonSegment(
              value: _EpcInputMode.manual,
              icon: TraqIcon(AppAssets.iconKeyboard),
              label: Text('Manual'),
            ),
          ],
          selected: {_mode},
          onSelectionChanged: _onModeChanged,
        ),
        const SizedBox(height: 12),
        _mode == _EpcInputMode.scanner
            ? EpcInputScannerTab(
                title: widget.label ?? 'Scan EPC',
                allowedFormats: _allowedFormatStrings,
                lastScannedRaw: _lastScannedRaw,
                parsedResult: _lastParsed,
                errorMessage: _errorMessage,
                onScanData: (data) {
                  setState(() => _lastScannedRaw = data);
                  _tryParse(data);
                },
                onAdd: _handleAdd,
              )
            : EpcInputManualTab(
                controller: _controller,
                label: widget.label ?? 'Item Barcode',
                hintText: widget.placeholder ?? 'Enter SGTIN or SSCC barcode',
                parsedResult: _lastParsed,
                validator: _fieldValidator,
                onChanged: _tryParse,
                onAdd: _handleAdd,
              ),
      ],
    );
  }
}
