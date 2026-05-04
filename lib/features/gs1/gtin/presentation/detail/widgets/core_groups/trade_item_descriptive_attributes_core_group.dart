import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

class TradeItemDescriptiveAttributesCoreGroup extends StatefulWidget {
  const TradeItemDescriptiveAttributesCoreGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

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

  TextEditingController get targetMarketCountryController => _targetMarketCountryCode;

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
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GtinUiConstants.sectionTradeItemDescriptiveAttributes),
        GtinValidatedField(
          controller: _functionalName,
          fieldName: 'functional_name',
          label: GtinUiConstants.labelFunctionalName,
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
          label: GtinUiConstants.labelTradeItemDescription,
          readOnly: widget.isReadOnly,
          maxLength: 200,
          validator: GtinFieldValidators.validateTradeItemDescription,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _gpcCategoryCode,
          fieldName: 'gpc_brick_code',
          label: GtinUiConstants.labelGpcBrickCode,
          helperText: GtinUiConstants.helperGpcBrickCode,
          readOnly: widget.isReadOnly,
          keyboardType: TextInputType.number,
          maxLength: 8,
          validator: GtinFieldValidators.validateGpcBrickCode,
        ),
        const SizedBox(height: 12),
        GtinCountryCodePickerField(
          controller: _targetMarketCountryCode,
          labelText: GtinUiConstants.labelTargetMarketCountryCode,
          helperText: GtinUiConstants.helperIso3166Numeric3,
          enabled: !widget.isReadOnly,
          validator: GtinFieldValidators.validateTargetMarketCountry,
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(GtinUiConstants.sectionTradeItemDescriptiveAttributes),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
    );
  }
}

