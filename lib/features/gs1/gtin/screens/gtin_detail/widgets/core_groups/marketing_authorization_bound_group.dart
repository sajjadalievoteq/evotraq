import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';


class MarketingAuthorizationBoundGroup extends StatelessWidget {
  const MarketingAuthorizationBoundGroup({
    super.key,
    required this.isReadOnly,
    required this.numberController,
    required this.validFromDisplayController,
    required this.validToDisplayController,
    required this.validFrom,
    required this.validTo,
    required this.onPickValidFrom,
    required this.onPickValidTo,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final TextEditingController numberController;
  final TextEditingController validFromDisplayController;
  final TextEditingController validToDisplayController;
  final DateTime? validFrom;
  final DateTime? validTo;
  final Future<void> Function() onPickValidFrom;
  final Future<void> Function() onPickValidTo;
  final bool showFieldSkeleton;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gs1ValidatedField(
          controller: numberController,
          fieldName: 'registrationNumber',
          label: 'Marketing Authorization Number *',
          helperText:
              'Regulator-issued; market-specific format (max 50 characters)',
          readOnly: isReadOnly,
          maxLength: 50,
          validator: GtinFieldValidators.validateMarketingAuthorizationNumber,
        ),
        const SizedBox(height: 16),
        Gs1DateFormField(
          controller: validFromDisplayController,
          label: GtinUiConstants.labelAuthorizationValidityFromDate,
          enabled: !isReadOnly,
          onPick: onPickValidFrom,
          validator: isReadOnly
              ? null
              : GtinFieldValidators.validateAuthorizationValidityFromDate,
        ),
        const SizedBox(height: 16),
        Gs1DateFormField(
          controller: validToDisplayController,
          label: GtinUiConstants.labelAuthorizationValidityToDate,
          enabled: !isReadOnly,
          onPick: onPickValidTo,
          validator: isReadOnly
              ? null
              : (v) => GtinFieldValidators.validateAuthorizationValidityToDate(
                  v,
                  fromValue: validFromDisplayController.text,
                ),
        ),
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionMarketingAuthorization,
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 16),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 16),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
        ],
      ),
      child: body,
    );
  }
}
