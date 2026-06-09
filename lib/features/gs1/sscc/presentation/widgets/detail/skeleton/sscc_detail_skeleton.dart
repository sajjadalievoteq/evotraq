import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traqtrace_app/core/config/feature_flags.dart';
import 'package:traqtrace_app/core/cubit/system_settings_cubit.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/sscc/presentation/widgets/detail/skeleton/sscc_skeleton_group_card.dart';

class SsccDetailSkeleton extends StatelessWidget {
  const SsccDetailSkeleton({
    super.key,
    this.showHeaderBanner = true,
    this.showCreateSection = false,
  });

  final bool showHeaderBanner;
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
      return SsccSkeletonGroupCard(
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
        group(
          titleWidth: 200,
          fieldHeights: const [56, 56, 56, 56, 56, 56],
          fieldSpacing: 16,
        ),
        const SizedBox(height: 12),
        group(
          titleWidth: 140,
          fieldHeights: const [56, 24, 24],
        ),
        const SizedBox(height: 12),
        group(
          titleWidth: 160,
          fieldHeights: const [56, 24, 24],
        ),
        const SizedBox(height: 12),
        group(
          titleWidth: 180,
          fieldHeights: const [56, 56, 56, 56, 56],
        ),
        const SizedBox(height: 12),
        group(
          titleWidth: 170,
          fieldHeights: const [56, 56, 56, 56],
        ),
        const SizedBox(height: 12),
        group(
          titleWidth: 120,
          fieldHeights: const [24, 24, 24, 24, 72],
        ),
        const SizedBox(height: 12),
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
