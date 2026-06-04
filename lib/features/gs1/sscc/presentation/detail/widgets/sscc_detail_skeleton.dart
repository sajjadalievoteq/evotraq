import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/core/widgets/shimmer_wrapper.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';

/// Shimmer placeholder for a single detail section (extensions, compliance, etc.).
class SsccSectionLoadingSkeleton extends StatelessWidget {
  const SsccSectionLoadingSkeleton({
    super.key,
    this.title = 'Loading',
    this.fieldCount = 2,
  });

  final String title;
  final int fieldCount;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).colorScheme.outlineVariant.withValues(
          alpha: 0.45,
        );

    return AppShimmer(
      child: _SsccSkeletonGroupCard(
        borderColor: border,
        titleWidth: title.length * 8.0 + 40,
        fieldHeights: List<double>.generate(
          fieldCount,
          (i) => i == 0 ? 48 : 56,
        ),
      ),
    );
  }
}

/// Full-page skeleton for the SSCC detail screen — mirrors [SSCCDetailScreen] layout.
class SsccDetailSkeleton extends StatelessWidget {
  const SsccDetailSkeleton({
    super.key,
    this.showHeaderBanner = true,
    this.showCreateSection = false,
  });

  /// [CardWithBackgroundWidget] SSCC code banner (view / edit existing).
  final bool showHeaderBanner;

  /// Issuing GLN + extension digit + SSCC code block when creating.
  final bool showCreateSection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final accent = isDark ? Colors.grey.shade700 : Colors.grey.shade400;
    final border = Theme.of(context).colorScheme.outlineVariant.withValues(
          alpha: 0.45,
        );

    final settings = context.watch<SystemSettingsCubit>().state.settings;

    Widget group({
      required double titleWidth,
      required List<double> fieldHeights,
      double fieldSpacing = 12,
    }) {
      return _SsccSkeletonGroupCard(
        borderColor: border,
        baseColor: c,
        titleWidth: titleWidth,
        fieldHeights: fieldHeights,
        fieldSpacing: fieldSpacing,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeaderBanner) ...[
          Container(
            height: 92,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(kGtinSkeletonInputRadius),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 28,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 160,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 14,
                  width: 96,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (showCreateSection) ...[
          group(
            titleWidth: 200,
            fieldHeights: const [56, 56, 56],
            fieldSpacing: 16,
          ),
          const SizedBox(height: 16),
        ],
        // Classification & Content
        group(
          titleWidth: 200,
          fieldHeights: const [56, 56, 56, 56, 56, 56],
          fieldSpacing: 16,
        ),
        const SizedBox(height: 12),
        // Lifecycle Status
        group(
          titleWidth: 140,
          fieldHeights: const [56, 24, 24],
        ),
        const SizedBox(height: 12),
        // Dates & Milestones
        group(
          titleWidth: 160,
          fieldHeights: const [56, 24, 24],
        ),
        const SizedBox(height: 12),
        // Parties & Locations (5 GLN selectors)
        group(
          titleWidth: 180,
          fieldHeights: const [56, 56, 56, 56, 56],
        ),
        const SizedBox(height: 12),
        // Transport References
        group(
          titleWidth: 170,
          fieldHeights: const [56, 56, 56, 56],
        ),
        const SizedBox(height: 12),
        // Aggregation
        group(
          titleWidth: 120,
          fieldHeights: const [24, 24, 24, 24, 72],
        ),
        const SizedBox(height: 12),
        // EPCIS & Audit
        group(
          titleWidth: 130,
          fieldHeights: const [24, 24, 24, 24, 24, 24],
        ),
        if (settings.isPharmaceuticalMode) ...[
          const SizedBox(height: 24),
          group(
            titleWidth: 150,
            fieldHeights: const [24, 56, 56],
          ),
          const SizedBox(height: 12),
          group(
            titleWidth: 180,
            fieldHeights: const [56, 56, 56, 56, 56],
            fieldSpacing: 16,
          ),
        ] else if (settings.isTobaccoMode && kTobaccoExtensionEnabled) ...[
          const SizedBox(height: 24),
          GtinSkeletonExtensionTile(color: c),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

/// Outlined card + section title bar matching [Gs1GroupCard] spacing.
class _SsccSkeletonGroupCard extends StatelessWidget {
  const _SsccSkeletonGroupCard({
    required this.borderColor,
    required this.titleWidth,
    required this.fieldHeights,
    this.fieldSpacing = 12,
    Color? baseColor,
  }) : _baseColor = baseColor;

  final Color borderColor;
  final double titleWidth;
  final List<double> fieldHeights;
  final double fieldSpacing;
  final Color? _baseColor;

  @override
  Widget build(BuildContext context) {
    final c = _baseColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade300);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 14,
              width: titleWidth,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < fieldHeights.length; i++) ...[
              if (i > 0) SizedBox(height: fieldSpacing),
              GtinSkeletonOutlineField(color: c, height: fieldHeights[i]),
            ],
          ],
        ),
      ),
    );
  }
}
