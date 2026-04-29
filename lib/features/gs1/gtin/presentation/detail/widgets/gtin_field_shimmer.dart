import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// [OutlineInputBorder] radius; matches M3 text fields.
const double kGtinSkeletonInputRadius = 4;

/// Keeps [child] mounted for keys/controllers while showing an animated skeleton on top.
class GtinFieldSkeletonMask extends StatelessWidget {
  const GtinFieldSkeletonMask({
    super.key,
    required this.show,
    required this.child,
    required this.skeletonBuilder,
  });

  final bool show;
  final Widget child;
  final Widget Function(Color baseColor) skeletonBuilder;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      children: [
        Opacity(
          opacity: 0,
          child: IgnorePointer(child: child),
        ),
        IgnorePointer(
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1,
              child: skeletonBuilder(baseColor),
            ),
          ),
        ),
      ],
    );
  }
}

class GtinSkeletonOutlineField extends StatelessWidget {
  const GtinSkeletonOutlineField({
    super.key,
    required this.color,
    this.height = 56,
  });

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(kGtinSkeletonInputRadius),
      ),
    );
  }
}

class GtinSkeletonDateRow extends StatelessWidget {
  const GtinSkeletonDateRow({
    super.key,
    required this.color,
    this.fieldHeight = 56,
  });

  final Color color;
  final double fieldHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: fieldHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(kGtinSkeletonInputRadius),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: fieldHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(kGtinSkeletonInputRadius),
          ),
        ),
      ],
    );
  }
}

/// Expansion-style tile placeholder for industry extensions.
class GtinSkeletonExtensionTile extends StatelessWidget {
  const GtinSkeletonExtensionTile({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            _rBox(color, 40, 40, kGtinSkeletonInputRadius),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _rBox(color, 180, 16, 4),
                  const SizedBox(height: 6),
                  _rBox(color, 120, 12, 4),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}

class GtinSkeletonPrimaryButton extends StatelessWidget {
  const GtinSkeletonPrimaryButton({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

Widget _rBox(Color color, double w, double h, double r) {
  return Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(r),
    ),
  );
}
