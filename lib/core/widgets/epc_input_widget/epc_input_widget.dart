import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/services/scanner_detection_service.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_parser.dart';
import 'package:traqtrace_app/core/widgets/epc_input_widget/epc_types.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/epc_entry_field.dart';
import 'package:traqtrace_app/features/barcode/widgets/gs1_barcode_scan_dialog.dart';
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
    final types = widget.allowedTypes ??
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

  Widget _typeBadge(EPCParseResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          label: Text('${result.typeLabel} detected',style: TextStyle(color: Colors.white),),
          backgroundColor: colorScheme.primaryContainer,
          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  Widget _manualTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EpcEntryField(
              controller: _controller,
              label: widget.label ?? 'Item Barcode',
              hintText: widget.placeholder ??
                  'Enter SGTIN or SSCC barcode',
              validator: _fieldValidator,
              onChanged: _tryParse,
              onEditingComplete: () => _handleAdd(),
            ),
            if (_lastParsed != null) _typeBadge(_lastParsed!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _lastParsed != null ? () => _handleAdd() : null,
              icon: TraqIcon(AppAssets.iconPlus),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scannerTab() {
    final canAdd = _lastParsed != null && _errorMessage == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gs1BarcodeScanTrigger(
              title: widget.label ?? 'Scan EPC',
              allowedFormats: _allowedFormatStrings,
              onScanResult: (result) {
                if (!result.isValid) return;
                setState(() => _lastScannedRaw = result.data);
                _tryParse(result.data);
              },
            ),
            if (_lastScannedRaw != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last scan',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              SelectableText(
                _lastScannedRaw!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (_lastParsed != null) _typeBadge(_lastParsed!),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: canAdd ? () => _handleAdd() : null,
              icon: TraqIcon(AppAssets.iconPlus),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isScannable) {
      return _manualTab();
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
        _mode == _EpcInputMode.scanner ? _scannerTab() : _manualTab(),
      ],
    );
  }
}