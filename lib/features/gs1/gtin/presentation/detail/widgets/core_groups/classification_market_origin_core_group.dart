import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';

class ClassificationMarketOriginCoreGroup extends StatefulWidget {
  const ClassificationMarketOriginCoreGroup({
    super.key,
    required this.isReadOnly,
  });

  final bool isReadOnly;

  @override
  State<ClassificationMarketOriginCoreGroup> createState() =>
      _ClassificationMarketOriginCoreGroupState();
}

class _ClassificationMarketOriginCoreGroupState
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
        sectionLabel('5. Classification, Market & Origin (Core)'),
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

