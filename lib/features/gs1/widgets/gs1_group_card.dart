import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/utils/responsive_utils.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';
import 'package:traqtrace_app/features/gs1/widgets/section_label.dart';

class Gs1GroupCard extends StatelessWidget {
  const Gs1GroupCard({
    super.key,
    required this.title,
    required this.outlineColor,
    required this.child,
    this.showFieldSkeleton = false,
    this.skeletonFieldCount = 2,
    this.titlePadding = const EdgeInsets.only(top: 16, bottom: 12),
    this.elevation = 0,
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderRadius = 8,
    this.skeletonBuilder,
  });

  final String title;
  final Color outlineColor;
  final Widget child;
  final bool showFieldSkeleton;
  final int skeletonFieldCount;
  final EdgeInsets titlePadding;
  final double elevation;
  final EdgeInsets margin;
  final double borderRadius;
  final Widget Function(Color c)? skeletonBuilder;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(
            title,
            padding: titlePadding,
          ),
          child,
        ],
      ),
    );

    return Card(
      margin: margin,
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: outlineColor.withOpacity(0.45)),
      ),
      child: GtinFieldSkeletonMask(
        show: showFieldSkeleton,
        child: body,
        skeletonBuilder: skeletonBuilder ??
            (c) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionLabel(
                title,
                padding: titlePadding,
              ),
              for (int i = 0; i < skeletonFieldCount; i++) ...[
                GtinSkeletonOutlineField(color: c, height: 56),
                if (i != skeletonFieldCount - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

