import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class NetContentMeasurementsCoreGroup extends StatefulWidget {
  const NetContentMeasurementsCoreGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

  @override
  State<NetContentMeasurementsCoreGroup> createState() =>
      NetContentMeasurementsCoreGroupState();
}

class NetContentMeasurementsCoreGroupState
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

  double? _doubleOrNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : double.tryParse(c.text.trim());
  String? _stringOrNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  double? get netContentValue => _doubleOrNull(_netContent);
  String? get netContentUom => _stringOrNull(_netContentUom);
  double? get grossWeightValue => _doubleOrNull(_grossWeight);
  String? get grossWeightUom => _stringOrNull(_grossWeightUom);
  double? get heightValue => _doubleOrNull(_height);
  double? get widthValue => _doubleOrNull(_width);
  double? get depthValue => _doubleOrNull(_depth);
  String? get dimUom => _stringOrNull(_dimensionUom);

  void setFromGtin({
    required double? netContentValue,
    required String? netContentUom,
    required double? grossWeightValue,
    required String? grossWeightUom,
    required double? heightValue,
    required double? widthValue,
    required double? depthValue,
    required String? dimUom,
  }) {
    _netContent.text = netContentValue?.toString() ?? '';
    _netContentUom.text = (netContentUom ?? '').trim();
    _grossWeight.text = grossWeightValue?.toString() ?? '';
    _grossWeightUom.text = (grossWeightUom ?? '').trim();
    _height.text = heightValue?.toString() ?? '';
    _width.text = widthValue?.toString() ?? '';
    _depth.text = depthValue?.toString() ?? '';
    _dimensionUom.text = (dimUom ?? '').trim();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Net Content & Measurements'),
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
          label: 'Height',
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
          label: 'Width',
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
          label: 'Depth',
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

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Net Content & Measurements'),
          for (var i = 0; i < 8; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            GtinSkeletonOutlineField(
              color: c,
              height: {1, 3, 7}.contains(i) ? 76 : 56,
            ),
          ],
        ],
      ),
    );
  }
}

