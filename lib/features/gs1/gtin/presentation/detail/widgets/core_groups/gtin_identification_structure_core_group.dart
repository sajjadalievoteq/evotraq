import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_structure_chips.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

class GtinIdentificationStructureCoreGroup extends StatefulWidget {
  const GtinIdentificationStructureCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.gtinCodeController,
    this.gtinFocusNode,
    this.onGtinEditingComplete,
    this.gtinFieldLocked,
  });

  final bool isReadOnly;
  final TextEditingController gtinCodeController;
  final FocusNode? gtinFocusNode;
  final VoidCallback? onGtinEditingComplete;
  final bool? gtinFieldLocked;

  @override
  State<GtinIdentificationStructureCoreGroup> createState() =>
      _GtinIdentificationStructureCoreGroupState();
}

class _GtinIdentificationStructureCoreGroupState
    extends State<GtinIdentificationStructureCoreGroup> {
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;

  late final TextEditingController _gtinStructure;
  late final TextEditingController _indicatorDigit;
  late final TextEditingController _checkDigit;
  late final TextEditingController _companyPrefixLength;
  late final TextEditingController _gs1CompanyPrefix;
  late final TextEditingController _itemReference;

  @override
  void initState() {
    super.initState();
    if (widget.gtinFocusNode != null) {
      _focusNode = widget.gtinFocusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _gtinStructure = TextEditingController();
    _indicatorDigit = TextEditingController();
    _checkDigit = TextEditingController();
    _companyPrefixLength = TextEditingController();
    _gs1CompanyPrefix = TextEditingController();
    _itemReference = TextEditingController();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    _gtinStructure.dispose();
    _indicatorDigit.dispose();
    _checkDigit.dispose();
    _companyPrefixLength.dispose();
    _gs1CompanyPrefix.dispose();
    _itemReference.dispose();
    super.dispose();
  }

  void _normalizeGtinIfPossible() {
    final locked = widget.gtinFieldLocked ?? widget.isReadOnly;
    if (locked) return;
    final raw = widget.gtinCodeController.text;
    if (!GtinFieldValidators.isGtinCodeValid(raw)) return;

    final n = GtinFieldValidators.canonicalGtin14FromInput(raw);
    if (raw == n) return;
    widget.gtinCodeController.value = TextEditingValue(
      text: n,
      selection: TextSelection.collapsed(offset: n.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    Widget sectionLabel(String text) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        sectionLabel('1. GTIN Identification & Structure (Core)'),
        GtinValidatedField(
          focusNode: _focusNode,
          onEditingComplete: () {
            _normalizeGtinIfPossible();
            widget.onGtinEditingComplete?.call();
          },
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          controller: widget.gtinCodeController,
          fieldName: 'gtinCode',
          label: 'GTIN *',
          helperText:
              '8, 12, 13, or 14 digits; GS1 check digit. Spaces and hyphens are ignored.',
          readOnly: widget.gtinFieldLocked ?? widget.isReadOnly,
          validator: GtinFieldValidators.validateGtinCode,
        ),
        GtinStructureChips(gtinCodeController: widget.gtinCodeController),
        ListenableBuilder(
          listenable: Listenable.merge([
            widget.gtinCodeController,
            _companyPrefixLength,
          ]),
          builder: (context, _) {
            final raw = widget.gtinCodeController.text;
            final s = GtinFormat.stripGtinInput(raw);
            if (!GtinFieldValidators.isGtinCodeValid(raw)) {
              _gtinStructure.text = '';
              _indicatorDigit.text = '';
              _checkDigit.text = '';
              return Text(
                'Enter a valid GTIN above to populate structure fields (gtin_structure, indicator_digit, check_digit).',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              );
            }

            final structure = GtinFormat.structureLabelForStrippedInput(s) ?? '';
            final canon = GtinFieldValidators.canonicalGtin14FromInput(raw);
            final indicator = GtinFormat.indicatorFromCanonical14(canon);
            final check = s.isNotEmpty ? s[s.length - 1] : '';

            _gtinStructure.text = structure;
            _indicatorDigit.text = indicator ?? '';
            _checkDigit.text = check;

            final prefixLen = int.tryParse(_companyPrefixLength.text);
            if (prefixLen != null && prefixLen >= 6 && prefixLen <= 12) {
              final withoutCheck = canon.substring(0, canon.length - 1);
              final rest = withoutCheck.substring(1); // drop indicator
              if (prefixLen <= rest.length) {
                _gs1CompanyPrefix.text = rest.substring(0, prefixLen);
                _itemReference.text = rest.substring(prefixLen);
              }
            }

            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _companyPrefixLength,
          fieldName: 'gs1_company_prefix_length',
          label: 'GS1 Company Prefix (GCP) Length',
          helperText:
              'Helper for now. Per documentation, GCP is derived using a prefix-length table (variable length).',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: GtinFieldValidators.validateGs1CompanyPrefixLengthHelper,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GtinValidatedField(
                controller: _gs1CompanyPrefix,
                fieldName: 'gs1_company_prefix',
                label: 'GS1 Company Prefix (GCP)',
                helperText: 'Derived from GTIN (read-only)',
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                validator: (v) => GtinFieldValidators.validateGs1CompanyPrefix(
                  v,
                  prefixLength: int.tryParse(_companyPrefixLength.text.trim()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GtinValidatedField(
                controller: _itemReference,
                fieldName: 'item_reference',
                label: 'Item Reference',
                helperText: 'Derived from GTIN (read-only)',
                readOnly: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                validator: (v) => GtinFieldValidators.validateItemReference(
                  v,
                  prefixLength: int.tryParse(_companyPrefixLength.text.trim()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

