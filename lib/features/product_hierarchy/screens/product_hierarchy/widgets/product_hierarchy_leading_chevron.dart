import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/theme/traq_theme.dart';
import 'package:traqtrace_app/core/widgets/custom_snackbar_widget.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';

class ProductHierarchyLeadingChevron extends StatelessWidget {
  const ProductHierarchyLeadingChevron({
    super.key,
    required this.isExpanded,
    required this.isLoading,
    required this.color,
  });

  final bool isExpanded;
  final bool isLoading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: TraqDuration.normal,
              curve: TraqDuration.ease,
              child: TraqIcon(AppAssets.iconChevronR, size: 18, color: color),
            ),
    );
  }
}
