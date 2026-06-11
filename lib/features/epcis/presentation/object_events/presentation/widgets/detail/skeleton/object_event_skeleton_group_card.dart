import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/presentation/detail/widgets/gtin_field_shimmer.dart';

class ObjectEventSkeletonGroupCard extends StatelessWidget {
  const ObjectEventSkeletonGroupCard({
    super.key,
    required this.borderColor,
    required this.titleWidth,
    required this.fieldHeights,
    this.fieldSpacing = 12,
    this.baseColor,
  });

  final Color borderColor;
  final double titleWidth;
  final List<double> fieldHeights;
  final double fieldSpacing;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final c = baseColor ??
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
