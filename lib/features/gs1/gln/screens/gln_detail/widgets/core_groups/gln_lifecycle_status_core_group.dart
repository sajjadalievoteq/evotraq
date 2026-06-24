import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_date_field.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';
import 'package:traqtrace_app/features/gs1/widgets/gs1_group_card.dart';

class GlnLifecycleStatusCoreGroup extends StatelessWidget {
  const GlnLifecycleStatusCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
    required this.isEditing,
    required this.operatingStatus,
    required this.onOperatingStatusChanged,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.nonReuseUntil,
    required this.onPickEffectiveFrom,
    required this.onPickEffectiveTo,
  });

  final bool showFieldSkeleton;
  final bool isEditing;
  final String operatingStatus;
  final ValueChanged<String?> onOperatingStatusChanged;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final DateTime? nonReuseUntil;
  final VoidCallback onPickEffectiveFrom;
  final VoidCallback onPickEffectiveTo;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(operatingStatus),
          initialValue: operatingStatus,
          decoration: const InputDecoration(
            labelText: GlnUiConstants.labelOperatingStatus,
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: GlnUiConstants.operatingDraft,
              child: Text(GlnUiConstants.operatingDraft),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.operatingActive,
              child: Text(GlnUiConstants.operatingActive),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.operatingInactive,
              child: Text(GlnUiConstants.operatingInactive),
            ),
            DropdownMenuItem(
              value: GlnUiConstants.operatingDiscontinued,
              child: Text(GlnUiConstants.operatingDiscontinued),
            ),
          ],
          onChanged: isEditing ? onOperatingStatusChanged : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Gs1DatePickerField(
                label: GlnUiConstants.labelEffectiveFrom,
                value: effectiveFrom,
                onTap: isEditing ? onPickEffectiveFrom : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Gs1DatePickerField(
                label: GlnUiConstants.labelEffectiveTo,
                value: effectiveTo,
                onTap: isEditing ? onPickEffectiveTo : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: GlnUiConstants.labelNonReuseWaiting,
            border: OutlineInputBorder(),
            helperText: GlnUiConstants.helperNonReuseReadonly,
          ),
          child: Text(
            nonReuseUntil != null
                ? Gs1DatePickerField.displayDateFormat.format(nonReuseUntil!)
                : '—',
            style: TextStyle(
              color: nonReuseUntil != null ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ],
    );

    return Gs1GroupCard(
      title: GlnUiConstants.sectionLifecycleStatus,
      outlineColor: Theme.of(context).colorScheme.outlineVariant,
      showFieldSkeleton: showFieldSkeleton,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          GtinSkeletonOutlineField(color: c, height: 56),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
              const SizedBox(width: 12),
              Expanded(child: GtinSkeletonOutlineField(color: c, height: 56)),
            ],
          ),
          const SizedBox(height: 12),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
      child: body,
    );
  }
}
