import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_date_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';

/// GDSN-style master-data inputs for future API binding.
/// State is **local only**; values are not submitted with [GTIN] create/update.
class GtinUnboundSpecFields extends StatefulWidget {
  const GtinUnboundSpecFields({
    super.key,
    required this.isReadOnly,
    required this.gtinCodeController,
  });

  final bool isReadOnly;
  final TextEditingController gtinCodeController;

  @override
  State<GtinUnboundSpecFields> createState() => _GtinUnboundSpecFieldsState();
}

class _GtinUnboundSpecFieldsState extends State<GtinUnboundSpecFields> {
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  late final TextEditingController _brandName;
  late final TextEditingController _functionalName;
  late final TextEditingController _tradeItemDescription;
  late final TextEditingController _gpcCategoryCode;
  late final TextEditingController _targetMarketCountryCode;
  late final TextEditingController _netContent;
  late final TextEditingController _netContentUom;
  late final TextEditingController _grossWeight;
  late final TextEditingController _grossWeightUom;
  late final TextEditingController _height;
  late final TextEditingController _width;
  late final TextEditingController _depth;
  late final TextEditingController _dimensionUom;
  late final TextEditingController _parentGtin;
  late final TextEditingController _quantityPerParent;
  late final TextEditingController _quantityOfChildren;
  late final TextEditingController _totalQuantityNextLower;
  late final TextEditingController _packagingType;
  late final TextEditingController _unitOfMeasure;
  late final TextEditingController _launchDateDisplay;

  DateTime? _launchDate;
  bool _isBaseUnit = false;
  bool _isConsumerUnit = false;
  bool _isOrderableUnit = false;
  bool _isDespatchUnit = false;
  bool _isInvoiceUnit = false;
  bool _isVariableUnit = false;

  @override
  void initState() {
    super.initState();
    _brandName = TextEditingController();
    _functionalName = TextEditingController();
    _tradeItemDescription = TextEditingController();
    _gpcCategoryCode = TextEditingController();
    _targetMarketCountryCode = TextEditingController();
    _netContent = TextEditingController();
    _netContentUom = TextEditingController();
    _grossWeight = TextEditingController();
    _grossWeightUom = TextEditingController();
    _height = TextEditingController();
    _width = TextEditingController();
    _depth = TextEditingController();
    _dimensionUom = TextEditingController();
    _parentGtin = TextEditingController();
    _quantityPerParent = TextEditingController();
    _quantityOfChildren = TextEditingController();
    _totalQuantityNextLower = TextEditingController();
    _packagingType = TextEditingController();
    _unitOfMeasure = TextEditingController();
    _launchDateDisplay = TextEditingController();
  }

  @override
  void dispose() {
    _brandName.dispose();
    _functionalName.dispose();
    _tradeItemDescription.dispose();
    _gpcCategoryCode.dispose();
    _targetMarketCountryCode.dispose();
    _netContent.dispose();
    _netContentUom.dispose();
    _grossWeight.dispose();
    _grossWeightUom.dispose();
    _height.dispose();
    _width.dispose();
    _depth.dispose();
    _dimensionUom.dispose();
    _parentGtin.dispose();
    _quantityPerParent.dispose();
    _quantityOfChildren.dispose();
    _totalQuantityNextLower.dispose();
    _packagingType.dispose();
    _unitOfMeasure.dispose();
    _launchDateDisplay.dispose();
    super.dispose();
  }

  Future<void> _pickLaunchDate() async {
    final initial = _launchDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _launchDate = picked;
        _launchDateDisplay.text = _dateFmt.format(picked);
      });
    }
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

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        maintainState: true,
        title: const Text('Additional GDSN-style fields'),
        subtitle: Text(
          'Local preview only — not sent to the server',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionLabel('Descriptive (GDSN)'),
                GtinValidatedField(
                  controller: _brandName,
                  fieldName: 'brandName',
                  label: 'Brand name',
                  readOnly: widget.isReadOnly,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _functionalName,
                  fieldName: 'functionalName',
                  label: 'Functional name',
                  readOnly: widget.isReadOnly,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _tradeItemDescription,
                  fieldName: 'tradeItemDescription',
                  label: 'Trade item description',
                  readOnly: widget.isReadOnly,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _gpcCategoryCode,
                  fieldName: 'gpcCategoryCode',
                  label: 'GPC (brick / category code)',
                  helperText: 'e.g. 8-digit GPC brick',
                  readOnly: widget.isReadOnly,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _targetMarketCountryCode,
                  fieldName: 'targetMarketCountryCode',
                  label: 'Target market (country code)',
                  helperText: 'e.g. ISO 3166-1 numeric, if applicable',
                  readOnly: widget.isReadOnly,
                  keyboardType: TextInputType.number,
                ),
                sectionLabel('Content & measure'),
                GtinValidatedField(
                  controller: _netContent,
                  fieldName: 'netContent',
                  label: 'Net content (value)',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _netContentUom,
                  fieldName: 'netContentUom',
                  label: 'Net content UoM',
                  helperText: 'UN/ECE Rec 20 code, e.g. C62, mL, g',
                  readOnly: widget.isReadOnly,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _grossWeight,
                  fieldName: 'grossWeight',
                  label: 'Gross weight',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _grossWeightUom,
                  fieldName: 'grossWeightUom',
                  label: 'Gross weight UoM',
                  readOnly: widget.isReadOnly,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _height,
                  fieldName: 'height',
                  label: 'Height',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _width,
                  fieldName: 'width',
                  label: 'Width',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _depth,
                  fieldName: 'depth',
                  label: 'Depth',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _dimensionUom,
                  fieldName: 'dimensionUom',
                  label: 'Dimension UoM',
                  readOnly: widget.isReadOnly,
                ),
                sectionLabel('Packaging & hierarchy (draft)'),
                GtinValidatedField(
                  controller: _packagingType,
                  fieldName: 'packagingType',
                  label: 'Packaging type',
                  readOnly: widget.isReadOnly,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _unitOfMeasure,
                  fieldName: 'unitOfMeasure',
                  label: 'Unit of measure (trade item)',
                  readOnly: widget.isReadOnly,
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _parentGtin,
                  fieldName: 'parentGtin',
                  label: 'Parent GTIN',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _quantityPerParent,
                  fieldName: 'quantityPerParent',
                  label: 'Quantity per parent',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _quantityOfChildren,
                  fieldName: 'quantityOfChildren',
                  label: 'Quantity of child trade items',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinValidatedField(
                  controller: _totalQuantityNextLower,
                  fieldName: 'totalQuantityNextLower',
                  label: 'Total quantity of next-lower level',
                  readOnly: widget.isReadOnly,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                ),
                const SizedBox(height: 12),
                GtinDateField(
                  controller: _launchDateDisplay,
                  label: 'Launch date',
                  enabled: !widget.isReadOnly,
                  onPick: _pickLaunchDate,
                ),
                sectionLabel('Trade item role flags'),
                SwitchListTile(
                  value: _isBaseUnit,
                  onChanged: widget.isReadOnly
                      ? null
                      : (v) => setState(() => _isBaseUnit = v),
                  title: const Text('Base unit'),
                ),
                SwitchListTile(
                  value: _isConsumerUnit,
                  onChanged: widget.isReadOnly
                      ? null
                      : (v) => setState(() => _isConsumerUnit = v),
                  title: const Text('Consumer unit'),
                ),
                SwitchListTile(
                  value: _isOrderableUnit,
                  onChanged: widget.isReadOnly
                      ? null
                      : (v) => setState(() => _isOrderableUnit = v),
                  title: const Text('Orderable unit'),
                ),
                SwitchListTile(
                  value: _isDespatchUnit,
                  onChanged: widget.isReadOnly
                      ? null
                      : (v) => setState(() => _isDespatchUnit = v),
                  title: const Text('Despatch unit'),
                ),
                SwitchListTile(
                  value: _isInvoiceUnit,
                  onChanged: widget.isReadOnly
                      ? null
                      : (v) => setState(() => _isInvoiceUnit = v),
                  title: const Text('Invoice unit'),
                ),
                SwitchListTile(
                  value: _isVariableUnit,
                  onChanged: widget.isReadOnly
                      ? null
                      : (v) => setState(() => _isVariableUnit = v),
                  title: const Text('Variable measure unit'),
                ),
                sectionLabel('Derived from GTIN (read-only)'),
                ListenableBuilder(
                  listenable: widget.gtinCodeController,
                  builder: (context, _) {
                    final raw = widget.gtinCodeController.text;
                    final s = GtinFormat.stripGtinInput(raw);
                    if (s.isEmpty) {
                      return Text(
                        'Enter a valid GTIN above to see the check digit and 14-digit form.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      );
                    }
                    if (!GtinFieldValidators.isGtinCodeValid(raw)) {
                      return Text(
                        'Check digit and canonical form update when the GTIN field is valid.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      );
                    }
                    final body = s.substring(0, s.length - 1);
                    final check = s[s.length - 1];
                    final canon = GtinFieldValidators.canonicalGtin14FromInput(
                      raw,
                    );
                    return SelectableText(
                      'Check digit: $check  ·  Data body (no check): $body\n'
                      'Canonical (14 digits): $canon  ·  Indicator: ${GtinFormat.indicatorFromCanonical14(canon) ?? "—"}\n'
                      'Note: company prefix and item reference split are not shown (length varies by member).',
                      style: theme.textTheme.bodySmall,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
