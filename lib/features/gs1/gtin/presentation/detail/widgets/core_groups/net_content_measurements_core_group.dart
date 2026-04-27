import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class NetContentMeasurementsCoreGroup extends StatefulWidget {
  const NetContentMeasurementsCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<NetContentMeasurementsCoreGroup> createState() =>
      _NetContentMeasurementsCoreGroupState();
}

class _NetContentMeasurementsCoreGroupState
    extends State<NetContentMeasurementsCoreGroup> {
  late final TextEditingController _netContent;
  late final TextEditingController _netContentUom;
  late final TextEditingController _grossWeight;
  late final TextEditingController _grossWeightUom;
  late final TextEditingController _height;
  late final TextEditingController _width;
  late final TextEditingController _depth;
  late final TextEditingController _dimensionUom;

  @override
  void initState() {
    super.initState();
    _netContent = TextEditingController();
    _netContentUom = TextEditingController();
    _grossWeight = TextEditingController();
    _grossWeightUom = TextEditingController();
    _height = TextEditingController();
    _width = TextEditingController();
    _depth = TextEditingController();
    _dimensionUom = TextEditingController();
  }

  @override
  void dispose() {
    _netContent.dispose();
    _netContentUom.dispose();
    _grossWeight.dispose();
    _grossWeightUom.dispose();
    _height.dispose();
    _width.dispose();
    _depth.dispose();
    _dimensionUom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        sectionLabel('4. Net Content & Measurements (Core)'),
        GtinValidatedField(
          controller: _netContent,
          fieldName: 'net_content_value',
          label: 'Net Content Value',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateNetContentValueRequired,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _netContentUom,
          fieldName: 'net_content_uom',
          label: 'Net Content UOM',
          helperText: 'UN/ECE Rec 20 code (2–3 chars, uppercase)',
          readOnly: widget.isReadOnly,
          maxLength: 3,
          validator: GtinFieldValidators.validateNetContentUomRequired,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _grossWeight,
          fieldName: 'gross_weight_value',
          label: 'Gross Weight Value',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateGrossWeightValue,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _grossWeightUom,
          fieldName: 'gross_weight_uom',
          label: 'Gross Weight UOM',
          helperText: 'UN/ECE Rec 20 code (2–3 chars, uppercase)',
          readOnly: widget.isReadOnly,
          maxLength: 3,
          validator: GtinFieldValidators.validateGrossWeightUom,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _height,
          fieldName: 'height_value',
          label: 'Height Value',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateHeightValue,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _width,
          fieldName: 'width_value',
          label: 'Width Value',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateWidthValue,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _depth,
          fieldName: 'depth_value',
          label: 'Depth Value',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          validator: GtinFieldValidators.validateDepthValue,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _dimensionUom,
          fieldName: 'dim_uom',
          label: 'Dimension UOM',
          helperText: 'UN/ECE Rec 20 code (2–3 chars, uppercase)',
          readOnly: widget.isReadOnly,
          maxLength: 3,
          validator: GtinFieldValidators.validateDimUom,
        ),
      ],
    );
  }
}

