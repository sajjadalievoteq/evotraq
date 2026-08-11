import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/widgets/skeleton_box.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/features/gs1/gtin/screens/gtin_detail/widgets/gtin_skeleton_constants.dart';

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
            SkeletonBox(
              color,
              width: 40,
              height: 40,
              radius: kGtinSkeletonInputRadius,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(color, width: 180, height: 16, radius: 4),
                  const SizedBox(height: 6),
                  SkeletonBox(color, width: 120, height: 12, radius: 4),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TraqIcon(AppAssets.iconChevronD, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}
