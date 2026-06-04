import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';

/// Full-page skeleton shown on the SGTIN detail screen while data is loading.
///
/// Mirrors the section layout of the detail form (EPC identity, serial item
/// identity, batch & dates, lifecycle, commissioning, location, regulatory,
/// EPCIS snapshot, verification, audit, pharma extension).
class SgtinDetailSkeleton extends StatelessWidget {
  const SgtinDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header banner card (CardWithBackgroundWidget)
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(kGtinSkeletonInputRadius),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 28, width: double.infinity, ),
              const SizedBox(height: 6),
              Container(height: 16, width: 160, ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(height: 14, width: 80, ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // EPC Identity card
        GtinSkeletonOutlineField(color: c, height: 36),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 24),

        // Serial Item Identity card
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),

        // Batch & Date Information card
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),

        // Lifecycle Status card
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 36),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 24),

        // Commissioning card
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 24),

        // Current Location & Custody card
        GtinSkeletonOutlineField(color: c, height: 36),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 24),

        // Regulatory Information card
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 12),
        GtinSkeletonOutlineField(color: c, height: 56),
        const SizedBox(height: 24),

        // EPCIS Event Snapshot card
        GtinSkeletonOutlineField(color: c, height: 36),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 24),

        // Verification (VRS) card
        GtinSkeletonOutlineField(color: c, height: 36),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 24),

        // Audit card
        GtinSkeletonOutlineField(color: c, height: 36),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 8),
        GtinSkeletonOutlineField(color: c, height: 24),
        const SizedBox(height: 24),

        // Pharmaceutical Extension (collapsible tiles)
        GtinSkeletonExtensionTile(color: c),
        GtinSkeletonExtensionTile(color: c),
        GtinSkeletonExtensionTile(color: c),
        const SizedBox(height: 24),
      ],
    );
  }
}
