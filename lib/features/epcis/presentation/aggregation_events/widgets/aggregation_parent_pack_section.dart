import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/barcode/services/epc_uri_converter.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_event_form_validators.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_pharma_rules_text.dart';
import 'package:traqtrace_app/features/epcis/presentation/aggregation_events/utilities/aggregation_parent_pack_mode.dart';
import 'package:traqtrace_app/features/epcis/utils/epc_formatter.dart';

class AggregationParentPackSection extends StatefulWidget {
  const AggregationParentPackSection({
    super.key,
    required this.action,
    required this.onParentEpcChanged,
    this.initialParentEpc,
  });

  final String action;
  final ValueChanged<String> onParentEpcChanged;
  final String? initialParentEpc;

  @override
  State<AggregationParentPackSection> createState() =>
      AggregationParentPackSectionState();
}

class AggregationParentPackSectionState extends State<AggregationParentPackSection> {
  final _ssccController = TextEditingController();
  final _gtinController = TextEditingController();
  final _serialController = TextEditingController();
  final _formFieldKey = GlobalKey<FormFieldState<String>>();

  AggregationParentPackMode _mode = AggregationParentPackMode.sscc;
  String? _resolvedParentEpc;

  bool get _parentRequired => widget.action != 'OBSERVE';

  @override
  void initState() {
    super.initState();
    _hydrateFromInitial(widget.initialParentEpc);
  }

  void _hydrateFromInitial(String? epc) {
    if (epc == null || epc.isEmpty) return;
    if (epc.toLowerCase().contains(':sgtin:')) {
      _mode = AggregationParentPackMode.sgtin;
      final parts = epc.split(':sgtin:').last.split('.');
      if (parts.length >= 3) {
        _serialController.text = parts.last;
      }
    } else {
      _mode = AggregationParentPackMode.sscc;
      _ssccController.text = epc;
    }
    _syncResolvedParent();
  }

  @override
  void dispose() {
    _ssccController.dispose();
    _gtinController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  String? _buildParentEpcUri() {
    switch (_mode) {
      case AggregationParentPackMode.sscc:
        final raw = _ssccController.text.trim();
        if (raw.isEmpty) return null;
        if (raw.startsWith('urn:epc:')) return raw;
        final fromBarcode = EPCURIConverter.convertToEPCUri(raw);
        if (fromBarcode != null) return fromBarcode;
        final digits = raw.replaceAll(RegExp(r'\D'), '');
        if (RegExp(r'^\d{18}$').hasMatch(digits)) {
          return EPCURIConverter.convertSSCCToEPCUri(digits);
        }
        return EPCFormatter.formatToEPCUri(raw) ?? raw;
      case AggregationParentPackMode.sgtin:
        final gtin = _gtinController.text.trim().replaceAll(RegExp(r'\D'), '');
        final serial = _serialController.text.trim();
        if (gtin.isEmpty || serial.isEmpty) return null;
        return EPCURIConverter.convertGTINSerialToEPCUri(gtin, serial);
    }
  }

  void _syncResolvedParent() {
    final uri = _buildParentEpcUri();
    setState(() => _resolvedParentEpc = uri);
    widget.onParentEpcChanged(uri ?? '');
    _formFieldKey.currentState?.didChange(uri);
  }

  String? _validateResolvedParent(String? _) {
    if (!_parentRequired &&
        (_resolvedParentEpc == null || _resolvedParentEpc!.isEmpty)) {
      return null;
    }
    switch (_mode) {
      case AggregationParentPackMode.sscc:
        final ssccError = AggregationEventFormValidators.validateSsccInput(
          _ssccController.text,
          required: _parentRequired,
        );
        if (ssccError != null) return ssccError;
        break;
      case AggregationParentPackMode.sgtin:
        final gtinError = AggregationEventFormValidators.validateGtin14(
          _gtinController.text,
          required: _parentRequired,
        );
        if (gtinError != null) return gtinError;
        final serialError = AggregationEventFormValidators.validateSerialNumber(
          _serialController.text,
          required: _parentRequired,
        );
        if (serialError != null) return serialError;
        break;
    }
    final uri = _resolvedParentEpc ?? _buildParentEpcUri();
    if (_parentRequired && (uri == null || uri.isEmpty)) {
      return 'Could not build a valid parent EPC URI';
    }
    if (uri != null && uri.isNotEmpty) {
      return AggregationEventFormValidators.validateResolvedParentEpc(uri);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parentLabel =
        _parentRequired ? 'Parent pack *' : 'Parent pack (optional)';

    return FormField<String>(
      key: _formFieldKey,
      validator: _validateResolvedParent,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              parentLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AggregationPharmaRulesText.parentPackHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<AggregationParentPackMode>(
              segments: const [
                ButtonSegment(
                  value: AggregationParentPackMode.sscc,
                  label: Text('SSCC'),
                  icon: Icon(Icons.inventory_2_outlined, size: 18),
                ),
                ButtonSegment(
                  value: AggregationParentPackMode.sgtin,
                  label: Text('GTIN + serial'),
                  icon: Icon(Icons.qr_code_2_outlined, size: 18),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() {
                  _mode = selection.first;
                  _resolvedParentEpc = null;
                });
                _syncResolvedParent();
              },
            ),
            const SizedBox(height: 16),
            if (_mode == AggregationParentPackMode.sscc)
              TextFormField(
                controller: _ssccController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'SSCC',
                  hintText: '18-digit code, (00)… barcode, or urn:epc:id:sscc:…',
                  border: OutlineInputBorder(),
                  helperText:
                      'GS1 SSCC with valid check digit (AI 00)',
                ),
                validator: (value) =>
                    AggregationEventFormValidators.validateSsccInput(
                  value,
                  required: _parentRequired,
                ),
                onChanged: (_) => _syncResolvedParent(),
              )
            else ...[
              TextFormField(
                controller: _gtinController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'GTIN',
                  hintText: '8, 12, 13, or 14 digits (check digit validated)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    AggregationEventFormValidators.validateGtin14(
                  value,
                  required: _parentRequired,
                ),
                onChanged: (_) => _syncResolvedParent(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _serialController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Serial number',
                  hintText: 'GS1 serial (1–20 chars, file-7 charset)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    AggregationEventFormValidators.validateSerialNumber(
                  value,
                  required: _parentRequired,
                ),
                onChanged: (_) => _syncResolvedParent(),
              ),
            ],
            if (_resolvedParentEpc != null && _resolvedParentEpc!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resolved parent EPC',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      _resolvedParentEpc!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (field.errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                field.errorText!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
