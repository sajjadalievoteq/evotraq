import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/core/widgets/gs1_fields/gtin_entry_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_validated_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_format.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';


class PackagingHierarchyTradeItemRolesCoreGroup extends StatelessWidget {
  const PackagingHierarchyTradeItemRolesCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.gtinCodeController,
    required this.unitDescriptorController,
    required this.nextLowerLevelGtinController,
    required this.nextLowerLevelQuantityController,
    required this.quantityOfChildrenController,
    required this.totalQtyNextLowerController,
    required this.launchDateDisplayController,
    required this.launchDate,
    required this.isBaseUnit,
    required this.isConsumerUnit,
    required this.isOrderableUnit,
    required this.isDespatchUnit,
    required this.isInvoiceUnit,
    required this.isVariableUnit,
    required this.onPickLaunchDate,
    required this.onIsBaseUnitChanged,
    required this.onIsConsumerUnitChanged,
    required this.onIsOrderableUnitChanged,
    required this.onIsDespatchUnitChanged,
    required this.onIsInvoiceUnitChanged,
    required this.onIsVariableUnitChanged,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final TextEditingController gtinCodeController;
  final TextEditingController unitDescriptorController;
  final TextEditingController nextLowerLevelGtinController;
  final TextEditingController nextLowerLevelQuantityController;
  final TextEditingController quantityOfChildrenController;
  final TextEditingController totalQtyNextLowerController;
  final TextEditingController launchDateDisplayController;
  final DateTime? launchDate;
  final bool isBaseUnit;
  final bool isConsumerUnit;
  final bool isOrderableUnit;
  final bool isDespatchUnit;
  final bool isInvoiceUnit;
  final bool isVariableUnit;
  final Future<void> Function() onPickLaunchDate;
  final ValueChanged<bool> onIsBaseUnitChanged;
  final ValueChanged<bool> onIsConsumerUnitChanged;
  final ValueChanged<bool> onIsOrderableUnitChanged;
  final ValueChanged<bool> onIsDespatchUnitChanged;
  final ValueChanged<bool> onIsInvoiceUnitChanged;
  final ValueChanged<bool> onIsVariableUnitChanged;

  String? _indicatorDigitFromGtin() {
    final raw = gtinCodeController.text;
    if (!GtinFieldValidators.isGtinCodeValid(raw)) return null;
    final canon = GtinFieldValidators.canonicalGtin14FromInput(raw);
    return GtinFormat.indicatorFromCanonical14(canon);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorDigit = _indicatorDigitFromGtin();

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GtinEntryField(
          controller: nextLowerLevelGtinController,
          fieldName: 'next_lower_level_gtin',
          label: GtinUiConstants.labelNextLowerLevelGtin,
          helperText: GtinUiConstants.helperWhenBaseUnitFalse,
          enabled: !isReadOnly,
          validator: (v) =>
              GtinFieldValidators.validateNextLowerLevelGtinConditional(
                v,
                isBaseUnit: isBaseUnit,
                currentGtinRaw: gtinCodeController.text,
              ),
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: nextLowerLevelQuantityController,
          fieldName: 'next_lower_level_quantity',
          label: GtinUiConstants.labelNextLowerLevelQuantity,
          helperText: GtinUiConstants.helperWhenBaseUnitFalse,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: (v) =>
              GtinFieldValidators.validateNextLowerLevelQuantityConditional(
                v,
                isBaseUnit: isBaseUnit,
                nextLowerLevelGtin: nextLowerLevelGtinController.text,
              ),
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: quantityOfChildrenController,
          fieldName: 'quantity_of_children',
          label: GtinUiConstants.labelQuantityOfChildren,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: (v) =>
              GtinFieldValidators.validateQuantityOfChildrenConditional(
                v,
                isBaseUnit: isBaseUnit,
              ),
        ),
        const SizedBox(height: 12),
        Gs1ValidatedField(
          controller: totalQtyNextLowerController,
          fieldName: 'total_qty_next_lower',
          label: GtinUiConstants.labelTotalQtyNextLower,
          readOnly: isReadOnly,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: false,
            signed: false,
          ),
          validator: (v) =>
              GtinFieldValidators.validateTotalQtyNextLowerConditional(
                v,
                isBaseUnit: isBaseUnit,
              ),
        ),
        const SizedBox(height: 12),
        Gs1DateFormField(
          key: ValueKey(launchDate),
          controller: launchDateDisplayController,
          label: GtinUiConstants.labelLaunchDate,
          enabled: !isReadOnly,
          onPick: onPickLaunchDate,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isBaseUnit,
          onChanged: isReadOnly ? null : onIsBaseUnitChanged,
          title: const Text(GtinUiConstants.switchTradeItemBaseUnit),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isConsumerUnit,
          onChanged: isReadOnly ? null : onIsConsumerUnitChanged,
          title: const Text(GtinUiConstants.switchTradeItemConsumerUnit),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isOrderableUnit,
          onChanged: isReadOnly ? null : onIsOrderableUnitChanged,
          title: const Text(GtinUiConstants.switchTradeItemOrderableUnit),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isDespatchUnit,
          onChanged: isReadOnly ? null : onIsDespatchUnitChanged,
          title: const Text(GtinUiConstants.switchTradeItemDespatchUnit),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isInvoiceUnit,
          onChanged: isReadOnly ? null : onIsInvoiceUnitChanged,
          title: const Text(GtinUiConstants.switchTradeItemInvoiceUnit),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isVariableUnit,
          onChanged: isReadOnly ? null : onIsVariableUnitChanged,
          title: const Text(GtinUiConstants.switchTradeItemVariableUnit),
        ),
        FormField<void>(
          validator: (_) => GtinFieldValidators.validateTradeItemRoleFlags(
            isBaseUnit: isBaseUnit,
            isConsumerUnit: isConsumerUnit,
            isOrderableUnit: isOrderableUnit,
            isDespatchUnit: isDespatchUnit,
            isInvoiceUnit: isInvoiceUnit,
            isVariableUnit: isVariableUnit,
            unitDescriptor: unitDescriptorController.text,
            indicatorDigit: indicatorDigit,
            isReadOnly: isReadOnly,
          ),
          builder: (state) {
            if (state.errorText == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                state.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          },
        ),
      ],
    );

    return Gs1GroupCard(
      title: GtinUiConstants.sectionPackagingHierarchyTradeItemRoles,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 76),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          const SizedBox(height: 8),
          for (var i = 0; i < 6; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            GtinSkeletonOutlineField(color: c, height: 56),
          ],
        ],
      ),
      child: body,
    );
  }
}
