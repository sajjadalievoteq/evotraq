import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class InformationProviderManufacturerCoreGroup extends StatefulWidget {
  const InformationProviderManufacturerCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<InformationProviderManufacturerCoreGroup> createState() =>
      _InformationProviderManufacturerCoreGroupState();
}

class _InformationProviderManufacturerCoreGroupState
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
        sectionLabel('6. Information Provider & Manufacturer (Core)'),
        GtinValidatedField(
          controller: _informationProviderGln,
          fieldName: 'information_provider_gln',
          label: 'Information Provider GLN',
          helperText: '13 digits; Mod-10 check digit',
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
          helperText: '13 digits; Mod-10 check digit',
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
  }
}

