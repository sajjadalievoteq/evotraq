import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_country_code_picker_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class ClassificationMarketOriginCoreGroup extends StatefulWidget {
  const ClassificationMarketOriginCoreGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

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

  String? get countryOfOrigin => _countryOfOrigin.text.trim().isEmpty
      ? null
      : _countryOfOrigin.text.trim();

  void setFromGtin({required String? countryOfOrigin}) {
    _countryOfOrigin.text = (countryOfOrigin ?? '').trim();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GtinCountryCodePickerField(
          controller: _countryOfOrigin,
          labelText: GtinUiConstants.labelCountryOfOrigin,
          helperText: GtinUiConstants.helperIso3166Numeric3,
          enabled: !widget.isReadOnly,
          validator: GtinFieldValidators.validateCountryOfOrigin,
        ),
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionClassificationMarketOrigin,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: widget.showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 76),
        ],
      ),
      child: body,
    );
  }
}
