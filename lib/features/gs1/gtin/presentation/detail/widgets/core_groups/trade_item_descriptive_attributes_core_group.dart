import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class TradeItemDescriptiveAttributesCoreGroup extends StatefulWidget {
  const TradeItemDescriptiveAttributesCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<TradeItemDescriptiveAttributesCoreGroup> createState() =>
      TradeItemDescriptiveAttributesCoreGroupState();
}

class TradeItemDescriptiveAttributesCoreGroupState
    extends State<TradeItemDescriptiveAttributesCoreGroup> {
  late final TextEditingController _functionalName;
  late final TextEditingController _tradeItemDescription;
  late final TextEditingController _gpcCategoryCode;
  late final TextEditingController _targetMarketCountryCode;

  @override
  void initState() {
    super.initState();
    _functionalName = TextEditingController();
    _tradeItemDescription = TextEditingController();
    _gpcCategoryCode = TextEditingController();
    _targetMarketCountryCode = TextEditingController();
  }

  @override
  void dispose() {
    _functionalName.dispose();
    _tradeItemDescription.dispose();
    _gpcCategoryCode.dispose();
    _targetMarketCountryCode.dispose();
    super.dispose();
  }

  String? get functionalName =>
      _functionalName.text.trim().isEmpty ? null : _functionalName.text.trim();
  String? get tradeItemDescription => _tradeItemDescription.text.trim().isEmpty
      ? null
      : _tradeItemDescription.text.trim();
  String? get gpcBrickCode =>
      _gpcCategoryCode.text.trim().isEmpty ? null : _gpcCategoryCode.text.trim();
  String? get targetMarketCountry => _targetMarketCountryCode.text.trim().isEmpty
      ? null
      : _targetMarketCountryCode.text.trim();

  void setFromGtin({
    required String? functionalName,
    required String? tradeItemDescription,
    required String? gpcBrickCode,
    required String? targetMarketCountry,
  }) {
    _functionalName.text = (functionalName ?? '').trim();
    _tradeItemDescription.text = (tradeItemDescription ?? '').trim();
    _gpcCategoryCode.text = (gpcBrickCode ?? '').trim();
    _targetMarketCountryCode.text = (targetMarketCountry ?? '').trim();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Trade Item Descriptive Attributes'),
        GtinValidatedField(
          controller: _functionalName,
          fieldName: 'functional_name',
          label: 'Functional Name',
          readOnly: widget.isReadOnly,
          maxLength: 35,
          validator: (v) => GtinFieldValidators.validateFunctionalName(
            v,
            hasGpcBrickCode: _gpcCategoryCode.text.trim().isNotEmpty,
          ),
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _tradeItemDescription,
          fieldName: 'trade_item_description',
          label: 'Trade Item Description',
          readOnly: widget.isReadOnly,
          maxLength: 200,
          validator: GtinFieldValidators.validateTradeItemDescription,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _gpcCategoryCode,
          fieldName: 'gpc_brick_code',
          label: 'GPC Brick Code',
          helperText: "8 digits, must start with '1000'",
          readOnly: widget.isReadOnly,
          keyboardType: TextInputType.number,
          maxLength: 8,
          validator: GtinFieldValidators.validateGpcBrickCode,
        ),
        const SizedBox(height: 12),
        GtinCountryCodePickerField(
          controller: _targetMarketCountryCode,
          labelText: 'Target Market Country Code',
          helperText: 'ISO 3166-1 numeric (3 digits)',
          enabled: !widget.isReadOnly,
          validator: GtinFieldValidators.validateTargetMarketCountry,
        ),
      ],
    );
  }
}

