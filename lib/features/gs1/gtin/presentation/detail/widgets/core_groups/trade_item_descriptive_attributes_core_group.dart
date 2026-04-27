import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class TradeItemDescriptiveAttributesCoreGroup extends StatefulWidget {
  const TradeItemDescriptiveAttributesCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<TradeItemDescriptiveAttributesCoreGroup> createState() =>
      _TradeItemDescriptiveAttributesCoreGroupState();
}

class _TradeItemDescriptiveAttributesCoreGroupState
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
        sectionLabel('2. Trade Item Descriptive Attributes (GDSN Core)'),
        Text(
          'brand_name is captured in the main form (Brand Name *).',
          style: theme.textTheme.bodySmall?.copyWith(color: muted),
        ),
        const SizedBox(height: 12),
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

