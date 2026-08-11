import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_skeleton_constants.dart';

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
