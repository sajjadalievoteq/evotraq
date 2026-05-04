import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gln/utils/gln_ui_constants.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

/// Legacy operational subtype dropdown (warehouse, pharmacy, …).
class GlnOperationalLocationTypeCoreGroup extends StatelessWidget {
  const GlnOperationalLocationTypeCoreGroup({
    super.key,
    this.showFieldSkeleton = false,
    required this.isEditing,
    required this.locationTypeLabel,
    required this.onLocationTypeChanged,
  });

  final bool showFieldSkeleton;
  final bool isEditing;
  final String locationTypeLabel;
  final ValueChanged<String?> onLocationTypeChanged;

  @override
  Widget build(BuildContext context) {
    final items = GlnUiConstants.locationTypeDetailOptions;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(GlnUiConstants.sectionOperationalLocationType),
        DropdownButtonFormField<String>(
          key: ValueKey(
            '${locationTypeLabel}_${items.contains(locationTypeLabel)}',
          ),
          initialValue: items.contains(locationTypeLabel)
              ? locationTypeLabel
              : GlnUiConstants.operationalFallbackOther,
          decoration: const InputDecoration(
            labelText: GlnUiConstants.labelLegacyLocationSubtype,
            helperText: GlnUiConstants.helperOperationalCategory,
            border: OutlineInputBorder(),
          ),
          items: items
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: isEditing ? onLocationTypeChanged : null,
        ),
      ],
    );

    return GtinFieldSkeletonMask(
      show: showFieldSkeleton,
      child: body,
      skeletonBuilder: (c) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel(GlnUiConstants.sectionOperationalLocationType),
          GtinSkeletonOutlineField(color: c, height: 56),
        ],
      ),
    );
  }
}
