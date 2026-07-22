import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_field_validators.dart';
import 'package:traqtrace_app/features/gs1/gtin/utils/gtin_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';


class LifecycleAvailabilityStatusCoreGroup extends StatelessWidget {
  const LifecycleAvailabilityStatusCoreGroup({
    super.key,
    required this.isReadOnly,
    required this.tradeItemStatus,
    required this.effectiveDateDisplayController,
    required this.startAvailDateDisplayController,
    required this.endAvailDateDisplayController,
    required this.publicationDateDisplayController,
    required this.startAvailDate,
    required this.endAvailDate,
    required this.onTradeItemStatusChanged,
    required this.onPickEffectiveDate,
    required this.onPickStartAvail,
    required this.onPickEndAvail,
    required this.onPickPublication,
    this.showFieldSkeleton = false,
  });

  final bool isReadOnly;
  final bool showFieldSkeleton;
  final String? tradeItemStatus;
  final TextEditingController effectiveDateDisplayController;
  final TextEditingController startAvailDateDisplayController;
  final TextEditingController endAvailDateDisplayController;
  final TextEditingController publicationDateDisplayController;
  final DateTime? startAvailDate;
  final DateTime? endAvailDate;
  final ValueChanged<String?> onTradeItemStatusChanged;
  final Future<void> Function() onPickEffectiveDate;
  final Future<void> Function() onPickStartAvail;
  final Future<void> Function() onPickEndAvail;
  final Future<void> Function() onPickPublication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('trade_item_status_$tradeItemStatus'),
          initialValue: tradeItemStatus,
          decoration: const InputDecoration(
            labelText: GtinUiConstants.labelTradeItemStatus,
            helperText: GtinUiConstants.helperTradeItemStatusCodes,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: GtinUiConstants.tradeItemStatusAdd,
              child: Text(GtinUiConstants.tradeItemStatusAdd),
            ),
            DropdownMenuItem(
              value: GtinUiConstants.tradeItemStatusChn,
              child: Text(GtinUiConstants.tradeItemStatusChn),
            ),
            DropdownMenuItem(
              value: GtinUiConstants.tradeItemStatusCor,
              child: Text(GtinUiConstants.tradeItemStatusCor),
            ),
          ],
          validator: (v) => GtinFieldValidators.validateTradeItemStatus(v),
          onChanged: isReadOnly ? null : onTradeItemStatusChanged,
        ),
        const SizedBox(height: 12),
        Gs1DateFormField(
          controller: effectiveDateDisplayController,
          label: GtinUiConstants.labelEffectiveDateTime,
          enabled: !isReadOnly,
          validator: isReadOnly
              ? null
              : (v) => (v == null || v.trim().isEmpty)
                    ? GtinUiConstants.errorEffectiveDateRequired
                    : null,
          onPick: onPickEffectiveDate,
        ),
        const SizedBox(height: 12),
        Gs1DateFormField(
          controller: startAvailDateDisplayController,
          label: GtinUiConstants.labelStartAvailabilityDateTime,
          enabled: !isReadOnly,
          onPick: onPickStartAvail,
        ),
        const SizedBox(height: 12),
        Gs1DateFormField(
          controller: endAvailDateDisplayController,
          label: GtinUiConstants.labelEndAvailabilityDateTime,
          enabled: !isReadOnly,
          onPick: onPickEndAvail,
        ),
        const SizedBox(height: 12),
        Gs1DateFormField(
          controller: publicationDateDisplayController,
          label: GtinUiConstants.labelPublicationDate,
          enabled: !isReadOnly,
          validator: isReadOnly
              ? null
              : (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return null;
                  final parsed = DateTime.tryParse(s);
                  if (parsed == null) {
                    return 'publication_date must be YYYY-MM-DD';
                  }
                  final today = DateTime.now();
                  final todayDate = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );
                  final d = DateTime(parsed.year, parsed.month, parsed.day);
                  if (d.isAfter(todayDate)) {
                    return 'publication_date must be <= today';
                  }
                  return null;
                },
          onPick: onPickPublication,
        ),
        FormField<void>(
          validator: (_) {
            if (isReadOnly) return null;
            if (startAvailDate != null &&
                endAvailDate != null &&
                endAvailDate!.isBefore(startAvailDate!)) {
              return 'End Availability Date / Time must be >= Start Availability Date / Time';
            }
            return null;
          },
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
      title: GtinUiConstants.sectionLifecycleAvailabilityStatus,
      showRequiredStar: true,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
          const SizedBox(height: 12),
          GtinSkeletonDateRow(color: c, fieldHeight: 56),
        ],
      ),
      child: body,
    );
  }
}
