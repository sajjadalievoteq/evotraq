import 'package:flutter/material.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_field_shimmer.dart';

class GlnSkeletonThreeFieldRow extends StatelessWidget {
  const GlnSkeletonThreeFieldRow({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: GtinSkeletonOutlineField(color: color, height: 36)),
        const SizedBox(width: 8),
        Expanded(child: GtinSkeletonOutlineField(color: color, height: 36)),
        const SizedBox(width: 8),
        Expanded(child: GtinSkeletonOutlineField(color: color, height: 36)),
      ],
    );
  }
}
