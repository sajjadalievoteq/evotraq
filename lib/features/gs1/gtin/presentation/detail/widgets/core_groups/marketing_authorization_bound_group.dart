import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gtin_validated_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/utilities/gtin_ui_constants.dart';

class MarketingAuthorizationBoundGroup extends StatefulWidget {
  const MarketingAuthorizationBoundGroup({
    super.key,
    required this.isReadOnly,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;

  @override
  State<MarketingAuthorizationBoundGroup> createState() =>
      MarketingAuthorizationBoundGroupState();
}

class MarketingAuthorizationBoundGroupState
    extends State<MarketingAuthorizationBoundGroup> {
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  late final TextEditingController _number;
  late final TextEditingController _validFromDisplay;
  late final TextEditingController _validToDisplay;
  DateTime? _validFrom;
  DateTime? _validTo;

  @override
  void initState() {
    super.initState();
    _number = TextEditingController();
    _validFromDisplay = TextEditingController();
    _validToDisplay = TextEditingController();
  }

  @override
  void dispose() {
    _number.dispose();
    _validFromDisplay.dispose();
    _validToDisplay.dispose();
    super.dispose();
  }

  String get number => _number.text;
  DateTime? get validFrom => _validFrom;
  DateTime? get validTo => _validTo;

  void setFromGtin({
    required String number,
    required DateTime? validFrom,
    required DateTime? validTo,
  }) {
    _number.text = number;
    _validFrom = validFrom;
    _validTo = validTo;
    _validFromDisplay.text =
        validFrom == null ? '' : _dateFmt.format(validFrom.toLocal());
    _validToDisplay.text = validTo == null ? '' : _dateFmt.format(validTo.toLocal());
    if (mounted) setState(() {});
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime?> setValue,
    required TextEditingController display,
  }) async {
    if (widget.isReadOnly) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      setValue(picked);
      display.text = _dateFmt.format(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GtinUiConstants.sectionMarketingAuthorization),
        GtinValidatedField(
          controller: _number,
          fieldName: 'registrationNumber',
          label: 'Marketing Authorization Number',
          helperText:
              'Regulator-issued; market-specific format (max 50 characters)',
          readOnly: widget.isReadOnly,
          maxLength: 50,
          validator: GtinFieldValidators.validateMarketingAuthorizationNumber,
        ),
        const SizedBox(height: 16),
        Gs1DateFormField(
          controller: _validFromDisplay,
          label: GtinUiConstants.labelAuthorizationValidityFromDate,
          enabled: !widget.isReadOnly,
          onPick: () => _pickDate(
            current: _validFrom,
            setValue: (v) => _validFrom = v,
            display: _validFromDisplay,
          ),
          validator: widget.isReadOnly
              ? null
              : GtinFieldValidators.validateAuthorizationValidityFromDate,
        ),
        const SizedBox(height: 16),
        Gs1DateFormField(
          controller: _validToDisplay,
          label: GtinUiConstants.labelAuthorizationValidityToDate,
          enabled: !widget.isReadOnly,
          onPick: () => _pickDate(
            current: _validTo,
            setValue: (v) => _validTo = v,
            display: _validToDisplay,
          ),
          validator: widget.isReadOnly
              ? null
              : (v) => GtinFieldValidators.validateAuthorizationValidityToDate(
                    v,
                    fromValue: _validFromDisplay.text,
                  ),
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: widget.showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(GtinUiConstants.sectionMarketingAuthorization),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 16),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 16),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
        ],
      ),
    );
  }
}

