import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/constants/gtin_detail_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class TradeItemMasterdataBoundGroup extends StatefulWidget {
  const TradeItemMasterdataBoundGroup({
    super.key,
    required this.isReadOnly,
    required this.initialStatus,
  });

  final bool isReadOnly;
  final String? initialStatus;

  @override
  State<TradeItemMasterdataBoundGroup> createState() =>
      TradeItemMasterdataBoundGroupState();
}

class TradeItemMasterdataBoundGroupState
    extends State<TradeItemMasterdataBoundGroup> {
  late final TextEditingController _brandName;
  late final TextEditingController _manufacturer;
  late final TextEditingController _unitDescriptor;
  late final TextEditingController _packSize;
  String? _status;

  @override
  void initState() {
    super.initState();
    _brandName = TextEditingController();
    _manufacturer = TextEditingController();
    _unitDescriptor = TextEditingController();
    _packSize = TextEditingController();
    _status = widget.initialStatus;
  }

  @override
  void dispose() {
    _brandName.dispose();
    _manufacturer.dispose();
    _unitDescriptor.dispose();
    _packSize.dispose();
    super.dispose();
  }

  // Values consumed by submit logic
  String get brandName => _brandName.text;
  String get manufacturer => _manufacturer.text;
  String get unitDescriptor => _unitDescriptor.text;
  TextEditingController get unitDescriptorController => _unitDescriptor;
  String get status => _status ?? 'ACTIVE';
  int? get packSize => _packSize.text.isEmpty ? null : int.tryParse(_packSize.text);

  void setFromGtin({
    required String brandName,
    required String manufacturer,
    required String unitDescriptor,
    required String? status,
    required String packSize,
  }) {
    _brandName.text = brandName;
    _manufacturer.text = manufacturer;
    _unitDescriptor.text = unitDescriptor;
    _packSize.text = packSize;
    _status = status;
    if (mounted) setState(() {});
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
        sectionLabel('2. Trade Item Master Data (Bound)'),
        GtinValidatedField(
          controller: _brandName,
          fieldName: 'brand_name',
          label: 'Brand Name *',
          readOnly: widget.isReadOnly,
          maxLength: 70,
          validator: GtinFieldValidators.validateProductName,
        ),
        const SizedBox(height: 16),
        GtinValidatedField(
          controller: _manufacturer,
          fieldName: 'manufacturer',
          label: 'Manufacturer *',
          readOnly: widget.isReadOnly,
          maxLength: 200,
          validator: GtinFieldValidators.validateManufacturer,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _unitDescriptor.text.isEmpty ? null : _unitDescriptor.text,
          decoration: const InputDecoration(
            labelText: 'Trade Item Unit Descriptor *',
            helperText: 'GDSN tradeItemUnitDescriptorCode (GS1 code list)',
          ),
          items: GtinDetailConstants.unitDescriptorOptions
              .map(
                (level) => DropdownMenuItem(
                  value: level,
                  child: Text(level),
                ),
              )
              .toList(),
          validator: widget.isReadOnly ? null : GtinFieldValidators.validateUnitDescriptor,
          onChanged: widget.isReadOnly
              ? null
              : (value) => setState(() => _unitDescriptor.text = value ?? ''),
        ),
        const SizedBox(height: 16),
        GtinValidatedField(
          controller: _packSize,
          fieldName: 'packSize',
          label: 'Pack Size',
          helperText: 'e.g., 30, 100, 500',
          readOnly: widget.isReadOnly,
          validator: GtinFieldValidators.validatePackSizeOptionalInt,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _status,
          decoration: const InputDecoration(
            labelText: 'Status',
          ),
          items: GtinDetailConstants.statusOptions
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                ),
              )
              .toList(),
          validator: widget.isReadOnly ? null : GtinFieldValidators.validateProductStatus,
          onChanged: widget.isReadOnly ? null : (value) => setState(() => _status = value),
        ),
      ],
    );
  }
}

