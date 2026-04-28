import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class ClassificationMarketOriginCoreGroup extends StatefulWidget {
  const ClassificationMarketOriginCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<ClassificationMarketOriginCoreGroup> createState() =>
      ClassificationMarketOriginCoreGroupState();
}

class ClassificationMarketOriginCoreGroupState
    extends State<ClassificationMarketOriginCoreGroup> {
  late final TextEditingController _countryOfOrigin;

  @override
  void initState() {
    super.initState();
    _countryOfOrigin = TextEditingController();
  }

  @override
  void dispose() {
    _countryOfOrigin.dispose();
    super.dispose();
  }

  String? get countryOfOrigin =>
      _countryOfOrigin.text.trim().isEmpty ? null : _countryOfOrigin.text.trim();

  void setFromGtin({required String? countryOfOrigin}) {
    _countryOfOrigin.text = (countryOfOrigin ?? '').trim();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Classification, Market & Origin'),
        GtinCountryCodePickerField(
          controller: _countryOfOrigin,
          labelText: 'Country of Origin',
          helperText: 'ISO 3166-1 numeric (3 digits)',
          enabled: !widget.isReadOnly,
          validator: GtinFieldValidators.validateCountryOfOrigin,
        ),
      ],
    );
  }
}

