import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class InformationProviderManufacturerCoreGroup extends StatefulWidget {
  const InformationProviderManufacturerCoreGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

  @override
  State<InformationProviderManufacturerCoreGroup> createState() =>
      InformationProviderManufacturerCoreGroupState();
}

class InformationProviderManufacturerCoreGroupState
    extends State<InformationProviderManufacturerCoreGroup> {
  late final TextEditingController _informationProviderGln;
  late final TextEditingController _informationProviderName;
  late final TextEditingController _manufacturerGln;

  @override
  void initState() {
    super.initState();
    _informationProviderGln = TextEditingController();
    _informationProviderName = TextEditingController();
    _manufacturerGln = TextEditingController();
  }

  @override
  void dispose() {
    _informationProviderGln.dispose();
    _informationProviderName.dispose();
    _manufacturerGln.dispose();
    super.dispose();
  }

  String? get informationProviderGln => _informationProviderGln.text.trim().isEmpty
      ? null
      : _informationProviderGln.text.trim();
  String? get informationProviderName => _informationProviderName.text.trim().isEmpty
      ? null
      : _informationProviderName.text.trim();
  String? get manufacturerGln =>
      _manufacturerGln.text.trim().isEmpty ? null : _manufacturerGln.text.trim();

  void setFromGtin({
    required String? informationProviderGln,
    required String? informationProviderName,
    required String? manufacturerGln,
  }) {
    _informationProviderGln.text = (informationProviderGln ?? '').trim();
    _informationProviderName.text = (informationProviderName ?? '').trim();
    _manufacturerGln.text = (manufacturerGln ?? '').trim();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Information Provider & Manufacturer'),
        GtinValidatedField(
          controller: _informationProviderGln,
          fieldName: 'information_provider_gln',
          label: 'Information Provider GLN',
          helperText: 'Enter a 13-digit barcode (numbers only, last digit is auto-verified)',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          maxLength: 13,
          validator: GtinFieldValidators.validateInformationProviderGln,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _informationProviderName,
          fieldName: 'information_provider_name',
          label: 'Information Provider Name',
          readOnly: widget.isReadOnly,
          maxLength: 200,
          validator: GtinFieldValidators.validateInformationProviderName,
        ),
        const SizedBox(height: 12),
        GtinValidatedField(
          controller: _manufacturerGln,
          fieldName: 'manufacturer_gln',
          label: 'Manufacturer GLN',
          helperText: 'Enter a 13-digit GLN (provided by your organization)',
          readOnly: widget.isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          maxLength: 13,
          validator: GtinFieldValidators.validateManufacturerGln,
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Information Provider & Manufacturer'),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
        ],
      ),
    );
  }
}

